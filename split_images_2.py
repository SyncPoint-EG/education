from PIL import Image
import os

def split_image(input_path, output_left, output_right):
    if not os.path.exists(input_path):
        print(f"File not found: {input_path}")
        return
    img = Image.open(input_path)
    width, height = img.size
    mid = width // 2
    left = img.crop((0, 0, mid, height))
    right = img.crop((mid, 0, width, height))
    left.save(output_left)
    right.save(output_right)
    print(f"Saved {output_left} and {output_right}")

split_image('assets/image/Theship.jpg', 'assets/image/ship_left.jpg', 'assets/image/ship_right.jpg')
split_image('assets/image/Ambulance.jpg', 'assets/image/ambulance_left.jpg', 'assets/image/ambulance_right.jpg')
