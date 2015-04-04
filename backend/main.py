from flask import Flask, request
from data.model.email import Email
from google.appengine.ext import ndb
import json
app = Flask(__name__)
app.config['DEBUG'] = True

# Note: We don't need to call run() since our application is embedded within
# the App Engine WSGI application server.


@app.route('/')
def hello():
    return 'Hello World!'

@app.route('/user/<user_id>/email_webhook', methods=['POST'])
def receive_email(user_id):
    req_json = request.get_json()
    user_key = ndb.Key('Emails', user_id);
    email = Email(parent=user_key,
                  user_id=user_id,
                  subject=req_json['message_data']['subject'])
    email.put()
    return json.dumps({'result':'success'})

@app.route('/user/<user_id>/emails', methods=['GET'])
def emails(user_id):
    user_key = ndb.Key('Emails', user_id)
    print user_key
    emails = Email.query_emails(user_key)
    resp_body = '<ul>'
    for email in emails:
        resp_body = '%s<li>%s</li>' % (resp_body, email.subject)
    resp_body = '%s</ul>' % resp_body
    return resp_body

@app.errorhandler(404)
def page_not_found(e):
    """Return a custom 404 error."""
    return 'Sorry, nothing at this URL.', 404
