import pulsectl

from lib.choices import get_choice as get_choice_shadow

pulse = pulsectl.Pulse("audio-profile-switcher")
info = pulse.server_info()
cards = pulse.card_list()
sinks = pulse.sink_list()
default_sink = info.default_sink_name
inputs = pulse.sink_input_list()


def get_choice(items, item_name, name_getter, active_selector=None):
    return get_choice_shadow(items, item_name, name_getter, "Audio Script", active_selector, auto_select=True)
