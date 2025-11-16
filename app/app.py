"""
Flask application serving Lorem Ipsum content with secure Cloud Storage integration.
"""

from flask import Flask, render_template, jsonify
from google.cloud import storage
from datetime import timedelta
import os

app = Flask(__name__)

BUCKET_NAME = os.environ.get('STORAGE_BUCKET_NAME', 'lorem-ipsum-assets')
IMAGE_BLOB_NAME = os.environ.get('IMAGE_BLOB_NAME', 'lorem-ipsum.jpg')
SIGNED_URL_EXPIRATION = timedelta(hours=1)


def generate_signed_url(bucket_name: str, blob_name: str) -> str:
    """
    Generate a signed URL for accessing a private Cloud Storage object.
    
    Args:
        bucket_name: Name of the GCS bucket
        blob_name: Name of the object in the bucket
    
    Returns:
        Signed URL string valid for SIGNED_URL_EXPIRATION
    """
    try:
        storage_client = storage.Client()
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(blob_name)

        url = blob.generate_signed_url(
            version="v4",
            expiration=SIGNED_URL_EXPIRATION,
            method="GET"
        )

        return url
    except Exception as e:
        app.logger.error(f"Error generating signed URL: {e}")
        return None


@app.route('/')
def index():
    """
    Render the main page with Lorem Ipsum content and image.
    """
    # Using public URL for access to the image
    image_url = f"https://storage.googleapis.com/{BUCKET_NAME}/{IMAGE_BLOB_NAME}"

    return render_template('index.html', image_url=image_url)


@app.route('/health')
def health():
    """
    Health check endpoint for Cloud Run.
    """
    return jsonify({
        'status': 'healthy',
        'bucket': BUCKET_NAME,
        'image': IMAGE_BLOB_NAME
    }), 200


@app.route('/api/image-url')
def get_image_url():
    """
    API endpoint to get a fresh signed URL for the image.
    Useful for client-side refresh if URL expires.
    """
    image_url = generate_signed_url(BUCKET_NAME, IMAGE_BLOB_NAME)

    if image_url:
        return jsonify({
            'url': image_url,
            'expires_in_seconds': int(SIGNED_URL_EXPIRATION.total_seconds())
        }), 200
    else:
        return jsonify({
            'error': 'Could not generate signed URL'
        }), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=False)