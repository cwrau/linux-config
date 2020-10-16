#!/usr/bin/env bash

set -ex -o pipefail

cat - <<'EOINTRO'
Set up the base system the following way:
EFI partition on /boot
ROOT on / (^_^)
EOINTRO

if [ "$1" = "chroot" ]; then
  pacstrap /mnt --needed base linux-zen linux-zen-headers linux-firmware base-devel git networkmanager libxkbcommon inetutils nvidia-dkms intel-ucode
  genfstab -U /mnt >> /mnt/etc/fstab

  cat <<-'EOCHROOT' | arch-chroot /mnt
	passwd root

	useradd cwr -d /home/cwr -U -m
	passwd cwr
	chsh -s /usr/bin/zsh cwr
	chsh -s /usr/bin/zsh root

	cat <<-'EOSUDO' | sudo -u cwr sh
		cd $HOME
		git init
		git remote add origin https://github.com/cwrau/linux-config
		git fetch
		git reset origin/master
		git reset --hard
	EOSUDO

	sed -r -i 's#^MODULES=.+$#MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)#g' /etc/mkinitcpio.conf
	mkinitcpio -P

	bootctl install

  mkdir -p /boot/loader/entries
	cat <<-EOENTRY > /boot/loader/entries/arch.conf
		title Arch Linux
		linux /vmlinuz-linux-zen
		initrd /intel-ucode.img
		initrd /initramfs-linux-zen.img
		options root=UUID=$(findmnt / -o UUID -n) rw
	EOENTRY

	cat <<-EOLOADER > /boot/loader/loader.conf
		timeout 0
		default arch.conf
		auto-entries 0
		auto-firmware 0
	EOLOADER
EOCHROOT
elif [[ $(id -u) = 0 ]]; then
  systemctl enable --now NetworkManager
  timedatectl set-timezone Europe/Berlin
  hwclock --systohc
  localectl set-locale LANG=en_US.UTF-8
  sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
  sed -i 's/#en_GB.UTF-8/en_GB.UTF-8/g' /etc/locale.gen
  localectl set-locale LC_COLLATE=C
  locale-gen
  localectl set-keymap us-latin1
  localectl set-x11-keymap us latin1
  hostnamectl set-hostname steve
  cat <<-EOHOSTS >/etc/hosts
		127.0.0.1 localhost
		::1 localhost
		127.0.0.1 $(hostname)
		::1 $(hostname)
	EOHOSTS
  echo "cwr ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/cwr

  pacman -Sy --noconfirm --needed reflector

  systemctl enable reflector.timer
  systemctl start --wait reflector.service

	cat <<-EOLOGIND > /etc/systemd/logind.conf.d/lid-poweroff.conf
		[Login]
		HandleLidSwitch=poweroff
	EOLOGIND

  echo "Run this script again as other user"
else
  sudo pacman -S --noconfirm --needed aria2
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
  sudo sed -i -r 's#ftp::/usr/bin/curl -gqfC - --ftp-pasv --retry 3 --retry-delay 3 -o %o %u#ftp::/usr/bin/aria2c -s4 %u -o %o#g' /etc/makepkg.conf
  sudo sed -i -r 's#http::/usr/bin/curl -gqb "" -fLC - --retry 3 --retry-delay 3 -o %o %u#http::/usr/bin/aria2c -s4 %u -o %o#g' /etc/makepkg.conf
  sudo sed -i -r 's#https::/usr/bin/curl -gqb "" -fLC - --retry 3 --retry-delay 3 -o %o %u#https::/usr/bin/aria2c -s4 %u -o %o#g' /etc/makepkg.conf

  multilibLine=$(grep -n "\[multilib\]" /etc/pacman.conf | cut -f1 -d:)
  sudo sed -i -r "$multilibLine,$((( $multilibLine + 1 ))) s#^\###g" /etc/pacman.conf
  sudo sed -i -r "s#^SigLevel.+\$#SigLevel = PackageRequired#g" /etc/pacman.conf

  #startPackages
  packages=(
    arandr
    aria2
    autorandr
    base
    bash-completion
    bash-git-prompt
    bash-language-server
    bat
    bc
    bind
    blueman
    bluez-utils
    breeze-hacked-cursor-theme
    clipmenu
    curl
    datagrip
    datagrip-jre
    deluge-gtk
    diff-so-fancy
    discord
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
    freetype2-cleartype
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
    gradle-zsh-completion
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
    linux-firmware
    linux-zen
    linux-zen-headers
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
    nvidia-dkms
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
    procs
    proton-ge-custom-stable-bin
    pulseaudio
    pulseaudio-bluetooth
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
    xorg-xhost
    xorg-xinit
    xorg-xinput
    xorg-xkill
    xorg-xprop
    xorg-xwininfo
    xss-lock-session
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

  sudo pip install dynmen pulsectl

  kubectl krew update
  kubectl krew install access-matrix konfig debug node-shell

  helm plugin install https://github.com/databus23/helm-diff

  sudo usermod -a -G docker,wheel,uucp,input cwr

  sudo ln -sf ${HOME}/BIN /usr/local/bin/custom
  sudo rm -rf /usr/share/icons/default
  sudo ln -sf Breeze_Hacked /usr/share/icons/default

  for hook in ${HOME}/pacman-hooks/*; do
    sudo ln -sf ${hook} /usr/share/libalpm/hooks/$(basename ${hook})
  done

  sudo ln -sf ${HOME}/ETC/profile.d/custom.sh /etc/profile.d/custom.sh
  sudo ln -sf ${HOME}/ETC/conf.d/reflector.conf /etc/conf.d/reflector.conf
  sudo rm -f /root/.bashrc
  sudo ln -sf ${HOME}/.bashrc /root/.bashrc
  sudo rm -f /root/.zshrc
  sudo ln -sf ${HOME}/.zshrc /root/.zshrc
  sudo mkdir -p /root/.config
  sudo ln -sf ${HOME}/.config/p10k.zsh /root/.config/p10k.zsh
  sudo mkdir -p /etc/udev/rules.d
  sudo cp ${HOME}/ETC/udev/rules.d/20-yubikey.rules /etc/udev/rules.d/20-yubikey.rules
  sudo ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules

  nvim +PlugInstall +exit +exit

  mkdir ${HOME}/Screenshots

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

  sudo systemctl enable --now systemd-timesyncd bluetooth pkgstats.timer fwupd ebtables dnsmasq docker.socket libvirtd.socket
  sudo systemctl disable NetworkManager-wait-online
fi
