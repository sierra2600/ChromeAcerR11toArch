nmtui
reboot
ping 1.1.1.1
localectl set-locale LANG=en_US.UTF-8
pacman -S reflector
reflector --protocol https --sort rate --connection-timeout 1 --download-timeout 1 --threads 1 --age 1 --delay 1 --completion-percent 100 --save /etc/pacman.d/mirrorlist
nano /etc/pacman.d/mirrorlist
pacman -Syyu

#Install YAY (Yet Another Yogurt? "Yogurt! I Hate Yogurt Even With Strawberries" ... you're welcome... maybe... nevermind lets keep going)
pacman -S git && git clone https://aur.archlinux.org/yay-bin && cd yay-bin && makepkg -si

#To get started on a GUI
pacman -S xf86-video-intel xorg-{server,xinit}

#X11 KDE because Wayland still sucks, and why KDE? Well yes I know it's a memeory hog but why would I want to use up a bunch more disk space for programs that still pull down KDE elements?
pacman -S plasma-x11-session
pacman -S plasma-desktop vlc sddm konsole plasma-nm
systemctl enable sddm
reboot

#Haha If you want working audio in KDE :facepalm:
acman -S pipewire-pulse plasma-pa

#If you want that old windows 7/Vista/xp like look, throw down some themes
pacman -S oxygen oxygen-sounds

#Make it a little more cozy
pacman -S dolphin kate
