#!/usr/bin/env bash

set -ex -o pipefail

cat - <<EOF
Set up the base system the following way:
EFI partition on /boot/efi
ROOT on / (^_^)
cryptsetup luksFormat --type luks @DISK@ #not luks2! Incompatible with grub
EOF

if [[ $(id -u) = 0 ]]
then
  ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
  hwclock --systohc
  sed -r -i 's/^#(en_GB\.UTF-8 UTF-8)/\1/g' /etc/locale.gen
  locale-gen
  echo 'LANG=en_GB.UTF-8' > /etc/locale.conf
  echo 'KEYMAP=de-latin1-nodeadkeys' > /etc/vconsole.conf
  echo "cwr" > /etc/hostname
  echo '127.0.0.1 localhost
  ::1 localhost
  127.0.1.1 cwr' > /etc/hosts
  sed -r -i 's#^HOOKS=.+$#HOOKS=(base udev autodetect modconf block keyboard keymap encrypt filesystems)#g' /etc/mkinitcpio.conf
  sed -r -i 's#^FILES=.+$#FILES=(/crypto_keyfile.bin)#g' /etc/mkinitcpio.conf
  echo "cwr ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/cwr
  id -u cwr || (
    useradd cwr -d /home/cwr -U -m
    passwd cwr
    passwd root
  )

  pacman -Sy --noconfirm --needed pacman-contrib

  curl -s "https://www.archlinux.org/mirrorlist/?country=DE&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 10 - > /etc/pacman.d/mirrorlist

  pacman -Sy --noconfirm --needed grub efibootmgr

  echo -e "Type the name of the device on which Arch is to be installed.\nMake sure to type the right one!"
  read disk
  [[ -e /dev/${disk} ]]
  echo "Is /dev/$disk correct? (YES|*)"
  read answer
  [[ ${answer} = "YES" ]]
  eval $(blkid /dev/${disk} -o export)
  sed -r -i "s#^GRUB_CMDLINE_LINUX_DEFAULT=.+\$#GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=UUID=$UUID:luks-$UUID root=/dev/mapper/luks-$UUID resume=/dev/mapper/luks-$UUID\"#g" /etc/default/grub
  echo 'GRUB_ENABLE_CRYPTODISK=y' >> /etc/default/grub

  if [[ ! -f  /crypto_keyfile.bin ]]
  then
    dd bs=512 count=4 if=/dev/random of=/crypto_keyfile.bin iflag=fullblock
  fi
  chmod 000 /crypto_keyfile.bin
  cryptsetup luksAddKey /dev/${disk} /crypto_keyfile.bin

  mkinitcpio -p linux
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch-Grub --recheck
  grub-mkconfig -o /boot/grub/grub.cfg
  echo "Reboot and run this script again as other user"
else
  sudo systemctl start dhcpcd

  sudo pacman -Sy --noconfirm --needed yay

  yay -Syu --noconfirm --needed --removemake yubico-pam feh bash-completion libu2f-host pcsclite ccid gnupg shfmt jq networkmanager-openvpn matcha-gtk-theme papirus-icon-theme xwinfo ttf-fira-code ttf-font-awesome-4 ttf-dejavu ttf-liberation breeze-hacked-cursor-theme clipmenu clipnotify xclip pulseaudio intel-ucode polkit polkit-gnome fzf \
    git ripgrep fd bat kubectl-bin kubernetes-helm-bin kubespy docker docker-compose subversion git curl diff-so-fancy tldr++ prettyping ncdu youtube-dl blugon playerctl scrot lightdm i3-wm i3status i3lock perl-anyevent-i3 network-manager-applet rke-bin jq numlockx bash-git-prompt httpie cli-visualizer dunst glances net-tools emoji-keyboard zsh dmenu-frecency imagemagick xorg-xrandr yay jdk-openjdk openjdk-src networkmanager-dmenu cht.sh bind-tools whois nload gtop
      nodejs-terminalizer dive maven maven-bash-completion-git \
    visual-studio-code-bin google-chrome gnome-terminal slack-desktop-dark evolution charles krita ranger jetbrains-toolbox firefox

  sudo usermod cwr -a -G docker wheel

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
  ln -sf ${HOME}/projects/linux-config/HOME/.gitconfig $HOME/.gitconfig
  ln -sf ${HOME}/projects/linux-config/HOME/.config/i3status $HOME/.config/i3status
  ln -sf ${HOME}/projects/linux-config/HOME/.config/i3 $HOME/.config/i3
  ln -sf ${HOME}/projects/linux-config/HOME/.config/gtk-3.0/settings.ini $HOME/.config/gtk-3.0/settings.ini
  ln -sf ${HOME}/projects/linux-config/HOME/.config/screenlayouts $HOME/.config/screenlayouts
  sudo rm -rf /usr/local/bin
  sudo ln -sf ${HOME}/projects/linux-config/BIN /usr/local/bin

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

  sudo mkdir -p /etc/udev/rules.d
  echo 'ACTION=="remove", ENV{ID_BUS}=="usb", ENV{ID_MODEL_ID}=="0407|0116", ENV{ID_VENDOR_ID}=="1050", ENV{PRODUCT}=="3/1050/407/110|3/1050/116/110", RUN+="/usr/local/bin/yubikey-lock"' | sudo tee /etc/udev/rules.d/20-yubikey.rules

  if ! grep pam_yubico.so /etc/pam.d/system-auth &>/dev/null
  then
    # only make it sufficient, you're not supposed to publish the challenge response files
    sudo sed '2 i \\nauth sufficient pam_yubico.so mode=challenge-response chalresp_path=/var/yubico' /etc/pam.d/system-auth -i
    echo "Please run 'ykpamcfg -2 -v' for each yubikey and move the '~/.yubico/challenge-*' files to '/var/yubico/$USER-*'"
  fi

  sed -r 's#set show_hidden false#set show_hidden true#' ${HOME}/.config/ranger/rc.conf -i

  xdg-mime default ranger.desktop inode/directory

  localectl set-x11-keymap de latin1 nodeadkeys
  sudo systemctl enable --now systemd-timesyncd docker NetworkManager lightdm
fi
