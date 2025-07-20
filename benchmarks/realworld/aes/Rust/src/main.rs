use std::fs;
use std::time::Instant;

const BLOCK_SIZE: usize = 16;
const NB: usize = 4;
const NK: usize = 4;
const NR: usize = 10;

static SBOX: [u8; 256] = [
    0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
    0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
    0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
    0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
    0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
    0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
    0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
    0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
    0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
    0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
    0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
    0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
    0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
    0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
    0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
    0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
];

static RCON: [u8; 11] = [0x00, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1B, 0x36];

fn key_expansion(round_key: &mut [u8; 176], key: &[u8; 16]) {
    for i in 0..NK {
        round_key[i*4] = key[i*4];
        round_key[i*4+1] = key[i*4+1];
        round_key[i*4+2] = key[i*4+2];
        round_key[i*4+3] = key[i*4+3];
    }

    for i in NK..(NB * (NR + 1)) {
        let mut temp = [
            round_key[(i-1)*4],
            round_key[(i-1)*4+1],
            round_key[(i-1)*4+2],
            round_key[(i-1)*4+3],
        ];

        if i % NK == 0 {
            let t = temp[0];
            temp[0] = SBOX[temp[1] as usize];
            temp[1] = SBOX[temp[2] as usize];
            temp[2] = SBOX[temp[3] as usize];
            temp[3] = SBOX[t as usize];
            temp[0] ^= RCON[i / NK];
        }

        for j in 0..4 {
            round_key[i*4+j] = round_key[(i-NK)*4+j] ^ temp[j];
        }
    }
}

fn sub_bytes(state: &mut [u8; 16]) {
    for byte in state.iter_mut() {
        *byte = SBOX[*byte as usize];
    }
}

fn shift_rows(state: &mut [u8; 16]) {
    let temp = state[1];
    state[1] = state[5];
    state[5] = state[9];
    state[9] = state[13];
    state[13] = temp;

    let temp = state[2];
    state[2] = state[10];
    state[10] = temp;

    let temp = state[6];
    state[6] = state[14];
    state[14] = temp;

    let temp = state[3];
    state[3] = state[15];
    state[15] = state[11];
    state[11] = state[7];
    state[7] = temp;
}

fn xtime(x: u8) -> u8 {
    (x << 1) ^ (((x >> 7) & 1) * 0x1b)
}

fn mix_columns(state: &mut [u8; 16]) {
    let mut tmp = [0u8; 16];

    for i in 0..4 {
        let idx = i * 4;
        tmp[idx] = xtime(state[idx]) ^ xtime(state[idx+1]) ^ state[idx+1] ^ state[idx+2] ^ state[idx+3];
        tmp[idx+1] = state[idx] ^ xtime(state[idx+1]) ^ xtime(state[idx+2]) ^ state[idx+2] ^ state[idx+3];
        tmp[idx+2] = state[idx] ^ state[idx+1] ^ xtime(state[idx+2]) ^ xtime(state[idx+3]) ^ state[idx+3];
        tmp[idx+3] = xtime(state[idx]) ^ state[idx] ^ state[idx+1] ^ state[idx+2] ^ xtime(state[idx+3]);
    }

    state.copy_from_slice(&tmp);
}

fn add_round_key(state: &mut [u8; 16], round_key: &[u8; 176], round: usize) {
    for i in 0..16 {
        state[i] ^= round_key[round * NB * 4 + i];
    }
}

fn aes128_ecb_encrypt(input: &[u8; 16], key: &[u8; 16]) -> [u8; 16] {
    let mut state = *input;
    let mut round_key = [0u8; 176];
    key_expansion(&mut round_key, key);

    add_round_key(&mut state, &round_key, 0);

    for round in 1..NR {
        sub_bytes(&mut state);
        shift_rows(&mut state);
        mix_columns(&mut state);
        add_round_key(&mut state, &round_key, round);
    }

    sub_bytes(&mut state);
    shift_rows(&mut state);
    add_round_key(&mut state, &round_key, NR);

    state
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    if args.len() != 2 {
        println!("Usage: {} <file>", args[0]);
        std::process::exit(1);
    }

    let data = fs::read(&args[1]).expect("Failed to read file");
    let fsize = data.len();
    let padded = ((fsize + BLOCK_SIZE - 1) / BLOCK_SIZE) * BLOCK_SIZE;

    let mut input = vec![0u8; padded];
    input[..fsize].copy_from_slice(&data);

    let mut output = vec![0u8; padded];
    let key = [0u8; 16]; // All zero key

    let start = Instant::now();
    for i in (0..padded).step_by(BLOCK_SIZE) {
        let block = <&[u8; 16]>::try_from(&input[i..i+BLOCK_SIZE]).unwrap();
        let encrypted = aes128_ecb_encrypt(block, &key);
        output[i..i+BLOCK_SIZE].copy_from_slice(&encrypted);
    }
    let duration = start.elapsed();

    println!("AES encryption time: {:.6} sec ({:.2} MB)", 
        duration.as_secs_f64(),
        padded as f64 / (1024.0 * 1024.0)
    );

    fs::write("enc_output.bin", &output).expect("Failed to write output file");
}
