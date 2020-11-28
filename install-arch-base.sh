#!/usr/bin/env bash

set -ex -o pipefail

cat - <<'EOINTRO'
Set up the base system the following way:
EFI partition on /boot
ROOT on / (^_^)
EOINTRO

if [ "$1" = "iso" ]; then
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
    intel-ucode \
    aria2 \
    reflector \
    fd
  genfstab -U /mnt >/mnt/etc/fstab

  cp $0 /mnt/

  arch-chroot /mnt /$(basename $0) chroot
elif [ "$1" = "chroot" ]; then
  if ! id cwr; then
    useradd cwr -d /home/cwr -U -m
    passwd root
    passwd cwr
    chsh -s /usr/bin/zsh cwr
    chsh -s /usr/bin/zsh root
  fi

  if ! [ -d /home/cwr/.git ]; then
    cd /home/cwr
    git init
    git remote add origin https://github.com/cwrau/linux-config
    git fetch
    git reset origin/master
    git reset --hard
    cd /root
    chown -R cwr:cwr /home/cwr

    fd --type=directory --hidden . /home/cwr/rootfs -x mkdir -p {}
    for f in $(fd --type=symlink --type=file --hidden . /home/cwr/rootfs)
    do
      ln -sf ${f} -t $(dirname ${f/\/home\/cwr\/rootfs/})
    done
  fi

  sed -r -i 's/#(COMPRESSION="zstd")/\1/' /etc/mkinitcpio.conf
  sed -r -i 's/#(COMPRESSION_OPTIONS=)\(\)/\1(-T0 --ultra -22)/' /etc/mkinitcpio.conf
  mkinitcpio -P

  bootctl install

  cat <<-EOENTRY >/boot/loader/entries/arch.conf
  	title Arch Linux
  	linux /vmlinuz-linux
  	initrd /intel-ucode.img
  	initrd /initramfs-linux.img
  	options root=UUID=$(findmnt / -o UUID -n) rw quiet vga=current nvidia-drm.modeset=1
EOENTRY

  cat <<-EOLOADER >/boot/loader/loader.conf
  	timeout 0
  	default arch.conf
  	auto-entries 0
  	auto-firmware 0
EOLOADER

  ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
  hwclock --systohc
  sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
  locale-gen
  echo LANG=en_US.UTF-8 >/etc/locale.conf
  echo LC_COLLATE=C >>/etc/locale.conf
  echo KEYMAP=us-latin1 >/etc/vconsole.conf
  hostname=steve
  echo $hostname >/etc/hostname
  cat <<-EOHOSTS >/etc/hosts
  	127.0.0.1 localhost
  	127.0.0.1 $hostname
EOHOSTS
  echo "cwr ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/cwr

  reflector --save /etc/pacman.d/mirrorlist --protocol https --latest 5 --sort score

  multilibLine=$(grep -n "\[multilib\]" /etc/pacman.conf | cut -f1 -d:)
  sudo sed -i -r "$multilibLine,$((($multilibLine + 1))) s#^\###g" /etc/pacman.conf
  sudo sed -i -r "s#^SigLevel.+\$#SigLevel = PackageRequired#g" /etc/pacman.conf

  cd /home/cwr
  sudo -u cwr /$(basename $0)
else
  pushd /tmp
  [ -d yay-bin ] || git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin
  export PKGEXT=.pkg.tar
  makepkg -fs
  sudo pacman -U yay-bin-*.pkg.tar --noconfirm
  popd

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
    blueman
    bluez-utils
    breeze-hacked-cursor-theme
    clipmenu
    curl
    datagrip
    datagrip-jre
    deluge-gtk
    diff-so-fancy
    discord-canary
    dive
    dnsmasq
    docker
    docker-compose
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
    itch
    jq
    k9s
    kdeconnect
    kexec-tools
    krew-bin
    kube-linter-bin
    kubectl-bin
    lab-bin
    less
    lib32-nvidia-utils
    libfprint-2-tod1-xps9300-bin
    libfprint-tod-git
    libgnome-keyring
    libinput-gestures
    libu2f-host
    libva-mesa-driver
    linux
    linux-firmware
    linux-headers
    lscolors-git
    man-db
    man-pages
    matcha-gtk-theme
    meta-group-base-devel
    mitmproxy
    moreutils
    morsetran
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
    noto-fonts-all
    nss-mdns
    nvidia
    nvtop
    ocl-icd
    oh-my-zsh-git
    opencl-nvidia
    openjdk-src
    openssh
    pacman-contrib
    pamixer
    papirus-icon-theme
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
    procs-bin
    proton-ge-custom-stable-bin
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
    siji-git
    slack-desktop
    slit-git
    socat
    splatmoji-git
    steam
    steam-tweaks
    sxiv
    systemd
    systemd-boot-pacman-hook
    teams-insiders
    telegram-desktop
    telepresence
    thunderbird-extension-enigmail
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
    whatsapp-nativefier
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
    yay-bin
    youtube-dl
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
    neovim-drop-in
    nodejs-lts-dubnium
    rofi-dmenu
  )

  yay --pacman=pacman -S --noconfirm --needed powerpill
  # freetype2-cleartype is a problem, as one of it's dependencies, harfbuzz, depends on the original freetype2
  yes | yay -Syu --noconfirm --useask --needed --removemake --asdeps freetype2-cleartype || true
  yay -Syu --noconfirm --needed --removemake --asdeps ${prePackages[@]}

  yay -Syu --noconfirm --needed --removemake --asexplicit ${packages[@]}

  kubectl krew update
  kubectl krew install access-matrix konfig debug node-shell

  helm plugin install https://github.com/databus23/helm-diff

  sudo usermod -a -G docker,wheel,uucp,input cwr

  sudo ln -sf Breeze_Hacked /usr/share/icons/default

  nvim +PlugInstall +exit +exit

  mkdir -p ${HOME}/Screenshots

  sudo chmod u+s $(which i3lock)

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

  sudo systemctl enable systemd-timesyncd bluetooth pkgstats.timer fwupd ebtables dnsmasq docker.socket libvirtd.socket fwupd-refresh.timer NetworkManager reflector.timer
  sudo systemctl disable NetworkManager-wait-online
fi
