from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from .database import engine, Base
from .models import user, warehouse, user_warehouse, item, item_media, category
from .routes import auth, warehouse, item, media, category as category_router, admin
from .utils.settings import settings # Import settings
from .schemas.response import ResponseModel

# Create all tables in the database
Base.metadata.create_all(bind=engine)

app = FastAPI()

# Custom exception handler for HTTPException
@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "status": "error",
            "data": None,
            "message": exc.detail
        },
    )

# Mount static files directory for serving uploaded content
app.mount("/uploads", StaticFiles(directory=settings.upload_dir), name="uploads")

app.include_router(auth.router, prefix="/auth", tags=["Auth"])
app.include_router(warehouse.router, prefix="/warehouses", tags=["Warehouses"])
app.include_router(item.router, prefix="/items", tags=["Items"])
app.include_router(media.router, prefix="/media", tags=["Media"])
app.include_router(category_router.router, prefix="/categories", tags=["Categories"])
app.include_router(admin.router) # Include admin router

@app.get("/", response_model=ResponseModel)
def read_root():
    return ResponseModel(message="Welcome to Home Inventory API")
