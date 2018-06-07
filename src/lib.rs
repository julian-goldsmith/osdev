#![feature(lang_items)]
#![no_std]

extern crate rlibc;
use core::panic::PanicInfo;
use core::ptr;

#[no_mangle]
pub unsafe extern fn rust_main() -> ! {
    let vram = 0xb8000 as *mut u16;
    let chars = [0x074f as u16, 0x74b];

    ptr::write_bytes(vram, 0, 4000);
    ptr::copy_nonoverlapping(&chars as *const u16, vram, 2);

    loop { }
}

#[lang = "eh_personality"]
#[no_mangle]
pub extern fn eh_personality() {
}

#[lang = "panic_impl"]
#[no_mangle]
pub extern fn panic_impl(_pi: &PanicInfo) -> ! {
    loop { }
}
