package me.motifapp.android.network;

import android.net.Uri;
import android.text.TextUtils;
import android.util.Log;

import com.android.volley.AuthFailureError;
import com.android.volley.Response;
import com.android.volley.toolbox.JsonRequest;

import org.scribe.services.Base64Encoder;
import org.scribe.services.HMACSha1SignatureService;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import static java.util.Map.Entry;
import java.util.UUID;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

public abstract class BaseOAuthRequest<T> extends JsonRequest<T> {
    private static final String TAG = "BaseOAuthRequest";

    private static final String EMPTY_STRING = "";
    private static final String CARRIAGE_RETURN = "\r\n";
    private static final String UTF8 = "UTF-8";
    private static final String HMAC_SHA1 = "HmacSHA1";

    final String mClientId;
    final String mClientSecret;

    public BaseOAuthRequest(int method, String url, String requestBody, String clientId,
                            String clientSecret, Response.Listener<T> listener,
                            Response.ErrorListener errorListener) {
        super(method, url, requestBody, listener, errorListener);
        mClientId = clientId;
        mClientSecret = clientSecret;
    }

    @Override
    public Map<String, String> getHeaders() throws AuthFailureError {
        Map<String, String> result = new HashMap<>();
        result.putAll(super.getHeaders());
        result.put("Authentication", getAuthenticationParameter(getParams()));
        return result;
    }

    private String getAuthenticationParameter(Map<String, String> params) {
        Map<String, String> oauthParams = new HashMap<>();
        oauthParams.put("oauth_consumer_key", mClientId);
        oauthParams.put("oauth_nonce", getNonce());
        oauthParams.put("oauth_timestamp", getTimestamp());
        oauthParams.put("oauth_signature_method", "HMAC-SHA1");
        oauthParams.put("oauth_version", "1.0");
        oauthParams.putAll(params);

        utf8Encode(oauthParams);
        urlEncode(oauthParams);

        String baseSignatureString = "";
        {
            List<Entry<String, String>> sorted = new ArrayList<>(oauthParams.entrySet());
            Collections.sort(sorted, new Comparator<Entry<String, String>>() {
                @Override
                public int compare(Entry<String, String> lhs, Entry<String, String> rhs) {
                    final int first = lhs.getKey().compareTo(rhs.getKey());
                    return first != 0 ? first : lhs.getValue().compareTo(rhs.getKey());
                }
            });

            List<String> strings = new ArrayList<>();
            for (Entry<String, String> entry : sorted) {
                strings.add(String.format("%s=%s", entry.getKey(), entry.getValue()));
            }

            baseSignatureString += TextUtils.join("&", strings);
        }

        baseSignatureString = String.format("%s&%s&%s", Uri.encode(getMethodName(getMethod())),
                Uri.encode(urlNoQuery(getUrl())), Uri.encode(baseSignatureString));

        final String signature = doSign(baseSignatureString, mClientSecret);

        oauthParams.put("oauth_signature", signature);

        {
            List<String> values = new ArrayList<>();
            for (Entry<String, String> entry : oauthParams.entrySet()) {
                values.add(String.format("%s=%s", entry.getKey(), entry.getValue()));
            }

            return TextUtils.join(", ", values);
        }
    }

    private String urlNoQuery(String url) {
        if (TextUtils.isEmpty(url)) {
            return url;
        } else {
            Uri uri = Uri.parse(url);
            boolean hasPort = uri.getPort() != -1
                    && !(uri.getScheme().equals("http") && uri.getPort() == 80)
                    && !(uri.getScheme().equals("https") && uri.getPort() == 443);
            if (hasPort) {
                return String.format("%s://%s:%d%s", uri.getScheme(), uri.getAuthority(),
                        uri.getPort(), uri.getPath());
            } else {
                return String.format("%s://%s%s", uri.getScheme(), uri.getAuthority(),
                        uri.getPath());
            }
        }
    }

    private String getMethodName(int method) {
        switch (method) {
            case Method.GET:
                return "GET";
            case Method.POST:
                return "POST";
            case Method.PUT:
                return "PUT";
            case Method.DELETE:
                return "DELETE";
            case Method.HEAD:
                return "HEAD";
            case Method.OPTIONS:
                return "OPTIONS";
            case Method.TRACE:
                return "TRACE";
            case Method.PATCH:
                return "PATCH";
            default:
                throw new IllegalArgumentException("Did not expect HTTP method " + method);
        }
    }

    private void utf8Encode(Map<String, String> params) {
        for (String key : params.keySet()) {
            String val = params.get(key);
            try {
                params.put(key, new String(val.getBytes(), "UTF-8"));
            } catch (UnsupportedEncodingException e) {
                Log.w(TAG, "Unsupported encoding");
            }
        }
    }

    private void urlEncode(Map<String, String> params) {
        for (String key : params.keySet()) {
            String val = params.get(key);
            params.put(key, Uri.encode(val));
        }
    }

    private String getNonce() {
        return UUID.randomUUID().toString();
    }

    private String getTimestamp() {
        return String.valueOf(System.currentTimeMillis());
    }

    private String doSign(String toSign, String keyString) {
        try {
            SecretKeySpec key = new SecretKeySpec((keyString).getBytes(UTF8), HMAC_SHA1);
            Mac mac = Mac.getInstance(HMAC_SHA1);
            mac.init(key);
            byte[] bytes = mac.doFinal(toSign.getBytes(UTF8));
            return bytesToBase64String(bytes).replace(CARRIAGE_RETURN, EMPTY_STRING);
        } catch (Exception e) {
            return null;
        }
    }

    private String bytesToBase64String(byte[] bytes)
    {
        return Base64Encoder.getInstance().encode(bytes);
    }
}
