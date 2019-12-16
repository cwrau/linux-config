#!/usr/bin/env bash

set -ex -o pipefail

function homeConfiglink() {
  ln -sf ${HOME}/projects/linux-config/HOME/$1 $HOME/$1
}

cat - <<EOF
Set up the base system the following way:
EFI partition on /boot
ROOT on / (^_^)
cryptsetup luksFormat --type luks @DISK@ #not luks2! Incompatible with grub
EOF

if [[ $(id -u) = 0 ]]
then
  timedatectl set-timezone Europe/Berlin
  hwclock --systohc
  localectl set-locale LANG=en_US.UTF-8
  #sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
  localectl set-locale LC_COLLATE=C
  locale-gen
  localectl set-keymap us-latin1
  localectl set-x11-keymap us latin1
  hostnamectl set-hostname steve
  cat <<EOF > /etc/hosts
127.0.0.1 localhost
::1 localhost
127.0.0.1 $(hostname)
EOF
  sed -r -i 's#^HOOKS=.+$#HOOKS=(base udev autodetect modconf block keyboard keymap encrypt filesystems)#g' /etc/mkinitcpio.conf
  sed -r -i 's#^MODULES=.+$#MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)#g' /etc/mkinitcpio.conf
  echo "cwr ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/cwr
  id -u cwr || (
    useradd cwr -d /home/cwr -U -m
    passwd cwr
    passwd root
  )

  pacman -Sy --noconfirm --needed pacman-contrib

  curl -s "https://www.archlinux.org/mirrorlist/?country=DE&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 10 - > /etc/pacman.d/mirrorlist

  pacman -Sy --noconfirm --needed grub efibootmgr linux

  answer="NO"
  until [[ "${answer}" == "YES" ]]
  do
    disk='$$$$$$$$'
    until [[ -e "/dev/${disk}" ]]
    do
      echo -e "Type the name of the device on which Arch is to be installed.\nMake sure to type the right one!"
      read disk
    done
    echo "Is /dev/$disk correct? (YES|*)"
    read answer
  done
  eval $(blkid /dev/${disk} -o export)
  sed -r -i "s#^GRUB_CMDLINE_LINUX_DEFAULT=.+\$#GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=UUID=$UUID:luks-$UUID root=/dev/mapper/luks-$UUID resume=/dev/mapper/luks-$UUID nvidia-drm.modeset=1\"#g" /etc/default/grub
  echo 'GRUB_ENABLE_CRYPTODISK=y' >> /etc/default/grub

  #if [[ ! -f  /crypto_keyfile.bin ]]
  #then
  #  dd bs=512 count=4 if=/dev/random of=/crypto_keyfile.bin iflag=fullblock
  #fi
  #chmod 000 /crypto_keyfile.bin
  #cryptsetup luksAddKey /dev/${disk} /crypto_keyfile.bin

  #mkinitcpio -p linux
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch --recheck
  grub-mkconfig -o /boot/grub/grub.cfg
  echo "Reboot and run this script again as other user"
else
  sudo systemctl start dhcpcd

  pushd /tmp
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si
  popd

  sudo sed -i -r "s#^PKGEXT.+\$#PKGEXT='.pkg.tar'#g" /etc/makepkg.conf
  sudo sed -i -r "s#^\#?BUILDDIR=.*\$#BUILDDIR=/tmp/makepkg#g" /etc/makepkg.conf
  sudo sed -i -r "s#^\#?MAKEFLAGS=.*\$#MAKEFLAGS=\"-j\\\$(nproc)\"#g" /etc/makepkg.conf

  #packages
  packages=(yubico-pam feh bash-completion libu2f-host pcsclite ccid gnupg shfmt networkmanager-openvpn matcha-gtk-theme papirus-icon-theme xwinfo ttf-fira-code ttf-dejavu ttf-liberation breeze-hacked-cursor-theme clipmenu clipnotify xclip pulseaudio pulseaudio-bluetooth intel-ucode polkit polkit-gnome fzf android-udev bluez libsecret libgnome-keyring p7zip unzip xorg-xwininfo xorg-xprop xorg-xinit xorg-xinput gnome-disk-utility freetype2-cleartype linux-headers noto-fonts-emoji exfat-utils
    xorg-server bc gotop-bin git ripgrep fd bat kubectl-bin kubernetes-helm-bin kubespy docker docker-compose subversion git curl diff-so-fancy tldr++ prettyping ncdu youtube-dl blugon playerctl scrot i3-gaps i3lock-color perl-anyevent-i3 network-manager-applet rke-bin jq bash-git-prompt httpie dunst glances net-tools zsh antigen-git dmenu-frecency imagemagick xorg-xrandr yay-bin jdk-openjdk openjdk-src jdk8-openjdk openjdk8-src networkmanager-dmenu cht.sh splatmoji-git bind-tools whois nload gtop
    nodejs-terminalizer dive uhk-agent-appimage hadolint-bin powertop android-tools pastebinit ausweisapp2 neovim neovim-plug python-pynvim blueman pup-bin openssh gnome-keyring mupdf xarchiver gvfs gvfs-smb k9s-bin mousepad arandr rofi rofi-dmenu udiskie-dmenu-git cups storageexplorer slit-git krew-bin rsync lxrandr yq python-nvidia-ml-py3-git dolphin-emu nvidia vulkan-icd-loader vlc libdvdread libdvdcss magic-wormhole python-pip python-traitlets python-notify2 glava autorandr inotify-tools xorg-xkill pkgstats
    libinput-gestures python-virtualenv xfce4-power-manager polybar picom kdeconnect mitmproxy python-tornado nerd-fonts-complete fwupd notify-send.sh pavucontrol pcmanfm ttf-font-awesome thunderbird-extension-enigmail pamixer virt-manager dnsmasq ebtables kubebox visual-studio-code-bin google-chrome gnome-terminal slack-desktop-dark mailspring krita jetbrains-toolbox gpmdp zoom yarn xorg-xhost sxiv vue-cli telepresence remmina powerpill noto-fonts-all k3s-bin heluxup go-pie flatpak
    earlyoom gnome-network-displays)

  yay -Syu --noconfirm --needed ${packages[@]}

  sudo pip install dynmem pulsectl

  kubectl krew update
  kubectl krew install access-matrix konfig

  helm plugin install https://github.com/databus23/helm-diff --version master

  flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  flatpak --user install flathub com.valvesoftware.Steam
  flatpak run com.valvesoftware.Steam
  flatpak override com.valvesoftware.Steam --filesystem=$HOME

  sudo usermod -a -G docker,wheel cwr

  git clone https://github.com/amix/vimrc ${HOME}/.vim_runtime
  pushd ${HOME}/.vim_runtime
  git fetch
  popd

  mkdir -p ${HOME}/projects
  git clone https://github.com/cwrau/linux-config ${HOME}/projects/linux-config

  sudo mitmproxy &
  sleep 5
  kill %1

  sudo cp /root/.mitmproxy/mitmproxy-ca-cert.cer /etc/ca-certificates/trust-source/anchors/mitmproxy-ca-cert.crt
  sudo trust extract-compat

  homeConfiglink .bashrc
  homeConfiglink .zshrc
  homeConfiglink .xinitrc
  sudo rm -f /root/.bashrc
  sudo ln -sf ${HOME}/projects/linux-config/HOME/.bashrc /root/.bashrc
  sudo mkdir -p /etc/udev/rules.d
  sudo cp ${HOME}/projects/linux-config/ETC/udev/rules.d/20-yubikey.rules /etc/udev/rules.d/20-yubikey.rules
  sudo cp ${HOME}/projects/linux-config/ETC/subuid /etc/subuid
  sudo cp ${HOME}/projects/linux-config/ETC/subgid /etc/subgid
  sudo cp ${HOME}/projects/linux-config/ETC/iptables/iptables.rules /etc/iptables/iptables.rules
  sudo cp ${HOME}/projects/linux-config/ETC/iptables/ip6tables.rules /etc/iptables/ip6tables.rules
  sudo ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
  homeConfiglink .gitconfig
  homeConfiglink .config/i3status
  homeConfiglink .config/polybar
  homeConfiglink .config/glava
  homeConfiglink .config/dunst
  homeConfiglink .config/nvim
  homeConfiglink .config/p10k.zsh
  homeConfiglink .config/picom
  homeConfiglink .config/background.jpg
  homeConfiglink .config/autorandr
  homeConfiglink .config/i3
  homeConfiglink .config/gtk-3.0
  homeConfiglink .gtkrc-2.0
  homeConfiglink .config/screenlayouts
  mkdir -p ${HOME}/.local/share/steamApps
  ln -s ${HOME}/.var/app/com.valvesoftware.Steam/Desktop ${HOME}/.local/share/steamApps/applications
  sudo ln -sf ${HOME}/projects/linux-config/BIN /usr/local/bin/custom
  sudo rm -rf /usr/share/icons/default
  sudo ln -sf Breeze_Hacked /usr/share/icons/default
  for hook in ${HOME}/projects/linux-config/pacman-hooks/*
  do
    sudo ln -sf ${hook} /usr/share/libalpm/hooks/$(basename ${hook})
  done
  sudo ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
  sudo ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/

  echo "yes" > ${HOME}/.config/gnome-initial-setup-done

  chown ${USER}:${USER} -R ${HOME}

  mkdir ${HOME}/Screenshots

  sudo chmod u+s $(which i3lock)

  echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/${USER}

  if ! grep pam_gnome_keyring.so /etc/pam.d/login &>/dev/null
  then
    authSectionEnd="$(grep -n ^auth /etc/pam.d/login | sort -n | tail -1 | sed -r 's#^([0-9]+):.+$#\1#g')"
    sessionSectionEnd="$(grep -n ^session /etc/pam.d/login | sort -n | tail -1 | sed -r 's#^([0-9]+):.+$#\1#g')"

    sudo sed -i -r "$(( $authSectionEnd + 1 ))i auth       optional     pam_gnome_keyring.so" /etc/pam.d/login
    if [[ "$(( sessionSectionEnd + 1 ))" -ge "$(wc -l < /etc/pam.d/login)" ]]
    then
      sudo sed -i -r "$ a session    optional     pam_gnome_keyring.so auto_start" /etc/pam.d/login
    else
      sudo sed -i -r "$(( $sessionSectionEnd + 1 ))i session    optional     pam_gnome_keyring.so auto_start" /etc/pam.d/login
    fi
  fi

  if ! grep pam_yubico.so /etc/pam.d/system-auth &>/dev/null
  then
    # only make it sufficient, you're not supposed to publish the challenge response files (?)
    sudo sed '2 i \\nauth sufficient pam_yubico.so mode=challenge-response chalresp_path=/var/yubico' /etc/pam.d/system-auth -i
    echo "Please run 'ykpamcfg -2 -v' for each yubikey and move the '~/.yubico/challenge-*' files to '/var/yubico/$USER-*'"
  fi

  sudo systemctl enable --now systemd-timesyncd NetworkManager bluetooth org.cups.cupsd pkgstats.timer fwupd ebtables dnsmasq libvirtd
  systemctl --user enable --now gpg-agent blugon dunst blueman-applet
  sudo systemctl disable NetworkManager-wait-online
fi
