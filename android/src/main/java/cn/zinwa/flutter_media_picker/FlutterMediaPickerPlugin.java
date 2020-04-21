package cn.zinwa.flutter_media_picker;

import android.app.Activity;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import android.content.Intent;

import com.luck.picture.lib.PictureSelector;
import com.luck.picture.lib.PictureSelectorActivity;
import com.luck.picture.lib.config.PictureConfig;
import com.luck.picture.lib.config.PictureMimeType;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

//import androidx.appcompat.app.AppCompatDelegate;

/** FlutterMediaPickerPlugin */
public class FlutterMediaPickerPlugin implements MethodCallHandler, FlutterPlugin, ActivityAware {

    //  static
//  {
//    AppCompatDelegate.setCompatVectorFromResourcesEnabled(true);
//  }
  private static final String CHANNEL = "flutter_media_picker";

  private static FlutterMediaPickerPlugin instance;
  private static MethodChannel channel;
  private static FlutterMediaPickerDelegate delegate;

  private Activity activity;
  private final Object initializationLock = new Object();

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    if (instance == null) {
      instance = new FlutterMediaPickerPlugin();
    }
    if (registrar.activity() != null) {
      instance.onAttachedToEngine(registrar.messenger());
      instance.onAttachedToActivity(registrar.activity());
      registrar.addActivityResultListener(instance.getActivityResultListener());
    }
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (activity == null) {
      result.error("no_activity", "flutter_media_picker plugin requires a foreground activity.", null);
      return;
    }

    if (call.method.equals("get_assets")) {
      delegate.getAssets(call, result);
    } else {
       result.notImplemented();
     }
  }

  private void onAttachedToEngine(BinaryMessenger messenger) {
    synchronized (initializationLock) {
      if (channel != null) {
        return;
      }

      channel = new MethodChannel(messenger, CHANNEL);
      channel.setMethodCallHandler(this);
    }
  }

  private void onAttachedToActivity(Activity activity) {
    this.activity = activity;
    delegate = new FlutterMediaPickerDelegate(activity);
  }

  private PluginRegistry.ActivityResultListener getActivityResultListener() {
    return delegate;
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    onAttachedToEngine(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    channel = null;
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    if (getActivityResultListener() != null) {
      binding.removeActivityResultListener(getActivityResultListener());
    }
    onAttachedToActivity(binding.getActivity());
    binding.addActivityResultListener(getActivityResultListener());
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    activity = null;
    delegate = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    if (getActivityResultListener() != null) {
      binding.removeActivityResultListener(getActivityResultListener());
    }
    onAttachedToActivity(binding.getActivity());
    binding.addActivityResultListener(getActivityResultListener());
  }

  @Override
  public void onDetachedFromActivity() {
    activity = null;
    delegate = null;
  }
}
