# vim: ft=bash

#shellcheck disable=SC2034
declare -A games=(
  #[HogwartsLegacy.exe]="Hogwarts Legacy"
  #[Phasmophobia.exe]="Phasmophobia"
  #[Ghost Watchers.exe]="Ghost Watchers"
  #[Back4Blood.exe]="Back 4 Blood"
  #[Among Us.exe]="Among Us"
  #[TheDivision2.exe]="The Division 2"
  #[SniperElite5.exe]="Sniper Elite 5"
  #[Anno1800.exe]="Anno 1800"
  #[UnrailedGame.exe]="Unrailed"
  #[Deep Rock Galactic/FSD.exe]="Deep Rock Galactic"
  #[splintercell.exe]="Splinter Cell"
  #[TheAscent.exe]="The Ascent"
  #[Gears5.*.exe]="Gears 5"
  #[Diggles.exe]="Wiggles"
  [portal2.sh]="Portal 2"
  [Move or Die/start_linux32.sh]="Move or Die"
  [Bread&Fred.exe]="Bread & Fred"
  [conviction_game.exe]="Tom Clancy's Splinter Cell Conviction"
  [We Were Here.exe]="We Were Here"
  [Magicka.exe]=Magicka
  [BloonsTD6.exe]="Bloons TD 6"
  [Mindustry]=Mindustry
  [Shift Happens.exe]="Shift Happens"
  [Lethal Company.exe]="Lethal Company"
)

# space-separated list of service to start
# to behave correctly the service should Requires=gamemode.service
#shellcheck disable=SC2034
declare -A gameServiceMappings=(
  [Among Us]="discord-overlay.service"
)

#shellcheck disable=SC2034
declare -A gameScriptMappings=(
  ["Tom Clancy's Splinter Cell Conviction"]='systemd-run --user -p Requires=gamemode.service -u conviction-fix.service -- bash -c "while :; do taskset -cap 0-\$(nproc --ignore=1) \$(pgrep conviction_game); sleep 10; done"'
)

# you can use `wide` and `single`(default)
#shellcheck disable=SC2034
declare -A gameScreenSettings=(
  [Portal 2]="wide"
  ["Tom Clancy's Splinter Cell Conviction"]="wide"
)
