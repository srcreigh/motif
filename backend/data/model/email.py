
from google.appengine.ext import ndb

class Email(ndb.Model):
    user_id 	 = ndb.StringProperty()
    created_time = ndb.DateTimeProperty(auto_now_add=True)
    subject 	 = ndb.StringProperty()

    @classmethod
    def query_emails(cls, user_key):
        return cls.query(ancestor=user_key)
