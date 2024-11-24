import time
import requests
from PIL import Image
from io import BytesIO

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
        else:
            print(f"Failed to fetch image. Status code: {response.status_code}")
    except Exception as e:
        print(f"Error occurred: {e}")

def capture_images(url, folder, interval, duration, id):
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
        save_path = f"{folder}/image_{id}_{timestamp}.jpg"
        download_image(url, save_path)
        capture_count += 1
        time.sleep(interval)

    print(f"Captured {capture_count} images in {duration} seconds.")

# Example usage:
id  = "65e0552f6b18080018db6647"
image_url = f"http://giaothong.hochiminhcity.gov.vn/render/ImageHandler.ashx?id={id}"  # Replace with the live image URL
output_folder = f"images/{id}"  # Directory to save images
capture_interval = 3  # Capture every 5 seconds
capture_duration = 60*60*24  # Capture images for 1 minute

# Ensure the output folder exists
import os
os.makedirs(output_folder, exist_ok=True)

# Start capturing images
capture_images(image_url, output_folder, capture_interval, capture_duration, id)
