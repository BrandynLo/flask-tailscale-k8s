from flask import Flask, jsonify
import os
from datetime import datetime

app = Flask(__name__)

@app.route('/')
def home():
    return f"""
    <h1>It actually works!</h1>
    <p>Flask running on IBM Cloud free Kubernetes</p>
    <p>Pod: <b>{os.uname().nodename}</b></p>
    <p>Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
    <hr>
    <pre>{open('/proc/cpuinfo').read().splitlines()[4]}</pre>
    """

@app.route('/health')
def health():
    return jsonify(status="healthy", pod=os.uname().nodename)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
