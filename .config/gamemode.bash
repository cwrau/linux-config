# vim: ft=bash
#shellcheck disable=SC2034

# manualla mapping of exes to games if auto-detection fails
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
  #[portal2.sh]="Portal 2"
  #[Move or Die/start_linux32.sh]="Move or Die"
  #[Bread&Fred.exe]="Bread & Fred"
  #[conviction_game.exe]="Tom Clancy's Splinter Cell Conviction"
  #[We Were Here.exe]="We Were Here"
  #[Magicka.exe]=Magicka
  #[BloonsTD6.exe]="Bloons TD 6"
  #[Mindustry]=Mindustry
  #[Shift Happens.exe]="Shift Happens"
  #[Lethal Company.exe]="Lethal Company"
)

# space-separated list of service to start
# to behave correctly the service should Requires=gamemode.service and have Slice=gamemode.slice
declare -A gameServiceMappings=(
  [Among Us]="discord-overlay.service"
  [The Guild Gold Edition]="gamemode.target" # due to having to restart the game often, latch gamemode
  [Vermeer 2]="gamemode.target" # due to having to restart the game often, latch gamemode
)

#shellcheck disable=SC2016
declare -A gameScriptMapping=(
  ["Tom Clancy's Splinter Cell Conviction"]='systemd-run --user --slice=gamemode.slice -p Requires=gamemode.service -u conviction-fix.service -- bash -c "while :; do taskset -cap 0-\$(nproc --ignore=1) \$(pgrep conviction_game); sleep 10; done"'
)

function singleScreen() {
  if [[ "$(polybar -m | wc -l)" -gt 1 ]]; then
    autorandr --load desk --force
  fi
}

function wideScreen() {
  if [[ "$(polybar -m | wc -l)" -gt 1 ]]; then
    autorandr --load home-16:9 --force
  fi
}

function smallScreen() {
  if [[ "$(polybar -m | wc -l)" -gt 1 ]]; then
    autorandr --load home-4:3 --force
  fi
}

# function mapping suffixed with `Screen`
# wide -> wideScreen
# if function exists, will be executed
declare -A gameScreenSettings=(
  [Portal 2]="wide"
  [The Guild Gold Edition]="small"
  [Cultures 2]="small"
  [Vermeer 2]="small"
  ["Tom Clancy's Splinter Cell Conviction"]="wide"
  ["The Witcher 3: Wild Hunt"]="wide"
)
