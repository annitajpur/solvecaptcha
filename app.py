from flask import Flask, request, jsonify
from flask_cors import CORS
import pytesseract
import base64
from PIL import Image
import io

app = Flask(__name__)
CORS(app)

# Use default tesseract path (Termux will use binary in $PATH)
@app.route('/solve-truecaptcha', methods=['POST'])
def solve_captcha():
    try:
        data = request.get_json()
        if not data or 'imageContent' not in data:
            return jsonify({'error': 'Missing imageContent'}), 400

        image_data = base64.b64decode(data['imageContent'])
        image = Image.open(io.BytesIO(image_data)).convert('L')
        raw_text = pytesseract.image_to_string(image)
        allowed_chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
        cleaned_text = ''.join(c for c in raw_text if c in allowed_chars)
        return jsonify({'result': cleaned_text})

    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
