import hashlib, hmac, os

def hash_password(password: str) -> str:
    salt=os.urandom(16)
    digest=hashlib.pbkdf2_hmac('sha256',password.encode(),salt,310000)
    return f"pbkdf2_sha256$310000${salt.hex()}${digest.hex()}"

def verify_password(password: str, encoded: str) -> bool:
    try:
        algo, rounds, salt_hex, digest_hex=encoded.split('$')
        if algo!='pbkdf2_sha256': return False
        check=hashlib.pbkdf2_hmac('sha256',password.encode(),bytes.fromhex(salt_hex),int(rounds))
        return hmac.compare_digest(check.hex(),digest_hex)
    except Exception: return False
