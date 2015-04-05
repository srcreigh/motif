package me.motifapp.android;

import android.content.Context;

import com.android.volley.RequestQueue;

public interface RequestQueueProvider {
    public RequestQueue getRequestQueue(Context context);
}
