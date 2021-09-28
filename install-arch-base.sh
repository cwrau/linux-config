#!/usr/bin/env bash

set -ex -o pipefail

export hostname=${2:-steve}
export installUser=${3:-cwr}

cat - <<'EOINTRO'
Set up the base system the following way:
EFI partition on /boot
ROOT on / (^_^)
EOINTRO

if [ "$1" = "iso" ]; then
  if grep -q -i intel /proc/cpuinfo; then
    ucode="intel-ucode"
  elif grep -q -i amd /proc/cpuinfo; then
    ucode="amd-ucode"
  else
    echo "Unsupported cpu vendor"
    exit 1
  fi

  cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.old
  rankmirrors -n 6 /etc/pacman.d/mirrorlist.old > /etc/pacman.d/mirrorlist

  pacstrap /mnt --needed \
    base \
    linux \
    linux-headers \
    linux-firmware \
    base-devel \
    git \
    zsh \
    networkmanager \
    nvidia \
    ${ucode} \
    aria2 \
    reflector \
    fd

  genfstab -U /mnt > /mnt/etc/fstab

  cp $0 /mnt/
  chmod +x /mnt/$(basename $0)

  arch-chroot /mnt /$(basename $0) chroot $hostname $installUser
elif [ "$1" = "chroot" ]; then
  hostname="$2"
  installUser="$3"
  if ! id ${installUser}; then
    useradd ${installUser} -d /home/${installUser} -U -m
    passwd root
    passwd ${installUser}
    chsh -s /usr/bin/zsh ${installUser}
    chsh -s /usr/bin/zsh root
  fi

  if ! [ -d /home/${installUser}/.git ]; then
    cd /home/${installUser}
    git init
    git remote add origin git@github.com:cwrau/linux-config.git
    git fetch
    git reset origin/master
    git reset --hard
    cd /root
    chown -R ${installUser}:${installUser} /home/${installUser}

    for f in $(fd --type=symlink --type=file --hidden . /home/${installUser}/rootfs)
    do
      dir=$(dirname ${f/\/home\/${installUser}\/rootfs/})
      mkdir -p $dir
      ln -sf ${f} -t $dir
    done
    unset dir
  fi

  sed -r -i 's/#(COMPRESSION="zstd")/\1/' /etc/mkinitcpio.conf
  sed -r -i 's/#(COMPRESSION_OPTIONS=)\(\)/\1(-T0 --ultra -22)/' /etc/mkinitcpio.conf
  mkinitcpio -P

  bootctl install

  cat <<-EOENTRY > /boot/loader/entries/arch.conf
  	title Arch Linux
  	linux /vmlinuz-linux
  	initrd /$ucode.img
  	initrd /initramfs-linux.img
  	options root=UUID=$(findmnt / -o UUID -n) rw quiet vga=current nvidia-drm.modeset=1
EOENTRY

  cat <<-EOLOADER > /boot/loader/loader.conf
  	timeout 0
  	default arch.conf
  	auto-entries 1
  	auto-firmware 1
EOLOADER

  ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
  hwclock --systohc
  echo en_US.UTF-8 UTF-8 > /etc/locale.gen
  locale-gen
  echo LANG=en_US.UTF-8 > /etc/locale.conf
  echo LC_COLLATE=C >> /etc/locale.conf
  echo KEYMAP=us-latin1 > /etc/vconsole.conf
  echo ${hostname} > /etc/hostname
  cat <<-EOHOSTS > /etc/hosts
  	127.0.0.1 localhost
  	127.0.0.1 ${hostname}
EOHOSTS
  echo "${installUser} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${installUser}

  reflector --save /etc/pacman.d/mirrorlist --protocol https --latest 5 --sort score

  multilibLine=$(grep -n "\[multilib\]" /etc/pacman.conf | cut -f1 -d:)
  sudo sed -i -r "$multilibLine,$((($multilibLine + 1))) s#^\###g" /etc/pacman.conf
  sudo sed -i -r "s#^SigLevel.+\$#SigLevel = PackageRequired#g" /etc/pacman.conf

  cd /home/${installUser}
  sudo -u ${installUser} /$(basename $0) $hostname $installUser
else
  hostname="$1"
  installUser="$2"
  if ! paru --version; then
    pushd /tmp
    [ -d paru-bin ] || git clone https://aur.archlinux.org/paru-bin.git
    cd paru-bin
    export PKGEXT=.pkg.tar
    makepkg -fs
    sudo pacman -U paru-bin-*.pkg.tar --noconfirm
    popd
  fi

  sudo pacman -Sy

  #startPackages
  packages=(
    advcp
    aria2
    autorandr
    base
    bash-completion
    bash-git-prompt
    bash-language-server
    bat
    batsignal
    bc
    bind
    blueman
    bluez-utils
    bpytop
    breeze-hacked-cursor-theme
    clipmenu
    curl
    datagrip
    datagrip-jre
    deluge-gtk
    diff-so-fancy
    discord_arch_electron
    dnsmasq
    dockerfile-language-server-bin
    dolphin-emu
    dunst
    earlyoom
    ebtables
    edk2-ovmf
    efibootmgr
    exa
    exo
    fahcontrol
    fahviewer
    fd
    feh
    foldingathome
    fprintd
    freerdp
    freetype2
    fwupd
    fzf
    git
    glava
    gnome-keyring
    gnome-terminal
    gnu-netcat
    gnupg
    google-chrome
    gotop-bin
    gpmdp
    gradle
    grub
    gvfs
    helm
    hexchat
    howdy
    hsetroot
    httpie
    i3-gaps
    i3lock-color
    imagemagick
    informant
    inotify-tools
    intel-ucode
    intellij-idea-ultimate-edition
    intellij-idea-ultimate-edition-jre
    jq
    k9s
    kdeconnect
    kexec-tools
    krew-bin
    kube-linter-bin
    kubectl-bin
    kubefwd-bin
    lab-bin
    less
    lib32-nvidia-utils
    libfprint-2-tod1-xps9300-bin
    libfprint-tod-git
    libgnome-keyring
    libinput-gestures
    libopenaptx
    libu2f-host
    libva-mesa-driver
    linux
    linux-firmware
    linux-headers
    lscolors-git
    man-db
    man-pages
    matcha-gtk-theme
    mesa
    meta-group-base-devel
    mitmproxy
    moreutils
    morsetran
    mpv
    mpv-mpris
    multimc5
    ncdu
    neovim-drop-in
    neovim-plug
    nerd-fonts-complete
    net-tools
    network-manager-applet
    networkmanager-dmenu-git
    networkmanager-openvpn
    nmap
    nodejs-neovim
    notify-send.sh
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-extra
    nss-mdns
    nvidia
    nvtop
    ocl-icd
    oh-my-zsh-git
    opencl-nvidia
    openjdk-src
    openssh
    pacman-contrib
    papirus-icon-theme
    pavucontrol
    pcmanfm
    perl-anyevent-i3
    perl-file-mimeinfo
    picom
    pkgstats
    playerctl
    podman
    polkit
    polkit-gnome
    polybar
    polybar-scripts-git
    powertop
    premid
    prettyping
    procs
    proton-ge-custom-bin
    pulseaudio
    pulseaudio-bluetooth
    pv
    python-dynmen
    python-notify2
    python-pip
    python-pulsectl
    python-pynvim
    python-rope
    python-traitlets
    python-virtualenv
    qemu
    realvnc-vnc-viewer
    redshift
    reflector
    remmina
    ripgrep
    rke-bin
    rofi-dmenu
    scrot
    shfmt
    signal-desktop
    siji-git
    slack-electron
    slit-git
    socat
    sof-firmware
    splatmoji-git
    steam
    steam-tweaks
    sxiv
    systemd
    systemd-boot-pacman-hook
    teams-insiders
    telegram-desktop
    telepresence
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
    virt-manager
    whatsapp-nativefier-arch-electron
    which
    xarchiver
    xclip
    xorg-server
    xorg-xinit
    xorg-xinput
    xorg-xkill
    xorg-xprop
    xorg-xwininfo
    xss-lock-session
    paru-bin
    yq
    ytmdesktop
    yubico-pam
    zip
    zoom
    zsh
    zsh-autosuggestions
    zsh-completions
    zsh-syntax-highlighting
    zsh-theme-powerlevel10k-git
    zsh-you-should-use
  )
  #endPackages

  prePackages=(
    libfprint-2-tod1-xps9300-bin
    libfprint-tod-git
    neovim-drop-in
    nodejs-lts-dubnium
    rofi-dmenu
  )

  paru -Syu --noconfirm --needed --removemake --asdeps ${prePackages[@]}

  paru -Syu --noconfirm --needed --removemake --asexplicit ${packages[@]}

  kubectl krew update
  kubectl krew install access-matrix konfig debug node-shell

  if ! helm plugin list | grep diff; then
    helm plugin install https://github.com/databus23/helm-diff
  fi

  sudo usermod -a -G wheel,uucp,input ${installUser}

  sudo ln -sf Breeze_Hacked /usr/share/icons/default

  nvim +PlugInstall +exit +exit

  mkdir -p ${HOME}/Screenshots

  sudo chmod u+s $(which i3lock)

  if ! grep pam_gnome_keyring.so /etc/pam.d/login &> /dev/null; then
    authSectionEnd="$(grep -n ^auth /etc/pam.d/login | sort -n | tail -1 | sed -r 's#^([0-9]+):.+$#\1#g')"
    sessionSectionEnd="$(grep -n ^session /etc/pam.d/login | sort -n | tail -1 | sed -r 's#^([0-9]+):.+$#\1#g')"

    sudo sed -i -r "$(($authSectionEnd + 1))i auth       optional     pam_gnome_keyring.so" /etc/pam.d/login
    if [[ "$((sessionSectionEnd + 1))" -ge "$(wc -l </etc/pam.d/login)" ]]; then
      sudo sed -i -r "$ a session    optional     pam_gnome_keyring.so auto_start" /etc/pam.d/login
    else
      sudo sed -i -r "$(($sessionSectionEnd + 1))i session    optional     pam_gnome_keyring.so auto_start" /etc/pam.d/login
    fi
  fi

  if ! grep pam_yubico.so /etc/pam.d/system-auth &> /dev/null; then
    # only make it sufficient, you're not supposed to publish the challenge response files (?)
    sudo sed '2 i \\nauth sufficient pam_yubico.so mode=challenge-response chalresp_path=/var/yubico' /etc/pam.d/system-auth -i
    echo "Please run 'ykpamcfg -2 -v' for each yubikey and move the '~/.yubico/challenge-*' files to '/var/yubico/${installUser}-*'"
  fi

  sudo systemctl enable systemd-timesyncd bluetooth pkgstats.timer fwupd ebtables dnsmasq libvirtd.socket fwupd-refresh.timer NetworkManager reflector.timer
fi
