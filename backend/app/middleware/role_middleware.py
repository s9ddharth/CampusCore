from fastapi import Request, HTTPException, status
from typing import List, Callable

def require_roles(allowed_roles: List[str]):
    """
    Dependency/Decorator helper to enforce Role-Based Access Control (RBAC).
    Usage on endpoints:
        @router.get("/admin/metrics", dependencies=[Depends(require_roles(["ADMIN"]))])
    """
    async def role_checker(request: Request):
        user = getattr(request.state, "user", None)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User identity not found"
            )
        
        user_role = user.get("role")
        if user_role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access denied. Requires one of roles: {allowed_roles}"
            )
        return user

    return role_checker