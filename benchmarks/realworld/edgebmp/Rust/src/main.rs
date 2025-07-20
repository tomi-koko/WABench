use std::fs::File;
use std::io::{Read, Seek, SeekFrom, Write};
use std::time::Instant;

fn clamp(val: i32, min: i32, max: i32) -> i32 {
    if val < min {
        min
    } else if val > max {
        max
    } else {
        val
    }
}

fn main() -> std::io::Result<()> {
    let args: Vec<String> = std::env::args().collect();
    if args.len() != 2 {
        println!("Usage: {} <image.bmp>", args[0]);
        return Ok(());
    }

    let mut fp = File::open(&args[1])?;

    // Read BITMAPFILEHEADER
    let mut file_header = [0u8; 14];
    fp.read_exact(&mut file_header)?;
    let bf_type = u16::from_le_bytes([file_header[0], file_header[1]]);
    let bf_off_bits = u32::from_le_bytes([file_header[10], file_header[11], file_header[12], file_header[13]]);

    if bf_type != 0x4D42 {
        println!("Only BMP supported.");
        return Ok(());
    }

    // Read BITMAPINFOHEADER
    let mut info_header = [0u8; 40];
    fp.read_exact(&mut info_header)?;
    let bi_width = i32::from_le_bytes([info_header[4], info_header[5], info_header[6], info_header[7]]);
    let bi_height = i32::from_le_bytes([info_header[8], info_header[9], info_header[10], info_header[11]]);
    let bi_bit_count = u16::from_le_bytes([info_header[14], info_header[15]]);

    if bi_bit_count != 24 {
        println!("Only 24-bit BMP supported.");
        return Ok(());
    }

    let width = bi_width as usize;
    let height = bi_height.abs() as usize;
    let padding = (4 - (width * 3) % 4) % 4;

    let mut gray = vec![0u8; width * height];
    fp.seek(SeekFrom::Start(bf_off_bits as u64))?;

    for y in (0..height).rev() {
        for x in 0..width {
            let mut bgr = [0u8; 3];
            fp.read_exact(&mut bgr)?;
            let gray_val = 0.299 * f64::from(bgr[2]) + 
                          0.587 * f64::from(bgr[1]) + 
                          0.114 * f64::from(bgr[0]);
            gray[y * width + x] = gray_val as u8;
        }
        fp.seek(SeekFrom::Current(padding as i64))?;
    }

    // Sobel Kernel
    let gx = [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]];
    let gy = [[1, 2, 1], [0, 0, 0], [-1, -2, -1]];

    let start = Instant::now();

    let mut output = vec![0u8; width * height];
    for y in 1..height-1 {
        for x in 1..width-1 {
            let mut sum_x = 0i32;
            let mut sum_y = 0i32;
            for dy in -1..=1 {
                for dx in -1..=1 {
                    let val = gray[((y as i32 + dy) as usize) * width + ((x as i32 + dx) as usize)] as i32;
                    sum_x += val * gx[(dy + 1) as usize][(dx + 1) as usize];
                    sum_y += val * gy[(dy + 1) as usize][(dx + 1) as usize];
                }
            }
            let mag = (sum_x.pow(2) + sum_y.pow(2)) as f64;
            output[y * width + x] = clamp(mag.sqrt() as i32, 0, 255) as u8;
        }
    }

    let duration = start.elapsed();
    println!("Edge detection time: {:.6} seconds", duration.as_secs_f64());

    // Optional: write output.raw
    let mut out_file = File::create("output.raw")?;
    out_file.write_all(&output)?;

    Ok(())
}
