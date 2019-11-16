use core::mem;
use core::fmt;
use core::ptr;

const VGA_BASE: *mut u16 = 0xb8000 as _;

pub struct Terminal {
    pub base: &'static mut [u16; 2000],

    pub width: usize,
    pub height: usize,

    pub x: usize,
    pub y: usize,
}

pub fn new() -> Terminal {
    Terminal {
        base: unsafe {
            mem::transmute::<*mut u16, &mut [u16; 2000]>(VGA_BASE)
        },

        width: 80,
        height: 25,

        x: 0,
        y: 0,
    }
}

impl Terminal {
    pub fn print(&mut self, string: &str) {
        let pos = self.y*self.width + self.x;
        self.update_buffer(pos, string);

        self.y += string.len() / self.width;
        self.x += string.len() % self.width;
    }

    pub fn set_pos(&mut self, x: usize, y: usize) {
        self.x = x;
        self.y = y;
    }

    pub fn update_buffer(&mut self, pos: usize, string: &str) {
        for (i, c) in string.bytes().enumerate() {
            self.base[pos + i] = 0x0700 | c as u16;
        };
    }

    pub fn clear(&mut self) {
        unsafe {
            ptr::write_bytes(self.base.as_mut_ptr(), 0, 2000);
        }
    }
}

impl fmt::Write for Terminal {
    fn write_str(&mut self, s: &str) -> fmt::Result {
        self.print(s);
        Ok(())
    }
}
