use std::fs::File;
use std::io::Write;

fn main() {
    let data = [0u8; 1024];
    for i in 0..1000 {
        let fname = format!("data/smallfile_{}.bin", i);
        let mut f = File::create(fname).unwrap();
        f.write_all(&data).unwrap();
    }
}
