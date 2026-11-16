import os, requests
from flask import Flask, request
app = Flask(__name__)
SID = os.environ.get('TWILIO_SID')
TOKEN = os.environ.get('TWILIO_TOKEN')
FROM = os.environ.get('SMS_FROM')
TO = os.environ.get('SMS_TO')

@app.post('/send')
def send():
    for a in request.get_json().get('alerts', []):
        if a.get('status') != 'firing':
            continue
        body = f"[{a['labels'].get('severity','?').upper()}] {a['labels'].get('alertname')} on {a['labels'].get('instance','?')}"
        print(f"SMS-BRIDGE: {body}", flush=True)
        if SID and TOKEN and FROM and TO:
            try:
                r = requests.post(f'https://api.twilio.com/2010-04-01/Accounts/{SID}/Messages.json',
                                  auth=(SID, TOKEN), data={'From': FROM, 'To': TO, 'Body': body[:300]}, timeout=10)
                print(f"SMS-BRIDGE: twilio status {r.status_code}", flush=True)
            except Exception as e:
                print(f"SMS-BRIDGE: twilio error {e}", flush=True)
    return 'ok'
