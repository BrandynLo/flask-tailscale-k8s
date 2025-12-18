from flask import Flask, jsonify
import os
from datetime import datetime


app = Flask(__name__)

@app.route('/')
def home():
    return f"""
    <h1>It is now running</h1>
    <p>Flask Configured</p>
    <p>Pod: <b>{os.uname().nodename}</b></p>
    <p>Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
    <hr>
    <pre>{open('/proc/cpuinfo').read().splitlines()[4]}</pre>
    """
#Prints out configuration of Podname and current time/date to verify uptime is synced and live.
#Reads out current container virtual hardware info

@app.route('/health')
def health():
    return jsonify(status="healthy", pod=os.uname().nodename)
#Checks if pod status is up. For troubleshooting only.


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
#Listens on port 8080 
#Open to all on 0.0.0.0 for public access on internet.
