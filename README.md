# ChromeAcerR11toArch
Chromebook R11 (CYAN / CB5-132T) - Arch
Linux Install Scripts

!!! NOTICE !!! I WILL RECOMMEND READING
INTO THE SHELL SCRIPTS BEFORE BLINDLY
DOWNLOADING AND USING THEM! THERE IS ONE
COMMAND THAT IN instll1.sh THAT IS MEANT
TO ERASE THE STORAGE OF THE CHROMEBOOK

fwscript.sh has the command that needs
to be ran inside of ChromeOS

When you have your DVD or USB drive
in the computer that you want to
install Arch on, the media actually
has OpenSSH, if you have a Ethernet to
USB adapter (or a built in Ethernet
port) or you go though the rounds of
connecting to WIFI (which I do not
recommend AT ALL doing while installing
anything as corruption can happen, and
yes even despite checksums being done) 
you can do 'passwd' and set the root
password then 'ip a' to get the IP
address for the computer and use SSH
to remote in and install from a
terminal that you can copy and paste
into!

instll1.sh WILL ERASE THE CHROMEBOOK!
It has all the commands for creating
and formatting the partitions, creating
folders, setting up the simple
bootloader (the script is more setup
for copy an paste at the moment)

PstInstll.sh is post install, I am
getting tired of KDE pushing the still
very broken Wayland, I need to be able
to use AnyDesk and RustDesk in
unattended mode (where someone isn't at
the laptop/PC to click allow) and I am
having issues at the moment with not
getting ANY audio from Discord

Based off of the guide from Sudaraka
Wijesinghe titled "Chromebook R11
(CYAN / CB5-132T) - Arch Linux
Installation Guide" from "Tuesday,
November 10, 2020"

I cannot guarguarantee that I myself
will have this maintained but I've been
getting frustrated with having to
retype all of the commands and I'm sure
there are other people out there that
may have the same level of frustration
and not enough time in the world to do
all of this typing
for low resresolutions)
