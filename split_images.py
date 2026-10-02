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

split_image('assets/image/car.jpg', 'assets/image/car_left.jpg', 'assets/image/car_right.jpg')
split_image('assets/image/Theplane.jpg', 'assets/image/plane_left.jpg', 'assets/image/plane_right.jpg')
