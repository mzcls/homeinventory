from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import timedelta

from ..database import get_db
from ..schemas.user import UserCreate, UserResponse
from ..schemas.token import Token
from ..schemas.response import ResponseModel # Import ResponseModel
from ..services import user as user_service
from ..utils.security import verify_password
from ..utils.auth import create_access_token, decode_access_token, ACCESS_TOKEN_EXPIRE_MINUTES
from ..models.user import User

router = APIRouter()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    payload = decode_access_token(token)
    if payload is None:
        raise credentials_exception
    username: str = payload.get("sub")
    if username is None:
        raise credentials_exception
    user = user_service.get_user_by_username(db, username=username)
    if user is None:
        raise credentials_exception
    return user

async def get_current_admin_user(current_user: User = Depends(get_current_user)):
    if not current_user.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Operation forbidden: Not an administrator"
        )
    return current_user

@router.post("/register", response_model=ResponseModel[UserResponse])
def register_user(user: UserCreate, db: Session = Depends(get_db)):
    # Email is now optional, so no need to check if it's already registered
    # db_user = user_service.get_user_by_email(db, email=user.email)
    # if db_user:
    #     raise HTTPException(status_code=400, detail="Email already registered")
    db_user = user_service.get_user_by_username(db, username=user.username)
    if db_user:
        raise HTTPException(status_code=400, detail="Username already taken")
    created_user = user_service.create_user(db=db, user=user)
    return ResponseModel(data=created_user, message="User registered successfully")

@router.post("/token", response_model=ResponseModel[Token]) # Use ResponseModel
def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = user_service.get_user_by_username(db, username=form_data.username)
    if not user or not verify_password(form_data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    return ResponseModel(data={"access_token": access_token, "token_type": "bearer"}, message="Login successful") # Wrap response

@router.get("/users/me", response_model=ResponseModel[UserResponse]) # Use ResponseModel
async def read_users_me(current_user: User = Depends(get_current_user)):
    return ResponseModel(data=current_user, message="User information retrieved successfully") # Wrap response