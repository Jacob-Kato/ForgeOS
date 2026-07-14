#!/bin/bash
set -e

nasm -f win64 main.nasm -o main.obj

x86_64-w64-mingw32-ld -subsystem 10 -entry efi_main main.obj -o BOOTX64.EFI

rm -f forgeos.img
dd if=/dev/zero of=forgeos.img bs=1M count=48

mformat -i forgeos.img ::

mmd -i forgeos.img ::/EFI
mmd -i forgeos.img ::/EFI/BOOT
mcopy -i forgeos.img BOOTX64.EFI ::/EFI/BOOT/BOOTX64.EFI

qemu-system-x86_64 -bios /usr/share/ovmf/OVMF.fd -drive file=forgeos.img,format=raw -serial stdio

