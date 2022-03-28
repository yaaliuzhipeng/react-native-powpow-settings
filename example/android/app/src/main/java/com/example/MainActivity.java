package com.example;

import android.content.Intent;
import android.content.res.Configuration;
import android.media.AudioManager;
import android.util.Log;

import com.facebook.react.ReactActivity;
import com.powpow.settings.PowpowSettingsModule;

public class MainActivity extends ReactActivity {

  /**
   * Returns the name of the main component registered from JavaScript. This is used to schedule
   * rendering of the component.
   */
  @Override
  protected String getMainComponentName() {
    return "example";
  }

  @Override
  public void onConfigurationChanged(Configuration newConfig) {
    super.onConfigurationChanged(newConfig);
    PowpowSettingsModule.handleOrientationConfiguration(newConfig,this);
  }
}
