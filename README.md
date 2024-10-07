# VM and initramfs image setup
```bash
qemu-img create -f raw archlinux_disk.img 5G
mkfs.ext4 archlinux_disk.img
mkdir mnt
sudo mount archlinux_disk.img mnt
pacman -S arch-install-scripts qemu
sudo pacstrap mnt base devel dhcpcd nvim
# Compile kernel with .config in this directory
# Make kernel bzImage
fakeroot
mkinitcpio -k /path/to/bzImage -c mkinitcpio.conf -g initramfs.img
```

https://www.collabora.com/news-and-blog/blog/2019/03/20/bootstraping-a-minimal-arch-linux-image/

For initramfs: https://m47r1x.github.io/posts/linux-boot/

# Inside VM configuration
```bash
systemctl enable dhcpcd
reboot
```

# Network setup (done in start script)
- Create tap interfaces, set them as up
- Take a bridge interface and set it as master of taps
- If you want to make the vm appear in the lan:
    - Set the bridge as using dhcp 
    - Set enp34s as the bridge's slave
    - Now the bridge has taken the place of enp34s0. It has an ip in the lan (enp34s0 doesn't)
- If you want to make the vm local to the pc, while still being able to talk to the outside:
    - Give the bridge a static ip 
    - Set the bridge up
    - The vm will appear as in the same local network as the bridge device

# For my tests
Apply the [roundrobin](roundrobin-v6.12-rc2.patch) patch to the kernel source code before compiling to add a round robin scheduler to mptcp.

## Mptcp config
In `.zprofile` or `.bash_profile`
```bash
# ======== CONFIG MPTCP
#
ip mptcp limits set add_addr_accepted 8
ip mptcp limits set subflow 8
ip mptcp endpoint add <ip1> id 1 dev ens3 subflow
ip mptcp endpoint add <ip2> id 2 dev ens4 subflow
```
## Make it good looking
- Use zshrc from my dotfiles
- Add `export TERM=xterm-256color` to it
