-- Snap audio volumes to nearest 5%
-- Two hooks:
--   1. node/snap-volume      → stream nodes (no device routes), snaps Props
--   2. device/snap-route-vol → device nodes (ALSA sinks), snaps device Route

local cutils = require("common-utils")
local log = Log.open_topic("s-snap-vol")

local SNAP = 0.05
local EPSILON = 0.001

-- channelVolumes are stored in cubic (PW linear amplitude).
-- wpctl display = raw^(1/3).  Snap in that display space.
local function snap(raw)
	local linear = raw ^ (1.0 / 3.0)
	local snapped = math.floor(linear / SNAP + 0.5) * SNAP
	return snapped ^ 3.0
end

local function needs_snap(v)
	return math.abs(v - snap(v)) > EPSILON
end

-- ── 1. Stream / virtual-sink node hook ───────────────────────────────────────

local node_adjusting = false

SimpleEventHook({
	name = "node/snap-volume",
	after = "node/store-stream-props",
	interests = {
		EventInterest({
			Constraint({ "event.type", "=", "node-params-changed" }),
			Constraint({ "event.subject.param-id", "=", "Props" }),
			Constraint({ "media.class", "matches", "Stream/*" }),
		}),
		-- virtual sinks without device routes
		EventInterest({
			Constraint({ "event.type", "=", "node-params-changed" }),
			Constraint({ "event.subject.param-id", "=", "Props" }),
			Constraint({ "media.class", "matches", "Audio/*" }),
			Constraint({ "device.routes", "is-absent" }),
		}),
		EventInterest({
			Constraint({ "event.type", "=", "node-params-changed" }),
			Constraint({ "event.subject.param-id", "=", "Props" }),
			Constraint({ "media.class", "matches", "Audio/*" }),
			Constraint({ "device.routes", "equals", "0" }),
		}),
	},
	execute = function(event)
		if node_adjusting then return end
		local node = event:get_subject()
		for p in node:iterate_params("Props") do
			local props = cutils.parseParam(p, "Props")
			if not props or not props.channelVolumes then goto skip end

			local changed = false
			local new_vols = {}
			for i, v in ipairs(props.channelVolumes) do
				new_vols[i] = snap(v)
				if needs_snap(v) then changed = true end
			end

			if changed then
				log:info(node, "snapping stream volume to nearest 5%")
				node_adjusting = true
				table.insert(new_vols, 1, "Spa:Float")
				node:set_param("Props", Pod.Object({
					"Spa:Pod:Object:Param:Props", "Props",
					channelVolumes = Pod.Array(new_vols),
				}))
				node_adjusting = false
			end
			::skip::
		end
	end,
}):register()

-- ── 2. Device route hook (ALSA sinks, etc.) ──────────────────────────────────

local route_adjusting = false

SimpleEventHook({
	name = "device/snap-route-vol",
	after = "device/store-or-restore-routes",
	interests = {
		EventInterest({
			Constraint({ "event.type", "=", "device-params-changed" }),
			Constraint({ "event.subject.param-id", "=", "Route" }),
		}),
	},
	execute = function(event)
		if route_adjusting then return end
		local device = event:get_subject()
		for p in device:iterate_params("Route") do
			local route = cutils.parseParam(p, "Route")
			if not route or not route.props then goto skip end
			local props = route.props.properties
			if not props or not props.channelVolumes then goto skip end

			local changed = false
			local new_vols = {}
			for i, v in ipairs(props.channelVolumes) do
				new_vols[i] = snap(v)
				if needs_snap(v) then changed = true end
			end

			if changed then
				log:info(device, string.format(
					"snapping device route[%d] volume to nearest 5%%", route.index))
				route_adjusting = true
				table.insert(new_vols, 1, "Spa:Float")
				device:set_param("Route", Pod.Object({
					"Spa:Pod:Object:Param:Route", "Route",
					index = route.index,
					device = route.device,
					props = Pod.Object({
						"Spa:Pod:Object:Param:Props", "Route",
						channelVolumes = Pod.Array(new_vols),
					}),
					save = true,
				}))
				route_adjusting = false
			end
			::skip::
		end
	end,
}):register()
