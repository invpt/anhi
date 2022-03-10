use bcrypt::BcryptError;

const BCRYPT_ROUNDS: u32 = 10;

pub fn hash_secret(secret: String) -> String {
    bcrypt::hash(sha256::digest(secret), BCRYPT_ROUNDS).expect("Fatal error during BCrypt hashing")
}

pub fn verify_secret(secret: String, hash: String) -> Result<bool, anyhow::Error> {
    match bcrypt::verify(sha256::digest(secret), &hash) {
        Ok(result) => Ok(result),
        Err(error) => match error {
            BcryptError::InvalidPrefix(_)
            | BcryptError::InvalidHash(_)
            | BcryptError::InvalidBase64(_) => Err(anyhow::Error::new(error)),
            _ => panic!("Fatal error during BCrypt verification"),
        },
    }
}