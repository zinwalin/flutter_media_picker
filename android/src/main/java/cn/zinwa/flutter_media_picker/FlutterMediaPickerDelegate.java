package cn.zinwa.flutter_media_picker;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.net.Uri;

import java.io.File;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import android.util.Log;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

import static android.app.Activity.RESULT_OK;
import static android.content.ContentValues.TAG;

import com.luck.picture.lib.PictureSelector;
import com.luck.picture.lib.PictureSelectorActivity;
import com.luck.picture.lib.config.PictureConfig;
import com.luck.picture.lib.config.PictureMimeType;
import com.luck.picture.lib.entity.LocalMedia;
import com.luck.picture.lib.listener.OnResultCallbackListener;

public class FlutterMediaPickerDelegate implements PluginRegistry.ActivityResultListener {
    private final Activity activity;
    private MethodChannel.Result pendingResult;
    private FileUtils fileUtils;

    public FlutterMediaPickerDelegate(Activity activity) {
        this.activity = activity;
        fileUtils = new FileUtils();
    }

    public void getAssets(MethodCall call, MethodChannel.Result result) {

        pendingResult = result;

        PictureSelector.create(this.activity).openGallery(PictureMimeType.ofAll()).isWeChatStyle(true)
                .loadImageEngine(GlideEngine.createGlideEngine())
                // .forResult(PictureConfig.CHOOSE_REQUEST);
                .forResult(new OnResultCallbackListener<LocalMedia>() {
                    @Override
                    public void onResult(List<LocalMedia> result) {
                        List<Map> list = new ArrayList<Map>();
                        for (LocalMedia media : result) {
                            Log.i(TAG, "是否压缩:" + media.isCompressed());
                            Log.i(TAG, "压缩:" + media.getCompressPath());
                            Log.i(TAG, "原图:" + media.getPath());
                            Log.i(TAG, "是否裁剪:" + media.isCut());
                            Log.i(TAG, "裁剪:" + media.getCutPath());
                            Log.i(TAG, "是否开启原图:" + media.isOriginal());
                            Log.i(TAG, "原图路径:" + media.getOriginalPath());
                            Log.i(TAG, "Android Q 特有Path:" + media.getAndroidQToPath());
                            Log.i(TAG, "宽高: " + media.getWidth() + "x" + media.getHeight());
                            Log.i(TAG, "Size: " + media.getSize());

                            // TODO
                            // 可以通过PictureSelectorExternalUtils.getExifInterface();方法获取一些额外的资源信息，如旋转角度、经纬度等信息
                            Map<String, String> m = new HashMap<String, String>();
                            m.put("path", media.getAndroidQToPath());
                            m.put("type", "image");
                            list.add(m);
                        }

                        pendingResult.success(list);
                    }

                    @Override
                    public void onCancel() {
                        Log.i(TAG, "PictureSelector Cancel");
                    }
                });
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.i(TAG, "onActivityResult.....");
        return false;
    }
}
