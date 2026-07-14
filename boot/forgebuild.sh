set -e

nasm -f win64 main.nasm -0 main.obj

x86_64-w64-mingw32-ld -subsystem 10 -entry efi_main main.obj -o BOOTX64.EFI

dd if=/dev/zero of=myos.img bs=1M count=48
parted myos.img mktable gpt
parted myos.img makpart ESP Fat32 1MiB 100%
parted myos.img set 1 esp on

mformat -i myos.img@@1M ::

mmd -i myos.img@@1M :: /EFI
mmd -i myos.img@@1M :: /EFI/BOOT
mcopy -i myos.img@@1M BOOTX64.EFI ::/EFI/BOOT/BOOTX64.EFI

qemu-system-x86_64 -bios /usr/share/ovmf/OVMF.fd -drive file=myos.img,format=raw -serial stdio
