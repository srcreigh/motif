package me.motifapp.android;

import android.app.Application;
import android.util.Log;

import com.parse.Parse;
import com.parse.ParseException;
import com.parse.ParsePush;
import com.parse.SaveCallback;

public class MotifApp extends Application {
    @Override
    public void onCreate() {
        initParse();
    }

    private void initParse() {
        final String APP_ID = getString(R.string.parse_app_id);
        final String CLIENT_KEY = getString(R.string.parse_client_key);
        Parse.initialize(this, APP_ID, CLIENT_KEY);
        ParsePush.subscribeInBackground("", new SaveCallback() {
            @Override
            public void done(ParseException e) {
                if (e == null) {
                    Log.d("com.parse.push", "successfully subscribed to the broadcast channel.");
                } else {
                    Log.e("com.parse.push", "failed to subscribe for push", e);
                }
            }
        });
    }
}
