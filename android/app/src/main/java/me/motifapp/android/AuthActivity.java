package me.motifapp.android;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;

import com.parse.ParseInstallation;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicHeader;
import org.apache.http.protocol.HTTP;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;

import oauth.signpost.commonshttp.CommonsHttpOAuthConsumer;

public class AuthActivity extends Activity implements View.OnClickListener {
    private static final String TAG = "AuthActivity";
    private Button mLogInButton;

    private boolean mDidPressLogIn = false;
    private String mBrowserRedirectUrl = null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Intent intent = getIntent();
        if (!MotifApp.isAuthenticated(this)) {
            final String scheme = intent.getScheme();
            if (!TextUtils.isEmpty(scheme) && scheme.equals("motif")) {
                Uri uri = intent.getData();
                final String token = uri.getQueryParameter("contextio_token");
                getUserInfo(this, token);
            } else {
                setContentView(R.layout.activity_auth);
                // Set up the login button
                mLogInButton = (Button)findViewById(R.id.log_in_button);
                mLogInButton.setOnClickListener(this);
                getBrowserRedirectUrl(this);
            }
        } else {
            // TODO go to settings
        }
    }

    @Override
    public void onNewIntent(Intent intent) {
        setIntent(intent);

    }

    @Override
    public void onClick(View v) {
        if (v == mLogInButton) {
            mLogInButton.setEnabled(false);
            mDidPressLogIn = true;
            showOAuthWhenReady();
        }
    }

    private void getBrowserRedirectUrl(Context context) {
        final String CONSUMER_KEY = context.getString(R.string.contextio_client_id);
        final String CONSUMER_SECRET = context.getString(R.string.contextio_client_secret);
        final String URL = "https://api.context.io/lite/connect_tokens";
        final String CALLBACK = "motif://";

        new AsyncTask<Void, Void, Void>() {
            @Override
            protected Void doInBackground(Void... no) {
                CommonsHttpOAuthConsumer consumer = new CommonsHttpOAuthConsumer(CONSUMER_KEY,
                        CONSUMER_SECRET);
                try {
                    HttpClient client = new DefaultHttpClient();

                    HttpPost post = new HttpPost(URL);
                    String payload = String.format("callback_url=%s", Uri.encode(CALLBACK));
                    StringEntity entity = new StringEntity(payload, HTTP.UTF_8);
                    entity.setContentType(new BasicHeader(HTTP.CONTENT_TYPE, "application/x-www-form-urlencoded"));
                    post.setEntity(entity);

                    consumer.sign(post);

                    HttpResponse resp = client.execute(post);
                    JSONObject obj = new JSONObject(convertStreamToString(resp.getEntity().getContent()));
                    mBrowserRedirectUrl = obj.getString("browser_redirect_url");
                    showOAuthWhenReady();
                } catch (Exception e) {
                    Log.i(TAG, "exception", e);
                }

                return null;
            }
        }.execute();
    }

    private void getUserInfo(Context context, final String contextioToken) {
        final String CONSUMER_KEY = context.getString(R.string.contextio_client_id);
        final String CONSUMER_SECRET = context.getString(R.string.contextio_client_secret);
        final String URL = String.format("https://api.context.io/lite/connect_tokens/%s",
                contextioToken);

        new AsyncTask<Void, Void, Void>() {
            @Override
            protected Void doInBackground(Void... no) {
                CommonsHttpOAuthConsumer consumer = new CommonsHttpOAuthConsumer(CONSUMER_KEY,
                        CONSUMER_SECRET);
                try {
                    HttpClient client = new DefaultHttpClient();

                    HttpGet req = new HttpGet(URL);
                    consumer.sign(req);
                    HttpResponse resp = client.execute(req);
                    onAuthFinished(convertStreamToString(resp.getEntity().getContent()));
                } catch (Exception e) {
                    Log.i(TAG, "exception", e);
                }

                return null;
            }
        }.execute();
    }

    private static String convertStreamToString(java.io.InputStream is) {
        java.util.Scanner s = new java.util.Scanner(is).useDelimiter("\\A");
        return s.hasNext() ? s.next() : "";
    }

    private void showOAuthWhenReady() {
        if (mDidPressLogIn && mBrowserRedirectUrl != null) {
            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.setData(Uri.parse(mBrowserRedirectUrl));
            startActivity(intent);
        }
    }

    private void onAuthFinished(String resp) {
        try {
            JSONObject object = new JSONObject(resp);
            JSONObject user = object.getJSONObject("user");
            ParseInstallation installation = ParseInstallation.getCurrentInstallation();
            installation.put("user_id", user.getString("id"));
            installation.saveInBackground();

        } catch (JSONException ignored) {}
    }
}
