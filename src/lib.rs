#![feature(panic_implementation)]
#![no_std]

extern crate rlibc;
mod terminal;

use core::fmt::Write;
use core::panic::PanicInfo;

#[no_mangle]
pub unsafe extern "C" fn rust_main() -> ! {
    let mut term = terminal::new();
    term.clear();

    //write!(&mut term, "Hello, {}", "world").unwrap();
    //term.print();
    //core::fmt::write(&mut term, format_args!("Hello, {}", "world")).unwrap();
    let s = "Test string".clone();
    term.print(s);

    loop { }
}

#[panic_implementation]
#[no_mangle]
pub extern fn panic_impl(_pi: &PanicInfo) -> ! {
    loop { }
}
