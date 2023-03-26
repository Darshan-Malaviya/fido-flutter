package com.example.fido;

import android.content.Intent;
import android.os.Build;

import androidx.annotation.RequiresApi;

import com.google.android.gms.fido.fido2.Fido2ApiClient;
import com.google.android.gms.fido.fido2.api.common.PublicKeyCredentialCreationOptions;
import com.google.android.gms.fido.fido2.api.common.PublicKeyCredentialUserEntity;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.HashMap;

public class MainActivity extends FlutterActivity {
    static String FIDO_CHANNEL = "fido_channel";
    Fido2ApiClient fido2ApiClient;


    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);



//        MethodChannel fidoChannel = new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(),FIDO_CHANNEL);
//        fidoChannel.setMethodCallHandler((call,result)->{
//            if(call.method.equals("createCredentials")){
//                HashMap options = call.argument("options");
//                PublicKeyCredentialCreationOptions.Builder builder = new PublicKeyCredentialCreationOptions.Builder();
//
//                builder.setUser(new PublicKeyCredentialUserEntity(base64Decoder(options.get("user").toString()),);
////                fido2ApiClient.getRegisterPendingIntent();
//                result.success("Hello world");
//            }
//        });
    }

//    @RequiresApi(api = Build.VERSION_CODES.O)
//    private byte[] base64Decoder(String str){
//        byte[] decoded = Base64.getDecoder().decode(str);
//        return decoded;
//    }
}
