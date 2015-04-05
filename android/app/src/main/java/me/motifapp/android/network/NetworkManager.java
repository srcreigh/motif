package me.motifapp.android.network;

import android.content.Context;

import com.android.volley.RequestQueue;
import com.android.volley.toolbox.Volley;

import me.motifapp.android.RequestQueueProvider;

public class NetworkManager implements RequestQueueProvider {

    private static NetworkManager sInstance = new NetworkManager();
    private static RequestQueue sRequestQueue;

    public static NetworkManager getInstance() {
        return sInstance;
    }

    @Override
    public RequestQueue getRequestQueue(Context context) {
        if (sRequestQueue == null) {
            sRequestQueue = Volley.newRequestQueue(context);
        }
        return sRequestQueue;
    }
}
