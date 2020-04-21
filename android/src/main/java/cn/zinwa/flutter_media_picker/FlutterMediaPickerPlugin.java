package cn.zinwa.flutter_media_picker;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import android.app.Activity;
import android.content.Intent;

import com.luck.picture.lib.PictureSelector;
import com.luck.picture.lib.config.PictureConfig;
import com.luck.picture.lib.config.PictureMimeType;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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

      PictureSelector.create(activity)
              .openGallery(PictureMimeType.ofImage())
              .loadImageEngine(GlideEngine.createGlideEngine()) // 请参考Demo GlideEngine.java
              .forResult(PictureConfig.CHOOSE_REQUEST);
//      activity.startActivityForResult(new Intent(activity, PictureSelectorActivity.class), 0);
      // result.success(null);
     Map<String, String> m = new HashMap<String, String>();
     m.put("path", "9345893485.png");
     m.put("type", "image");
     List<Map> list = new ArrayList<Map>();
     list.add(m);

     result.success(list);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  }
}
