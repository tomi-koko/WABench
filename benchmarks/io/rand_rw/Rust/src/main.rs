use std::fs::OpenOptions;
use std::io::{Seek, SeekFrom, Write};
use rand::Rng;

fn main() {
    let mut file = OpenOptions::new().read(true).write(true).create(true).open("randio.bin").unwrap();
    file.set_len(104857600).unwrap();
    let mut buf = [0u8; 4096];
    let mut rng = rand::thread_rng();
    for _ in 0..10000 {
        let offset = rng.gen_range(0..(104857600 / 4096)) * 4096;
        file.seek(SeekFrom::Start(offset as u64)).unwrap();
        file.write_all(&buf).unwrap();
    }
}
