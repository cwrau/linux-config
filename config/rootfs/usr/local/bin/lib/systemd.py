import pathlib
import subprocess


def get_systemd_unit_name_for_pid(pid: int) -> str | None:
    script_path: pathlib.Path = pathlib.Path(__file__).resolve().with_name('getSystemdUnitDescriptionForPID')
    process: subprocess.Popen = subprocess.Popen([script_path, str(pid)],
                                                 stdout=subprocess.PIPE, stdin=subprocess.PIPE)
    stdout, stderr = process.communicate()
    exit_code: int = process.wait()
    if exit_code == 0:
        return stdout.decode('utf-8').rstrip("\n")
    else:
        return None
