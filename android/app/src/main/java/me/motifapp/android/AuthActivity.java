package me.motifapp.android;

import android.app.Activity;
import android.content.Context;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;

import com.android.volley.NetworkResponse;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonRequest;

import java.util.HashMap;
import java.util.Map;

import me.motifapp.android.network.BaseOAuthRequest;
import me.motifapp.android.network.NetworkManager;

public class AuthActivity extends Activity implements View.OnClickListener {
    private static final String TAG = "AuthActivity";
    private Button mLogInButton;

    private boolean mDidPressLogIn = false;
    private String mBrowserRedirectUrl = null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (MotifApp.isAuthenticated(this)) {
            // Open the settings activity
        } else {
            setContentView(R.layout.activity_auth);

            // Set up the login button
            mLogInButton = (Button)findViewById(R.id.log_in_button);
            mLogInButton.setOnClickListener(this);

            getBrowserRedirectUrl(this);
        }
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
        final String URL = "https://api.context.io/lite/connect_tokens";
        final String CALLBACK = "motif://";
        final String CLIENT_ID = context.getString(R.string.contextio_client_id);
        final String CLIENT_SECRET = context.getString(R.string.contextio_client_secret);
        final JsonRequest<Object> request = new BaseOAuthRequest<Object>(Request.Method.POST,
                URL, null, CLIENT_ID, CLIENT_SECRET,
                new Response.Listener<Object>() {
                    @Override
                    public void onResponse(Object o) {
                        // TODO
                        Log.i(TAG, "success");
                    }
                },
                new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError volleyError) {
                        Log.i(TAG, volleyError.getMessage(), volleyError.getCause());
                    }
                }
        ) {
            @Override
            protected Response<Object> parseNetworkResponse(NetworkResponse networkResponse) {
                // TODO
                return null;
            }

            @Override
            protected Map<String, String> getParams() {
                Map<String, String> params = new HashMap<>();
                params.put("callback_url", Uri.encode(CALLBACK));
                return params;
            }
        };
        NetworkManager.getInstance().getRequestQueue(this).add(request);
    }

    private void showOAuthWhenReady() {
        if (mDidPressLogIn) {
            // ...
        }
    }

    private static class BrowserRedirectUrlRequest extends JsonRequest<Object> {
        public BrowserRedirectUrlRequest(int method, String url, Response.Listener<Object> listener,
                                         Response.ErrorListener errorListener) {
            super(method, url, null, listener, errorListener);
        }

        @Override
        protected Map<String, String> getParams() {
            Map<String, String> result = new HashMap<>();
            result.put("callback", "motif://");
            return result;
        }

        @Override
        protected Response<Object> parseNetworkResponse(NetworkResponse response) {
            return null;
        }
    }
}
