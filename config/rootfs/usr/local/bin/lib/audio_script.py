from typing import Callable, Union, Iterable

import pulsectl
from lib.choices import get_choice as get_choice_shadow, ITEM
from lib.systemd import get_systemd_unit_name_for_pid
from pulsectl import PulsePortAvailableEnum, Pulse, PulseServerInfo, PulseCardInfo, PulseSinkInfo, PulseSinkInputInfo

pulse: Pulse = pulsectl.Pulse("audio-profile-switcher")
info: PulseServerInfo = pulse.server_info()
cards: [PulseCardInfo] = pulse.card_list()
sinks: [PulseSinkInfo] = [s for s in pulse.sink_list() if s.port_active is not None and
                          s.port_active.available != PulsePortAvailableEnum.no]
default_sink: str = info.default_sink_name
inputs: [PulseSinkInputInfo] = pulse.sink_input_list()


def get_choice(items: Iterable[ITEM], item_name: str, name_getter: Callable[[ITEM], str],
               active_selector: Union[Callable[[ITEM], bool], None] = None,
               sorter: Callable[[ITEM], object] = lambda i: 0) -> ITEM | None:
    return get_choice_shadow(sorted(items, key=sorter), item_name, name_getter,
                             "Audio Script", active_selector, auto_select=True)


def program_name_getter(program: PulseSinkInputInfo) -> str:
    return f'{get_systemd_unit_name_for_pid(program.proplist.get("application.process.id"))} ({program.proplist.get("application.name")})'
