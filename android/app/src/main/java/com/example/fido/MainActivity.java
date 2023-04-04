package com.example.fido;
import android.app.PendingIntent;
import android.content.Intent;
import android.content.IntentSender;
import android.os.Build;
import android.os.Bundle;
import android.util.Base64;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import com.google.android.gms.fido.Fido;
import com.google.android.gms.fido.fido2.Fido2ApiClient;
import com.google.android.gms.fido.fido2.api.common.Attachment;
import com.google.android.gms.fido.fido2.api.common.AuthenticatorAttestationResponse;
import com.google.android.gms.fido.fido2.api.common.AuthenticatorSelectionCriteria;
import com.google.android.gms.fido.fido2.api.common.PublicKeyCredentialCreationOptions;
import com.google.android.gms.fido.fido2.api.common.PublicKeyCredentialDescriptor;
import com.google.android.gms.fido.fido2.api.common.PublicKeyCredentialParameters;
import com.google.android.gms.fido.fido2.api.common.PublicKeyCredentialRpEntity;
import com.google.android.gms.fido.fido2.api.common.PublicKeyCredentialType;
import com.google.android.gms.fido.fido2.api.common.PublicKeyCredentialUserEntity;
import com.google.android.gms.tasks.Task;


import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import kotlin.text.Charsets;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

public class MainActivity extends FlutterActivity {
    static String FIDO_CHANNEL = "fido_channel";


    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        Bundle extras = data.getExtras();

        if(data.hasExtra(Fido.FIDO2_KEY_RESPONSE_EXTRA)){
            byte[] fido2Response = data.getByteArrayExtra(Fido.FIDO2_KEY_RESPONSE_EXTRA);
//            Log.e("fido2Response", String.valueOf("fido2Response: "+(fido2Response == null)));
            if(requestCode == 1) {
                handleRegisterResponse(fido2Response);
            }else if(requestCode == 0){

            }
        }

    }

    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    private void handleRegisterResponse(byte[] fido2Response) {

        MethodChannel fidoChannel = new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(),
                FIDO_CHANNEL);
        AuthenticatorAttestationResponse response =  AuthenticatorAttestationResponse.deserializeFromBytes(fido2Response);

        HashMap<String, String> args = new HashMap<>();
        args.put("keyHandle", new String(response.getKeyHandle(),StandardCharsets.UTF_8));
        args.put("clientDataJson", new String(response.getClientDataJSON(),
                StandardCharsets.UTF_8));
        args.put("attestationObject", new String(response.getAttestationObject(),StandardCharsets.UTF_8));
//        Log.e("response", "handleRegisterResponse: " + Arrays.toString(response.getAttestationObject()));
        fidoChannel.invokeMethod("onRegistrationComplete",args);
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        MethodChannel fidoChannel = new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(),
                FIDO_CHANNEL);

        fidoChannel.setMethodCallHandler((call, result) -> {
//            Log.e("cred method", "onActivityResult: " + call.method);
            // result.success(call.method);
            if (call.method.equals("createCredentials")) {

                HashMap options = (HashMap) call.arguments;
                PublicKeyCredentialCreationOptions.Builder builder = new PublicKeyCredentialCreationOptions.Builder();
                builder.setUser(parseUser((HashMap) options.get("user")));
                builder.setChallenge(base64Decoder(options.get("challenge")));
                builder.setParameters(parseParameter((List) options.get("pubKeyCredParams")));
                builder.setTimeoutSeconds(Double.valueOf((int) options.get("timeout")));
                builder.setExcludeList(parseCredentialDescriptors((List) options.get("excludeCredentials")));
                builder.setAuthenticatorSelection(parseSelection((HashMap) options.get("authenticatorSelection")));
                builder.setRp(parseRp((HashMap) options.get("rp")));
                PublicKeyCredentialCreationOptions publicKeyCredentialCreationOptions =
                        builder.build();
                Fido2ApiClient fidoClient = Fido.getFido2ApiClient(this);
                Task<PendingIntent> registerIntent = fidoClient.getRegisterPendingIntent(publicKeyCredentialCreationOptions);
                registerIntent.addOnFailureListener((e)->{
//                    Log.e("Failure", "addOnFailureListener: " + e);
                });
                registerIntent.addOnSuccessListener((pendingIntent -> {
//                    Log.e("Success", "addOnSuccessListener: " + pendingIntent);
                    try {
                        this.startIntentSenderForResult(
                                pendingIntent.getIntentSender(),
                                1,
                                null,
                                0,0,0
                        );
                    } catch (IntentSender.SendIntentException e) {
//                        Log.e("Success", "addOnSuccessListener: " + e);
                        throw new RuntimeException(e);
                    }
                }));
//                Task<PendingIntent> task = fido2ApiClient.getRegisterPendingIntent(publicKeyCredentialCreationOptions);
//                Log.e("", "configureFlutterEngine: " + task);
//                result.success(task);
            }
        });
    }

    private PublicKeyCredentialRpEntity parseRp(HashMap rp) {
        return new PublicKeyCredentialRpEntity(
                rp.get("id").toString(), rp.get("name").toString(), null);
    }

    private AuthenticatorSelectionCriteria parseSelection(HashMap authenticatorSelection) {
        AuthenticatorSelectionCriteria.Builder builder = new AuthenticatorSelectionCriteria.Builder();
        String aa = authenticatorSelection.get("authenticatorAttachment").toString();
        if(aa.equals("platform")){
            builder.setAttachment(Attachment.PLATFORM);
        } else if (aa.equals("cross-platform")) {
            builder.setAttachment(Attachment.CROSS_PLATFORM);
        }
        return builder.build();
    }

    private List<PublicKeyCredentialParameters> parseParameter(List pubKeyCredParams) {
        List<PublicKeyCredentialParameters> publicKeyCredentialParametersList = new ArrayList<PublicKeyCredentialParameters>();
        for (int i = 0; i < pubKeyCredParams.size(); i++) {
            HashMap map = (HashMap) pubKeyCredParams.get(i);
            publicKeyCredentialParametersList
                    .add(new PublicKeyCredentialParameters(map.get("type").toString(), (int) map.get("alg")));
        }
        return publicKeyCredentialParametersList;
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    private List<PublicKeyCredentialDescriptor> parseCredentialDescriptors(List excludeCredentials) {
        List<PublicKeyCredentialDescriptor> publicKeyCredentialDescriptorsList = new ArrayList<PublicKeyCredentialDescriptor>();
        for (int i = 0; i < excludeCredentials.size(); i++) {
            HashMap map = (HashMap) excludeCredentials.get(i);
            publicKeyCredentialDescriptorsList.add(new PublicKeyCredentialDescriptor(
                    PublicKeyCredentialType.PUBLIC_KEY.toString(), base64Decoder(map.get("id")), null));
        }
        return publicKeyCredentialDescriptorsList;
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    private PublicKeyCredentialUserEntity parseUser(HashMap userMap) {
        return new PublicKeyCredentialUserEntity(
                base64Decoder(userMap.get("id")), userMap.get("name").toString(), null,
                userMap.get("displayName").toString());
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    private byte[] base64Decoder(Object encodedStr) {
//        Log.e("encodedStr", "base64Decoder: "+encodedStr );
//        byte[] decodedStr = Base64.getDecoder().decode(encodedStr.toString());
        return encodedStr.toString().getBytes();
    }
}
