import uuid
from flask import Flask, request, jsonify, send_file
import os
import cv2
import numpy as np

app = Flask(__name__)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
UPLOAD_DIR = os.path.join(BASE_DIR, "uploads")
os.makedirs(UPLOAD_DIR, exist_ok=True)

def cartoonify_image(img_path):
    img = cv2.imread(img_path)
    if img is None:
        raise ValueError("Image not loaded properly")

    img = cv2.resize(img, (600, 600))
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    gray = cv2.medianBlur(gray, 5)

    edges = cv2.adaptiveThreshold(
        gray, 255,
        cv2.ADAPTIVE_THRESH_MEAN_C,
        cv2.THRESH_BINARY, 9, 9
    )

    color = cv2.bilateralFilter(img, 9, 300, 300)
    cartoon = cv2.bitwise_and(color, color, mask=edges)

    base, ext = os.path.splitext(img_path)
    cartoon_path = base + "_cartoon.jpg"
    cv2.imwrite(cartoon_path, cartoon)
    return cartoon_path

@app.route('/cartoonify', methods=['POST'])
def upload_image():
    if 'image' not in request.files:
        return jsonify({'error': 'No image uploaded'}), 400

    file = request.files['image']
    if file.filename == '':
        return jsonify({'error': 'No image selected'}), 400

    # Unique filename
    unique_name = str(uuid.uuid4())
    original_path = os.path.join(UPLOAD_DIR, f"{unique_name}.jpg")
    file.save(original_path)

    print(f"[INFO] Received image saved to: {original_path}")

    cartoon_path = cartoonify_image(original_path)
    print(f"[INFO] Cartoon image saved to: {cartoon_path}")

    return send_file(cartoon_path, mimetype='image/jpeg')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
