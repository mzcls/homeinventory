import os
from pathlib import Path
from typing import Optional
from fastapi import UploadFile
from dotenv import load_dotenv
import uuid
from PIL import Image
import io

load_dotenv()

UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

# Configuration for OSS (e.g., AWS S3 or Aliyun OSS)
# Set USE_OSS to "true" in your .env file to enable OSS storage
USE_OSS = os.getenv("USE_OSS", "false").lower() == "true"

# AWS S3 Configuration (example)
AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
AWS_REGION = os.getenv("AWS_REGION")
S3_BUCKET_NAME = os.getenv("S3_BUCKET_NAME")

# Aliyun OSS Configuration (example)
ALIYUN_ACCESS_KEY_ID = os.getenv("ALIYUN_ACCESS_KEY_ID")
ALIYUN_ACCESS_KEY_SECRET = os.getenv("ALIYUN_ACCESS_KEY_SECRET")
ALIYUN_ENDPOINT = os.getenv("ALIYUN_ENDPOINT")
ALIYUN_BUCKET_NAME = os.getenv("ALIYUN_BUCKET_NAME")


async def save_upload_file(upload_file: UploadFile, file_type: str) -> dict:
    """
    Saves an uploaded file, generates a thumbnail if it's an image,
    and returns a dictionary with full and thumbnail URLs.
    """
    file_extension = Path(upload_file.filename).suffix
    unique_name_base = str(uuid.uuid4())
    unique_filename = f"{unique_name_base}{file_extension}"
    
    urls = {"full_url": None, "thumb_url": None}

    if USE_OSS:
        # This part needs to be adapted for OSS, including thumbnail generation
        print("OSS is enabled but thumbnail generation for OSS is not implemented.")
        urls["full_url"] = f"https://your-oss-bucket.com/media/{unique_filename}"
        # For OSS, you might upload the thumbnail similarly and get another URL
        # urls["thumb_url"] = f"https://your-oss-bucket.com/media/{unique_name_base}_thumb.jpg"
    else:
        # Local storage logic
        file_path = UPLOAD_DIR / unique_filename
        file_contents = await upload_file.read()

        # Save the original file
        with open(file_path, "wb") as buffer:
            buffer.write(file_contents)
        urls["full_url"] = f"/uploads/{unique_filename}"

        # Generate and save a thumbnail if it's an image
        if file_type == "image":
            try:
                img = Image.open(io.BytesIO(file_contents))
                
                # Preserve transparency for PNGs
                if img.format == 'PNG':
                    thumb_ext = 'png'
                    save_format = 'PNG'
                else:
                    thumb_ext = 'jpg'
                    save_format = 'JPEG'
                    img = img.convert('RGB')

                thumb_filename = f"{unique_name_base}_thumb.{thumb_ext}"
                thumb_path = UPLOAD_DIR / thumb_filename
                
                thumb_width = 400
                w_percent = (thumb_width / float(img.size[0]))
                h_size = int((float(img.size[1]) * float(w_percent)))
                img.thumbnail((thumb_width, h_size))
                
                img.save(thumb_path, save_format, quality=85)
                urls["thumb_url"] = f"/uploads/{thumb_filename}"
            except Exception as e:
                print(f"Error generating thumbnail: {e}")
                urls["thumb_url"] = None # Fallback to no thumbnail

    return urls

def delete_upload_file(file_url: str):
    """
    Deletes a file from local storage.
    """
    if USE_OSS:
        # Placeholder for OSS deletion logic
        # e.g., s3.delete_object(Bucket=S3_BUCKET_NAME, Key=f"media/{filename}")
        print(f"OSS is enabled. Deleting {file_url} from OSS is not implemented.")
        return

    try:
        # The file_url is like /uploads/filename.jpg, we need to get the filename
        filename = os.path.basename(file_url)
        file_path = UPLOAD_DIR / filename
        if file_path.exists() and file_path.is_file():
            os.remove(file_path)
    except Exception as e:
        # Log the error, but don't crash the app
        print(f"Error deleting file {file_url}: {e}")
