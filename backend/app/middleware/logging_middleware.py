import time
import logging
from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware

logger = logging.getLogger("api_access")
logging.basicConfig(level=logging.INFO)

class LoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        start_time = time.time()
        
        response = await call_next(request)
        
        process_time = (time.time() - start_time) * 1000  # in ms
        client_host = request.client.host if request.client else "unknown"
        
        logger.info(
            f"[{request.method}] {request.url.path} - Status: {response.status_code} "
            f"- Latency: {process_time:.2f}ms - IP: {client_host}"
        )
        
        response.headers["X-Process-Time-MS"] = f"{process_time:.2f}"
        return response