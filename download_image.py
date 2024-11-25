import time
import requests
from PIL import Image
from io import BytesIO
import os
import base64
from pymongo import MongoClient

# MongoDB setup
mongo_client = MongoClient("mongodb://localhost:27017/")  # Replace with your MongoDB connection string
db = mongo_client["image_database"]  # Database name
collection = db["images"]  # Collection name

def download_image(url, save_path):
    """
    Download the image from the given URL and save it locally.
    """
    try:
        response = requests.get(url, stream=True)
        if response.status_code == 200:
            img = Image.open(BytesIO(response.content))
            img.save(save_path)
            print(f"Image saved to {save_path}")
            return save_path
        else:
            print(f"Failed to fetch image. Status code: {response.status_code}")
            return None
    except Exception as e:
        print(f"Error occurred: {e}")
        return None

def image_to_base64(image_path):
    """
    Convert an image file to a Base64 string.
    """
    try:
        with open(image_path, "rb") as image_file:
            encoded_string = base64.b64encode(image_file.read()).decode("utf-8")
        return encoded_string
    except Exception as e:
        print(f"Error encoding image to Base64: {e}")
        return None

def write_to_mongodb(image_id, image_url, base64_image):
    """
    Write the image data to MongoDB.
    """
    try:
        document = {
            "id": image_id,
            "url": image_url,
            "image_base64": base64_image,
        }
        collection.insert_one(document)
        print(f"Inserted document into MongoDB: ID={image_id}")
    except Exception as e:
        print(f"Error writing to MongoDB: {e}")

def capture_images(url, folder, interval, duration):
    """
    Periodically capture and save images from a real-time URL.
    
    Args:
    - url: Image URL to fetch.
    - folder: Directory to save images.
    - interval: Time interval (in seconds) between each capture.
    - duration: Total duration (in seconds) to capture images.
    """
    start_time = time.time()
    capture_count = 0

    while (time.time() - start_time) < duration:
        timestamp = int(time.time())
        image_id = f"image_{timestamp}"
        save_path = f"{folder}/{image_id}.jpg"
        saved_path = download_image(url, save_path)

        if saved_path:
            # Convert to Base64 and write to MongoDB
            base64_image = image_to_base64(saved_path)
            if base64_image:
                write_to_mongodb(image_id, url, base64_image)

        capture_count += 1
        time.sleep(interval)

    print(f"Captured {capture_count} images in {duration} seconds.")

# Example usage:
image_url = "https://example.com/real-time-image.jpg"  # Replace with the live image URL
output_folder = "images"  # Directory to save images
capture_interval = 5  # Capture every 5 seconds
capture_duration = 60  # Capture images for 1 minute

# Ensure the output folder exists
os.makedirs(output_folder, exist_ok=True)

# Start capturing images
capture_images(image_url, output_folder, capture_interval, capture_duration)
