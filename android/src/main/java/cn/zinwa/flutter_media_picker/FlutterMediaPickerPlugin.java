package cn.zinwa.flutter_media_picker;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import android.app.Activity;

/** FlutterMediaPickerPlugin */
public class FlutterMediaPickerPlugin implements FlutterPlugin, MethodCallHandler {
  private static Activity activity;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    final MethodChannel channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter_media_picker");
    channel.setMethodCallHandler(new FlutterMediaPickerPlugin());
  }
 
  public static void registerWith(Registrar registrar) {
    activity = registrar.activity();
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_media_picker");
    channel.setMethodCallHandler(new FlutterMediaPickerPlugin());
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("get_assets")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  }
}
