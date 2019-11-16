CFLAGS  := -ffreestanding -mcmodel=large -mno-red-zone -mno-mmx -mno-sse -mno-sse2
LDFLAGS := -n -Tsrc/link.ld
MOUNT_DIR := $(shell pwd)/mount
RUST_TARGET := x86_64-kernel
RUST_CONFIG := debug
KERNEL_LIB_PATH := target/$(RUST_TARGET)/$(RUST_CONFIG)/libkernel.a
PARTITION := scripts/partition.sh
KERNEL := obj/kernel

LOOPDEV = $(shell losetup --list --raw | cut -d " " -f 1,6 | grep disk.img | cut -d " " -f 1)

all: $(KERNEL)

install: $(KERNEL)
	@sudo cp $(KERNEL) $(MOUNT_DIR)/

clean: umount unloopback
	@rm -rf obj
	@rm -rf target
	@rm -f disk.img

$(KERNEL): obj/start.o $(KERNEL_LIB_PATH)
	@x86_64-elf-ld $(LDFLAGS) -o $(KERNEL) obj/start.o $(KERNEL_LIB_PATH)

obj:
	@mkdir obj

obj/start.o: obj
	@nasm -f elf64 -o obj/start.o src/start.asm

$(KERNEL_LIB_PATH): obj
	@RUST_TARGET_PATH="$(shell pwd)" cargo xbuild --target x86_64-kernel.json

# TODO: Look at guestfish instead of mounting
disk.img: format_disk install_grub install unloopback

install_grub: mount
	@sudo grub-install --boot-directory=$(MOUNT_DIR) --target=i386-pc $(LOOPDEV)
	@sudo cp scripts/grub.cfg $(MOUNT_DIR)/grub/grub.cfg

create_disk: umount unloopback
	@dd status=none if=/dev/zero of=disk.img bs=1M count=100
	@sfdisk --quiet disk.img < scripts/partitions.sfdisk

format_disk: loopback
	@sudo mkfs.vfat /dev/loop0p1

run: disk.img
	@qemu -drive file=disk.img,format=raw -s -S

loopback: create_disk
	@sudo losetup -f -P disk.img

unloopback: umount
	@if [ ! -z $(LOOPDEV) ]; then sudo losetup -D $(LOOPDEV); fi

mount: loopback
	@mkdir $(MOUNT_DIR)
	@sudo mount -o sync $(LOOPDEV)p1 $(MOUNT_DIR)

umount:
	@if mount | grep -q $(MOUNT_DIR); then sudo umount $(MOUNT_DIR) 2>&1 > /dev/null; fi
	@rm -rf $(MOUNT_DIR)
