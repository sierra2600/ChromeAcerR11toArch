# Network Manager, setup your WIFI... again... because the other method doesn't actually work
nmtui

# A restart can be recommended if ping isn't working
reboot
ping 1.1.1.1

# Setup your local language
localectl set-locale LANG=en_US.UTF-8

# Lets install reflector so we can dig those fast download speeds for updates
pacman -S reflector
reflector --protocol https --sort rate --connection-timeout 1 --download-timeout 1 --threads 1 --age 1 --delay 1 --completion-percent 100 --save /etc/pacman.d/mirrorlist

# use Ctrl+K to remove offending countries, I'm looking at you China, Iraq and Russia
nano /etc/pacman.d/mirrorlist

# perform a full system update
pacman -Syyu

# Install YAY (Yet Another Yogurt? "Yogurt! I Hate Yogurt Even With Strawberries" ... you're welcome... maybe... nevermind lets keep going)
pacman -S git && git clone https://aur.archlinux.org/yay-bin && cd yay-bin && makepkg -si

# To get started on a GUI
pacman -S xf86-video-intel xorg-{server,xinit}

# X11 KDE because Wayland is still broken. When installed in this order, the minimal amount of KDE will be installed, And why KDE? Well yes I know it's a memeory hog but why would I want to use up a bunch more disk space for programs that still pull down KDE elements?
pacman -S plasma-x11-session
pacman -S plasma-desktop vlc sddm konsole plasma-nm
systemctl enable sddm
reboot

# Haha If you want working audio in KDE :facepalm:
pacman -S pipewire-pulse plasma-pa

# If you want that old windows 7/Vista/xp like look, throw down some themes
pacman -S oxygen oxygen-sounds

# Make it a little more cozy and crap on Microshaft Windblows, file manager, notepad, office suite, a better paint
pacman -S dolphin kate libreoffice-still libreoffice-still-en-gb krita kcalc
