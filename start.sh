#!/bin/bash

qemu() {
    args=(
        -drive file=archlinux_disk.img,format=raw,index=0,media=disk
        -m 4G
        -kernel /boot/vmlinuz-linuxMptcp
        -append "root=/dev/sda rw console=ttyS0 loglevel=5 nokaslr"
        -initrd ./initramfs.img
        -enable-kvm
        -device virtio-net,netdev=network0 -netdev tap,id=network0,ifname=tap0,script=no,downscript=no,vhost=on
        -device virtio-net,netdev=network1 -netdev tap,id=network1,ifname=tap1,script=no,downscript=no,vhost=on
        -s # enable gdb stub
        #-vga virtio # allow better resolution
        -nographic
    )
    qemu-system-x86_64 "${args[@]}"
}

network() {
    sudo ip tuntap add dev tap0 mode tap user jelly
    sudo ip link set tap0 up
    sudo ip link add name qemubr0 type bridge
    sudo ip link set qemubr0 up
    sudo ip link set tap0 master qemubr0
    sudo ip link set enp34s0 master qemubr0 #-> must not be connected to ethernet, it must not have an ip address
    sudo nmcli device modify qemubr0 ipv4.method auto
    #use dhcp in qemubr0 with networkmanager
    # A questo punto qemubr0 prende il posto di enp34s0, e quindi e' lui a collegarsi alla lan
    #sudo ip addr add 192.168.122.1/24 dev virbr0
    #sudo ip link set virbr0 up
    #sudo ip link set tap0 master virbr0
    # Second vm interface
    sudo ip tuntap add dev tap1 mode tap user jelly
    sudo ip link set tap1 up
    sudo ip link set tap1 master qemubr0
}

del-network() {
    sudo ip link del tap0 
    sudo ip link del tap1 
    sudo ip link del qemubr0 
}

if [[ "$1" == "qemu" ]]; then
    qemu
elif [[ "$1" == "net" ]]; then
	network
elif [[ "$1" == "del-net" ]]; then
	del-network
else
	echo "kek"
fi
