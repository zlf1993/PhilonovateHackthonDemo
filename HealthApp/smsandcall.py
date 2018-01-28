from urllib.parse import urlencode
from twilio.rest import Client
from twilio import twiml
from flask import Response

# Import the Twilio Python Client.
import sys
from twilio.twiml.messaging_response import MessagingResponse
from flask import Flask, request

app = Flask(__name__)
@app.route('/', methods=['GET', 'POST'])

def hello():
    xml = '<Response><Say>Hello world.</Say></Response>'
    return Response(xml, mimetype='text/xml')
# Set your account ID and authentication token.
account_sid = "AC7c84010c68c75cd6795daca8d1ca9fad"
auth_token = "00482857181b6576bbdaacfb41b0c026"

#phnoe call url
fixedurl="http://twimlets.com/holdmusic?Bucket=com.twilio.music.ambient"

# The number of the phone initiating the the call.
# This should either be a Twilio number or a number that you've verified
from_number = "+12897993609"

# The number of the phone receiving call.
#to_number = str(sys.argv[1])

#The statement message
#message = str(sys.argv[2])

# Use the Twilio-provided site for the TwiML response.
url = "http://twimlets.com/message?"

# Initialize the Twilio client.
client = Client(account_sid, auth_token)

# Make the call.
def messagesend(to_number, message):
    messaged = client.messages.create(to=to_number, from_=from_number, body = message)
                           
def callsend(to_number, message):
    client.calls.create(to=to_number,
                           from_=from_number,
                           url=url + urlencode({'Message': message}))

