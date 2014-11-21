PARTITIONS=ada0
DISTRIBUTIONS="base.txz kernel.txz games.txz lib32.txz"

#! /bin/sh
cat >> /etc/rc.conf <<EOF
ifconfig_em0="DHCP"
sshd_enable="YES"
# Set dumpdev to "AUTO" to enable crash dumps, "NO" to disable
dumpdev="AUTO"
local_unbound_enable="YES"
vboxguest_enable="YES"
vboxservice_enable="YES"
EOF

# SSH config
echo "UseDNS no" >> /etc/ssh/sshd_config

# Start local unbound, for pkg install
service local_unbound onestart

# Activate pkg
ASSUME_ALWAYS_YES=YES pkg bootstrap

# Install sudo & virtualbox additions
ASSUME_ALWAYS_YES=YES pkg install sudo emulators/virtualbox-ose-additions

# Activate the wheel group for the vagrant user
sed -i .bak -e 's/^# %wheel ALL=(ALL) ALL$/%wheel ALL=(ALL) NOPASSWD: ALL/' /usr/local/etc/sudoers

# Add the vagrant user, and add it to the wheel group
adduser -f <<EOF
vagrant::::::vagrant::sh:vagrant
EOF
pw usermod vagrant -G wheel

# Change root password
pw usermod root -h 0 <<EOF
vagrant
EOF

# Reboot
shutdown -r now
