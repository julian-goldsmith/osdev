CFLAGS  := -ffreestanding -mcmodel=large -mno-red-zone -mno-mmx -mno-sse -mno-sse2
LDFLAGS := -n -Tsrc/link.ld
MOUNT_DIR := mount
RUST_TARGET := x86_64-kernel
RUST_CONFIG := debug
KERNEL_LIB_PATH := target/$(RUST_TARGET)/$(RUST_CONFIG)/libkernel.a
PARTITION := scripts/partition.sh
KERNEL := obj/kernel

LOOPDEV = $(shell losetup --list --raw | cut -d " " -f 1,6 | grep disk.img | cut -d " " -f 1)

all: $(KERNEL)

$(KERNEL): obj/start.o $(KERNEL_LIB_PATH)
	@x86_64-elf-ld $(LDFLAGS) -o $(KERNEL) obj/start.o $(KERNEL_LIB_PATH)

obj/start.o:
	@nasm -f elf64 -o obj/start.o src/start.asm

$(KERNEL_LIB_PATH):
	@RUST_TARGET_PATH="$(shell pwd)" xargo build --target x86_64-kernel

disk.img: format_disk install_grub install unloopback

install_grub: mount
	@sudo grub-install --boot-directory=$(MOUNT_DIR) --target=i386-pc $(LOOPDEV)
	@sudo cp scripts/grub.cfg $(MOUNT_DIR)/grub/grub.cfg

create_disk:
	@dd if=/dev/zero of=disk.img bs=1M count=100
	$(PARTITION) disk.img

format_disk: loopback
	@sudo mkfs.vfat /dev/loop0p1

install: $(KERNEL)
	@sudo cp $(KERNEL) $(MOUNT_DIR)

run: disk.img
	@qemu -drive file=disk.img,format=raw

loopback: create_disk
	@sudo losetup -f -P disk.img

unloopback: umount
	@sudo losetup -D $(LOOPDEV)

mount: loopback
	# FIXME: Don't hardcode this
	@mkdir $(MOUNT_DIR)
	@sudo mount -o sync $(LOOPDEV)p1 $(MOUNT_DIR)

.PHONY: umount
umount:
	@sudo umount $(MOUNT_DIR)
	@rmdir $(MOUNT_DIR)
