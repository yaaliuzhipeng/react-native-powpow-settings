// PowpowSettingsModule.java

package com.powpow.settings;

import static android.content.Context.AUDIO_SERVICE;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.media.AudioManager;
import android.os.Build;
import android.view.View;
import android.view.WindowManager;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

public class PowpowSettingsModule extends ReactContextBaseJavaModule implements LifecycleEventListener {

    private final ReactApplicationContext reactContext;
    private OrientationReceiver orientationReceiver;

    private static final String TAG = PowpowSettingsModule.class.getSimpleName();
    private static final String actionOrientation = "powpowOrientationChanged";
    private static final String extOrien = "orientation";
    private static final String jsOrientationEventName = "onOrientationChanged";

    public PowpowSettingsModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        reactContext.addLifecycleEventListener(this);
    }

    public static void handleOrientationConfiguration(Configuration newConfig, Context context) {
        Intent intent = new Intent();
        intent.setAction(actionOrientation);
        intent.putExtra(extOrien,newConfig.orientation);
        context.sendBroadcast(intent);
    }

    private class OrientationReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            int ori = intent.getIntExtra(extOrien,-1);
            reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(jsOrientationEventName,ori);
        }
    }

    private void handleReceiverRegistration(Boolean unregister){
        Activity activity = getCurrentActivity();
        if(activity == null) return;
        if(!unregister) {
            if(orientationReceiver == null) {
                orientationReceiver = new OrientationReceiver();
                IntentFilter filter = new IntentFilter();
                filter.addAction(actionOrientation);
                activity.registerReceiver(orientationReceiver,filter);
            }
        }else{
            if(orientationReceiver != null) {
                activity.unregisterReceiver(orientationReceiver);
            }
        }
    }

    @NonNull
    @Override
    public String getName() {
        return "PowpowSettings";
    }

    /**
     * @param orientation
     * 0 => Unknow
     * 1 => Portrait
     * 2 => PortraitUpsideDown
     * 3 => Landscaple (LandscapeLeft)
     * 4 => LandscapeRight
     */
    @ReactMethod
    public void setOrientation(int orientation) {
        if(getCurrentActivity() != null) {
            int to = -1;
            if(orientation == 0) {
                to = ActivityInfo.SCREEN_ORIENTATION_FULL_SENSOR;
            }else if(orientation == 1) {
                to = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT;
            }else if(orientation == 2) {
                to = ActivityInfo.SCREEN_ORIENTATION_REVERSE_PORTRAIT;
            }else if(orientation == 3) {
                to = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
            }else if(orientation == 4){
                to = ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE;
            }else {
                to = ActivityInfo.SCREEN_ORIENTATION_FULL_SENSOR;
            }
            getCurrentActivity().setRequestedOrientation(to);
        }
    }
    @ReactMethod
    public void getOrientation(Callback callback){
        WritableMap map = Arguments.createMap();
        map.putInt("value",reactContext.getResources().getConfiguration().orientation);
        callback.invoke(map);
    }
    // 0 - 1
    @ReactMethod
    public void setMediaVolume(int volume,Callback onError) {
        Activity activity = getCurrentActivity();
        if(activity == null) return;
        AudioManager audioManager = (AudioManager)activity.getSystemService(AUDIO_SERVICE);
        int maxVol = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
        try {
            audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, (int)Math.max(0,Math.min(volume, 1.0))*maxVol,AudioManager.FLAG_REMOVE_SOUND_AND_VIBRATE);
        }catch (SecurityException e) {
            WritableMap map = Arguments.createMap();
            map.putString("error",e.getLocalizedMessage());
            onError.invoke(map);
        }
    }
    // 0 - 1
    @ReactMethod
    public void getMediaVolume(Callback callback){
        Activity activity = getCurrentActivity();
        if(activity == null) return;
        AudioManager audioManager = (AudioManager)activity.getSystemService(AUDIO_SERVICE);
        int vol = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC);
        WritableMap map = Arguments.createMap();
        map.putDouble("value",vol/15.0);
        callback.invoke(map);
    }
    // 0 - 1
    @ReactMethod
    public void setAppScreenBrightness(double brightness){
        Activity activity = getCurrentActivity();
        if(activity == null) return;
        final WindowManager.LayoutParams lp = activity.getWindow().getAttributes();
        lp.screenBrightness = (float)Math.min(0,Math.max(brightness,1.0)) * 255;
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                activity.getWindow().setAttributes(lp);
            }
        });
    }
    @ReactMethod
    public void getAppScreenBrightness(Callback callback){
        //Settings.System.getInt(reactContext.getContentResolver(),Settings.System.SCREEN_BRIGHTNESS);
        final Activity activity = getCurrentActivity();
        if (activity == null) return;
        WritableMap map = Arguments.createMap();
        try {
            float brightness = activity.getWindow().getAttributes().screenBrightness;
            if (brightness < 0) {
//                int val = Settings.System.getInt(reactContext.getContentResolver(), Settings.System.SCREEN_BRIGHTNESS);
                map.putDouble("value",-1.0);
            }else{
                map.putDouble("value",brightness);
            }
        } catch (Exception e) {
            map.putDouble("value",-1.0);
        }
    }

    @ReactMethod
    public void setImmersiveStatusBar(Boolean immersive){
        Activity activity = getCurrentActivity();
        if(activity == null) return;
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                WindowManager.LayoutParams layoutParams = activity.getWindow().getAttributes();
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    layoutParams.layoutInDisplayCutoutMode = immersive ? WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES:WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_DEFAULT;
                    activity.getWindow().setAttributes(layoutParams);
                }
            }
        });
    }
    @ReactMethod
    public void setRealFullscreen(boolean fullscreen) {
        Activity activity = getCurrentActivity();
        if(activity == null) return;
        final int flags = !fullscreen ? View.SYSTEM_UI_FLAG_VISIBLE :View.SYSTEM_UI_FLAG_FULLSCREEN
                | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY;
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                activity.getWindow().getDecorView().setSystemUiVisibility(flags);
            }
        });
    }

    @ReactMethod
    public void addListener(String type){ }
    @ReactMethod
    public void removeListeners(int count) { }
    @Override
    public void onHostResume() {
        handleReceiverRegistration(false);
    }
    @Override
    public void onHostPause() {

    }
    @Override
    public void onHostDestroy() {
        handleReceiverRegistration(true);
    }
}
