import jwt
from starlette.requests import Request  # pyright: ignore[reportMissingImports]
from starlette.exceptions import HTTPException
from starlette import status
from starlette.middleware.base import BaseHTTPMiddleware  # pyright: ignore[reportMissingImports]
from typing import Optional

SECRET_KEY = "YOUR_SUPER_SECRET_JWT_KEY"  # Replace with app settings/env var
ALGORITHM = "HS256"

PUBLIC_PATHS = {
    "/docs",
    "/openapi.json",
    "/redoc",
    "/api/v1/auth/login",
    "/api/v1/auth/forgot-password",
}

class AuthMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        path = request.url.path
        
        # Skip public/unauthenticated endpoints
        if any(path.startswith(p) for p in PUBLIC_PATHS):
            return await call_next(request)

        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Missing or invalid authentication token"
            )

        token = auth_header.split(" ")[1]
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
            request.state.user = payload  # Attach decoded user payload to request
        except jwt.ExpiredSignatureError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token has expired"
            )
        except jwt.PyJWTError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Could not validate credentials"
            )

        return await call_next(request)