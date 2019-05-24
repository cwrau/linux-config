#!/usr/bin/env bash

set -ex -o pipefail

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
  hostnamectl set-hostname cwr
  echo '127.0.0.1 localhost
::1 localhost
127.0.1.1 cwr' > /etc/hosts
  sed -r -i 's#^HOOKS=.+$#HOOKS=(base udev autodetect modconf block keyboard keymap encrypt filesystems)#g' /etc/mkinitcpio.conf
  #sed -r -i 's#^FILES=.+$#FILES=(/crypto_keyfile.bin)#g' /etc/mkinitcpio.conf
  echo "cwr ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/cwr
  id -u cwr || (
    useradd cwr -d /home/cwr -U -m
    passwd cwr
    passwd root
  )

  pacman -Sy --noconfirm --needed pacman-contrib

  curl -s "https://www.archlinux.org/mirrorlist/?country=DE&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 10 - > /etc/pacman.d/mirrorlist

  pacman -Sy --noconfirm --needed grub efibootmgr linux-zen

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
  sed -r -i "s#^GRUB_CMDLINE_LINUX_DEFAULT=.+\$#GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=UUID=$UUID:luks-$UUID root=/dev/mapper/luks-$UUID resume=/dev/mapper/luks-$UUID\"#g" /etc/default/grub
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

  #yay -R --noconfirm freetype2
  yay -Syu --noconfirm --needed \
    yubico-pam feh bash-completion libu2f-host pcsclite ccid gnupg shfmt jq networkmanager-openvpn matcha-gtk-theme papirus-icon-theme xwinfo ttf-fira-code ttf-font-awesome-4 ttf-dejavu ttf-liberation breeze-hacked-cursor-theme clipmenu clipnotify xclip pulseaudio pulseaudio-bluetooth intel-ucode polkit polkit-gnome fzf xfce4-power-manager android-udev bluez libsecret libgnome-keyring p7zip unzip xorg-xwininfo xorg-xprop xorg-xinit xorg-xinput gnome-disk-utility freetype2-cleartype \
      linux-zen-headers noto-fonts-emoji exfat-utils \
  \
    thunar xorg-server bc gotop-bin git ripgrep fd bat kubectl-bin kubernetes-helm-bin kubespy docker docker-compose subversion git curl diff-so-fancy tldr++ prettyping ncdu youtube-dl blugon playerctl scrot i3-wm i3status i3lock perl-anyevent-i3 network-manager-applet rke-bin jq numlockx bash-git-prompt httpie cli-visualizer dunst glances net-tools zsh dmenu-frecency imagemagick xorg-xrandr yay jdk8-openjdk openjdk8-src jdk-openjdk openjdk-src networkmanager-dmenu cht.sh splatmoji-git \
    bind-tools whois nload gtop nodejs-terminalizer dive maven maven-bash-completion-git uhk-agent-appimage hadolint-bin powertop go minikube-bin scaleway-cli android-tools pastebinit ausweisapp2 vim blueman pup-bin openssh gnome-keyring mupdf xarchiver thunar-archive-plugin gvfs gvfs-smb k9s-bin mousepad arandr rofi rofi-dmenu udiskie-dmenu-git cups storageexplorer \
  \
    visual-studio-code-bin google-chrome gnome-terminal slack-desktop-dark mailspring charles krita ranger jetbrains-toolbox firefox gpmdp

  sudo usermod -a -G docker,wheel cwr

  cat - <<EOF | sudo tee /etc/polkit-1/rules.d/90-blueman.rules
polkit.addRule(function(action, subject) {
  if ((action.id == "org.blueman.network.setup" ||
       action.id == "org.blueman.dhcp.client" ||
       action.id == "org.blueman.rfkill.setstate" ||
       action.id == "org.blueman.pppd.pppconnect") &&
      subject.isInGroup("wheel")) {
      return polkit.Result.YES;
  }
});
EOF

  git clone https://github.com/amix/vimrc ${HOME}/.vim_runtime
  pushd ${HOME}/.vim_runtime
  git fetch
  popd

  mkdir -p ${HOME}/projects
  git clone https://github.com/cwrau/linux-config ${HOME}/projects/linux-config

  mkdir -p ${HOME}/.config/gtk-3.0

  ln -sf ${HOME}/projects/linux-config/HOME/.bashrc $HOME/.bashrc
  ln -sf ${HOME}/projects/linux-config/HOME/.xinitrc $HOME/.xinitrc
  sudo rm -f /root/.bashrc
  sudo ln -sf ${HOME}/projects/linux-config/HOME/.bashrc /root/.bashrc
  sudo mkdir -p /etc/udev/rules.d
  sudo cp ${HOME}/projects/linux-config/ETC/UDEV/RULES.D/20-yubikey.rules /etc/udev/rules.d/20-yubikey.rules
  ln -sf ${HOME}/projects/linux-config/HOME/.gitconfig $HOME/.gitconfig
  ln -sf ${HOME}/projects/linux-config/HOME/.config/i3status $HOME/.config/i3status
  ln -sf ${HOME}/projects/linux-config/HOME/.config/i3 $HOME/.config/i3
  ln -sf ${HOME}/projects/linux-config/HOME/.config/gtk-3.0/settings.ini $HOME/.config/gtk-3.0/settings.ini
  ln -sf /home/cwr/projects/linux-config/HOME/.gtkrc-2.0 $HOME/.gtkrc-2.0
  ln -sf ${HOME}/projects/linux-config/HOME/.config/screenlayouts $HOME/.config/screenlayouts
  sudo rm -rf /usr/local/bin
  sudo ln -sf ${HOME}/projects/linux-config/BIN /usr/local/bin
  sudo rm -rf /usr/share/icons/default
  sudo ln -sf Breeze_Hacked /usr/share/icons/default
  sudo ln -sf ${HOME}/projects/linux-config/pacman.hook /usr/share/libalpm/hooks/i3status-updates.hook
  sudo ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
  sudo ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/

  echo "yes" > ${HOME}/.config/gnome-initial-setup-done

  curl -fsSL http://dogr.io/wow/very%20wallpapger/so%20lockscreen/such%20laptop/much%20secure.png?split=false > ${HOME}/.config/screen-lock.png
  curl -fsSL https://upload.wikimedia.org/wikipedia/commons/3/3d/NASA%27s_Swift_Mission_Observes_Mega_Flares_from_a_Mini_Star.jpg > ${HOME}/.config/background.jpg

  mkdir -p ${HOME}/.config/dunst
  curl https://dunst-project.org/static/dunstrc1 > ${HOME}/.config/dunst/dunstrc

  chown ${USER}:${USER} -R ${HOME}

  sudo -u ${USER} /bin/bash -c ". ${HOME}/.vim_runtime/install_awesome_vimrc.sh"

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
    # only make it sufficient, you're not supposed to publish the challenge response files
    sudo sed '2 i \\nauth sufficient pam_yubico.so mode=challenge-response chalresp_path=/var/yubico' /etc/pam.d/system-auth -i
    echo "Please run 'ykpamcfg -2 -v' for each yubikey and move the '~/.yubico/challenge-*' files to '/var/yubico/$USER-*'"
  fi

  sed -r 's#set show_hidden false#set show_hidden true#' ${HOME}/.config/ranger/rc.conf -i

  sudo systemctl enable --now systemd-timesyncd docker NetworkManager bluetooth org.cups.cupsd
  systemctl --user enable --now gpg-agent
  sudo systemctl disable NetworkManager-wait-online
fi
