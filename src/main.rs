extern crate sodiumoxide;
use sodiumoxide::crypto::secretbox;

fn main() {
    let key = secretbox::gen_key();
    let nonce = secretbox::gen_nonce();
    let plaintext = b"some data";
    let ciphertext = secretbox::seal(plaintext, &nonce, &key);
    let their_plaintext = secretbox::open(&ciphertext, &nonce, &key).unwrap();
    assert!(plaintext == &their_plaintext[..]);
    println!("Plaintext: {:?}", &plaintext);
    println!("Decrypted Plaintext: {:?}", &their_plaintext);
}
