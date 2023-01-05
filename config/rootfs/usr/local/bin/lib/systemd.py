import pathlib
import re
import subprocess
from typing import Sequence


def name_matches_unit(name: str, unit: str) -> bool:
    return re.search(f"{unit}(?:.service)?", name) is not None


def get_systemd_unit_description_for_pid(pid: int) -> str | None:
    script_path: pathlib.Path = pathlib.Path(__file__).resolve().with_name('getSystemdUnitDescriptionForPID')
    return get_process_output([script_path, str(pid)])


def get_systemd_unit_name_for_pid(pid: int) -> str | None:
    script_path: pathlib.Path = pathlib.Path(__file__).resolve().with_name('getSystemdUnitNameForPID')
    return get_process_output([script_path, str(pid)])


def get_process_output(args: Sequence[str]) -> str | None:
    process: subprocess.Popen = subprocess.Popen(args,
                                                 stdout=subprocess.PIPE, stdin=subprocess.PIPE)
    stdout, stderr = process.communicate()
    exit_code: int = process.wait()
    if exit_code == 0:
        return stdout.decode('utf-8').rstrip("\n")
    else:
        return None
