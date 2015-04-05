from flask import Flask, request
from google.appengine.ext import ndb
from secrets import client_key, client_secret
from requests_oauthlib import OAuth1
import requests
import json
import urlparse
import urllib
app = Flask(__name__)
app.config['DEBUG'] = True

BASE_URL = 'http://motif-905.appspot.com'

@app.route('/user/<user_id>/on_create', methods=['POST'])
def create_user(user_id):
    # request a plain ol' webhook for this user
    params = {
        'callback_url':       '%s/user/%s/on_receive' % (BASE_URL, user_id),
        'failure_notif_url' : '%s/user/%s/on_fail'    % (BASE_URL, user_id)
    }
    params = urllib.urlencode(params)
    url = 'https://api.context.io/lite/users/%s/webhooks' % user_id
    return requests.post(url, auth=oauth(), data=params).text

@app.route('/user/<user_id>/on_fail', methods=['POST'])
def webhook_fail(user_id):
    return json.dumps({'error':'unimplemented'})

@app.route('/user/<user_id>/on_receive', methods=['POST'])
def receive_email(user_id):
    req_json = request.get_json()
    url = 'https://api.parse.com/1/push'
    payload = {
        'where': {
            'user_id': user_id                    
        },
        'data': {
            'alert': req_json['message_data']['subject']
        }
    }
    headers = {
        'Content-Type': 'application/json',
        'X-Parse-Application-Id': '4q8F1iczUazaKPIoUY0QXAjJDHxMZv70M7ebnEIr',
        'X-Parse-REST-API-Key': '9ZnWPfdckyxvBT23QJXQkLJXYE38vGRgNmj6w03p'
    }
    r = requests.post(url, headers=headers, data=json.dumps(payload))
    return r.text

@app.errorhandler(404)
def page_not_found(e):
    """Return a custom 404 error."""
    return 'Sorry, nothing at this URL.', 404

def oauth():
    return OAuth1(client_key, client_secret, '', '', 
                  signature_type='auth_header')