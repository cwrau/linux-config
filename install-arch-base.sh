#!/usr/bin/env bash

set -ex -o pipefail

cat - <<'EOF'
Set up the base system the following way:
EFI partition on /boot
ROOT on / (^_^)
pacstrap /mnt base linux linux-firmware base-devel git efibootmgr dhcpcd libxkbcommon inetutils
chroot:
  passwd root

  id -u cwr || (
    useradd cwr -d /home/cwr -U -m
    passwd cwr
  )
  su cwr
  cd $HOME
  git init
  git remote add origin https://github.com/cwrau/linux-config
  git fetch
  git reset origin/master
  git switch master
  git reset --hard

  sed -r -i 's#^MODULES=.+$#MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)#g' /etc/mkinitcpio.conf
  mkinitcpio -P

  efibootmgr --disk /dev/$disk --part $part --create --label "Arch Linux" --loader /vmlinuz-linux --unicode \
  'root=PARTUUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX rw initrd=\intel-ucode.img initrd=\initramfs-linux.img' --verbose
  efibootmgr -o EFIs # 3(new entry),0,1,2
EOF

if [[ $(id -u) = 0 ]]; then
  systemctl start dhcpcd
  timedatectl set-timezone Europe/Berlin
  hwclock --systohc
  localectl set-locale LANG=en_US.UTF-8
  sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
  localectl set-locale LC_COLLATE=C
  locale-gen
  localectl set-keymap us-latin1
  localectl set-x11-keymap us latin1
  hostnamectl set-hostname steve
  cat <<EOF >/etc/hosts
127.0.0.1 localhost
::1 localhost
127.0.0.1 $(hostname)
::1 $(hostname)
EOF
  echo "cwr ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/cwr

  pacman -Sy --noconfirm --needed pacman-contrib

  curl -s "https://www.archlinux.org/mirrorlist/?country=DE&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 10 - >/etc/pacman.d/mirrorlist

  echo "Run this script again as other user"
else
  pushd /tmp
  [ -d yay-bin ] || git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin
  export PKGEXT=.pkg.tar
  [ -f yay-bin-*.pkg.tar ] || makepkg -s
  sudo pacman -U yay-bin-*.pkg.tar --noconfirm
  popd

  sudo sed -i -r "s#^PKGEXT.+\$#PKGEXT='.pkg.tar'#g" /etc/makepkg.conf
  sudo sed -i -r "s#^\#?BUILDDIR=.*\$#BUILDDIR=/tmp/makepkg#g" /etc/makepkg.conf
  sudo sed -i -r "s#^\#?MAKEFLAGS=.*\$#MAKEFLAGS=\"-j\\\$(nproc)\"#g" /etc/makepkg.conf
  multilibLine=$(grep -n "\[multilib\]" /etc/pacman.conf | cut -f1 -d:)
  sudo sed -i -r "$multilibLine,$((( $multilibLine + 1 ))) s#^\###g" /etc/pacman.conf
  sudo sed -i -r "s#^SigLevel.+\$#SigLevel = PackageRequired#g" /etc/pacman.conf

  #startPackages
  packages=(
    android-tools
    android-udev
    antimicrox
    arandr
    audacity
    ausweisapp2
    autorandr
    azure-cli
    base
    bash-completion
    bash-git-prompt
    bash-language-server
    bashtop
    bat
    bc
    bind-tools
    blueman
    bluez-utils
    blugon
    breeze-hacked-cursor-theme
    ccid
    cht.sh
    clinfo
    clipmenu
    cryptsetup
    cuda
    cups
    curl
    davfs2
    deluge-gtk
    diff-so-fancy
    discord
    dive
    dnsmasq
    docker
    docker-compose
    dockerfile-language-server-bin
    dolphin-emu
    dos2unix
    dunst
    earlyoom
    ebtables
    edex-ui
    efibootmgr
    exfat-utils
    exo
    fahcontrol
    fahviewer
    fast
    fd
    feh
    firefox
    flake8
    flameshot
    fluxctl
    foldingathome
    freerdp
    freetype2-cleartype
    fwupd
    fzf
    gamehub
    git
    glances
    glava
    gnome-disk-utility
    gnome-keyring
    gnome-network-displays
    gnome-terminal
    gnu-netcat
    gnupg
    go
    google-chrome
    gotop-bin
    gparted
    gpmdp
    gradle
    gradle-zsh-completion
    groovy
    grub
    gtop
    gvfs-smb
    hadolint-bin
    helm
    heluxup
    highlight
    hsetroot
    httpie
    i3-gaps
    i3lock-color
    imagemagick
    informant
    inotify-tools
    intel-ucode
    itch
    jetbrains-toolbox
    jq
    js-beautify
    k9s
    kdeconnect
    kotlin-language-server
    krew-bin
    kube-score
    kubebox
    kubectl-bin
    lab-bin
    lens-bin
    less
    lib32-nvidia-utils
    libaacs
    libdvdcss
    libdvdread
    libgnome-keyring
    libinput-gestures
    libsecret
    libu2f-host
    libva-mesa-driver
    linux-firmware
    linux-headers
    lscolors-git
    lutris
    lutris-wine-meta
    lxrandr
    magic-wormhole
    man-db
    man-pages
    matcha-gtk-theme
    meta-group-base-devel
    moreutils
    morsetran
    mousepad
    multimc5
    mupdf
    ncdu
    neovim-drop-in
    neovim-plug
    nerd-fonts-complete
    net-tools
    nethogs
    network-manager-applet
    networkmanager-dmenu-git
    networkmanager-openvpn
    nload
    nmap
    nodejs-neovim
    notify-send.sh
    noto-fonts-all
    noto-fonts-emoji-fontconfig
    nss-mdns
    ntfs-3g
    nvidia
    nvidia-docker-compose
    nvtop
    obs-studio
    oh-my-zsh-git
    openjdk-src
    openresolv
    openssh
    p7zip
    pacman-contrib
    pamixer
    papirus-icon-theme
    pastebinit
    pavucontrol
    pcmanfm
    perl-anyevent-i3
    picom
    pkgstats
    playerctl
    polkit
    polkit-gnome
    polybar
    polybar-scripts-git
    powerpill
    powertop
    premid
    prettyping
    procs
    pulseaudio
    pulseaudio-bluetooth
    pup-bin
    pv
    python-language-server
    python-notify2
    python-pip
    python-pylint
    python-pynvim
    python-rope
    python-traitlets
    python-virtualenv
    python2-pynvim
    realvnc-vnc-viewer
    remmina
    ripgrep
    rke-bin
    rofi-dmenu
    rsync
    s3cmd
    scrot
    shfmt
    siji-git
    slack-desktop
    slit-git
    socat
    splatmoji-git
    steam
    storageexplorer
    strace
    sway
    sxiv
    systemd
    teams-insiders
    telegram-desktop-bin
    telepresence
    thunderbird-extension-enigmail
    tig
    traceroute
    tree
    ttf-dejavu
    ttf-fira-code
    ttf-font-awesome
    ttf-liberation
    tty-clock
    udiskie-dmenu-git
    uhk-agent-appimage
    unzip
    usbutils
    v4l2loopback-dkms
    virt-manager
    vlc
    vulkan-icd-loader
    whatsapp-nativefier
    which
    whois
    xarchiver
    xclip
    xfce4-power-manager
    xorg-server
    xorg-xhost
    xorg-xinit
    xorg-xinput
    xorg-xkill
    xorg-xprop
    xorg-xwininfo
    yaml-language-server-bin
    yapf
    yarn
    yay-bin
    youtube-dl
    yq
    yubico-pam
    zip
    zoom
    zsh
    zsh-autosuggestions
    zsh-completions
    zsh-syntax-highlighting
    zsh-theme-powerlevel10k-git
  )
  #endPackages

  yay -S --noconfirm powerpill
  yay --pacman=powerpill -Syu --noconfirm --needed ${packages[@]}

  sudo pip install dynmem pulsectl

  kubectl krew update
  kubectl krew install access-matrix konfig debug node-shell

  helm plugin install https://github.com/databus23/helm-diff --version master

  sudo usermod -a -G docker,wheel,uucp,input cwr

  sudo ln -sf ${HOME}/BIN /usr/local/bin/custom
  sudo rm -rf /usr/share/icons/default
  sudo ln -sf Breeze_Hacked /usr/share/icons/default

  for hook in ${HOME}/pacman-hooks/*; do
    sudo ln -sf ${hook} /usr/share/libalpm/hooks/$(basename ${hook})
  done

  sudo ln -sf ${HOME}/ETC/profile.d/custom.sh /etc/profile.d/custom.sh
  sudo rm -f /root/.bashrc
  sudo ln -sf ${HOME}/.bashrc /root/.bashrc
  sudo rm -f /root/.zshrc
  sudo ln -sf ${HOME}/.zshrc /root/.zshrc
  sudo mkdir -p /etc/udev/rules.d
  sudo cp ${HOME}/ETC/udev/rules.d/20-yubikey.rules /etc/udev/rules.d/20-yubikey.rules
  sudo ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules


  nvim +PlugInstall +exit +exit

  echo "yes" >${HOME}/.config/gnome-initial-setup-done

  chown ${USER}:${USER} -R ${HOME}

  mkdir ${HOME}/Screenshots

  sudo chmod u+s $(which i3lock)

  echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/${USER}

  if ! grep pam_gnome_keyring.so /etc/pam.d/login &>/dev/null; then
    authSectionEnd="$(grep -n ^auth /etc/pam.d/login | sort -n | tail -1 | sed -r 's#^([0-9]+):.+$#\1#g')"
    sessionSectionEnd="$(grep -n ^session /etc/pam.d/login | sort -n | tail -1 | sed -r 's#^([0-9]+):.+$#\1#g')"

    sudo sed -i -r "$(($authSectionEnd + 1))i auth       optional     pam_gnome_keyring.so" /etc/pam.d/login
    if [[ "$((sessionSectionEnd + 1))" -ge "$(wc -l </etc/pam.d/login)" ]]; then
      sudo sed -i -r "$ a session    optional     pam_gnome_keyring.so auto_start" /etc/pam.d/login
    else
      sudo sed -i -r "$(($sessionSectionEnd + 1))i session    optional     pam_gnome_keyring.so auto_start" /etc/pam.d/login
    fi
  fi

  if ! grep pam_yubico.so /etc/pam.d/system-auth &>/dev/null; then
    # only make it sufficient, you're not supposed to publish the challenge response files (?)
    sudo sed '2 i \\nauth sufficient pam_yubico.so mode=challenge-response chalresp_path=/var/yubico' /etc/pam.d/system-auth -i
    echo "Please run 'ykpamcfg -2 -v' for each yubikey and move the '~/.yubico/challenge-*' files to '/var/yubico/$USER-*'"
  fi

  sudo systemctl enable --now systemd-timesyncd NetworkManager bluetooth pkgstats.timer fwupd ebtables dnsmasq rfkill-unblock@all
  systemctl --user enable --now gpg-agent updates.timer
  sudo systemctl disable NetworkManager-wait-online
  sudo systemctl stop dhcpcd
  sudo pacman -R dhcpcd
fi
