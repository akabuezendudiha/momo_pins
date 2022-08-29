package com.mguardsolutions.momo_pins;

import android.Manifest;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.telecom.PhoneAccountHandle;
import android.telecom.TelecomManager;
import android.text.TextUtils;
import android.widget.Toast;
import android.app.AlertDialog;
import android.content.DialogInterface;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.multidex.MultiDex;

import java.util.List;
import java.util.Objects;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import static android.provider.Settings.Secure;
import static android.provider.Settings.SettingNotFoundException;

public class MainActivity extends FlutterFragmentActivity implements MethodChannel.MethodCallHandler {
    static final String TAG = ".MainActivity";
    static final String CHANNEL = "com.mguardsolutions.momo_pins/service";
    static final String STREAM = "com.mguardsolutions.momo_pins/stream";
    static final String CONNECT_TAG = "connect";
    static final String DISCONNECT_TAG = "disconnect";
    static final String OPEN_ACCESSIBILITY_TAG = "open_accessibility_settings";
    static final String DIAL_SINGLE_USSD_TAG = "dial_single_step_ussd_code";
    static final String DIAL_MULTIPLE_USSD_TAG = "dial_multi_step_ussd_code";
    static final String ARG_SIM_ID = "sim_id";
    static final String ARG_DIAL_CODE = "dial_code";
    static final String ARG_DIAL_CODE_RESULT = "dial_code_result";
    final static String[] simSlotNames = {
            "extra_asus_dial_use_dualsim",
            "com.android.phone.extra.slot",
            "slot",
            "simslot",
            "sim_slot",
            "subscription",
            "Subscription",
            "phone",
            "com.android.phone.DialingMode",
            "simSlot",
            "slot_id",
            "simId",
            "simnum",
            "phone_type",
            "slotId",
            "slotIdx",
            "sim",
            "_slot"};
    boolean serviceConnected = false;

    EventChannel.EventSink eventSink = null;
    EventChannel.StreamHandler streamHandler = new EventChannel.StreamHandler() {
        private BroadcastReceiver dialCodeResultReceiver;

        @Override
        public void onListen(Object args, EventChannel.EventSink sink) {
            eventSink = sink;
            dialCodeResultReceiver = dialCodeResultReceiver(sink);
            registerReceiver(dialCodeResultReceiver, new IntentFilter(USSDService.BROADCAST_ACTION));
        }

        @Override
        public void onCancel(Object args) {
            unregisterReceiver(dialCodeResultReceiver);
            eventSink = null;
        }

    };

    private static Uri convertToUri(String dialCode) {
        StringBuilder formattedString = new StringBuilder();
        if (!dialCode.startsWith("tel:"))
            formattedString.append("tel:");
        for (char c : dialCode.toCharArray()) {
            if (c == '#') formattedString.append(Uri.encode("#"));
            else formattedString.append(c);
        }
        return Uri.parse(formattedString.toString());
    }

    private BroadcastReceiver dialCodeResultReceiver(final EventChannel.EventSink events) {
        return new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                String message = intent.getStringExtra(ARG_DIAL_CODE_RESULT);
                events.success(message);
            }
        };
    }

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        MultiDex.install(this);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(this);
        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), STREAM)
                .setStreamHandler(streamHandler);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        try {
            Integer simSlotIndex;
            String dialCode;
            String dialCodeResult;
            switch (call.method) {
                case CONNECT_TAG:
                    if (isAccessibilitySettingsOff()) {
                        result.error("accessibilityServiceError", "Accessibility Service not enabled!\n", "Accessibility Service must be enabled to allow App function properly.");
                    } else {
                        connectToUssdService();
                        result.success("success");
                    }
                    break;
                case DISCONNECT_TAG:
                    disconnectFromUssdService();
                    result.success("disconnected");
                    break;
                case OPEN_ACCESSIBILITY_TAG:
                    if (isAccessibilitySettingsOff()) {
                        startActivity(new Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS));
                        result.success("not_enabled");
                    } else {
                        result.success("enabled");
                    }
                    break;
                case DIAL_SINGLE_USSD_TAG:
                    if (!serviceConnected) {
                        result.error("serviceConnectionError", "App not connected to Service!", "Please ensure App Accessibility Service is enabled.");
                    } else {
                        // Gets sim slot and dial code for the call operation
                        simSlotIndex = call.argument(ARG_SIM_ID);
                        dialCode = call.argument(ARG_DIAL_CODE);
                        if (simSlotIndex == null) {
                            result.error("simSlotError", "SIM Slot is empty!", "SIM slot number is required for App function.");
                        } else {
                            // initiate the dial code action
                            USSDService.mode = AppMode.SINGLE_STEP;
                            dialCodeResult = dialUSSDCode(dialCode, simSlotIndex);

                            // sets result status from dialCodeResult
                            result.success(dialCodeResult);
                        }
                    }
                    break;
                case DIAL_MULTIPLE_USSD_TAG:
                    if (!serviceConnected) {
                        result.error("serviceConnectionError", "App not connected to service!", "Please ensure App Accessibility Service is enabled.");
                    } else {
                        // Gets sim slot and dial code for the call operation
                        simSlotIndex = call.argument(ARG_SIM_ID);
                        dialCode = call.argument(ARG_DIAL_CODE);
                        if (simSlotIndex == null) {
                            result.error("simSlotError", "SIM Slot Index is null!", "SIM slot number is required for dial function.");
                        } else {
                            // initiate the dial code action
                            USSDService.mode = AppMode.MULTI_STEP;
                            dialCodeResult = dialUSSDCode(dialCode, simSlotIndex);

                            // sets result status from dialCodeResult
                            result.notImplemented();
                        }
                    }
                    break;
                default:
                    result.notImplemented();
            }
        } catch (Exception e) {
            e.printStackTrace();
            result.error("unhandledException", e.getMessage(), e.getLocalizedMessage());
        }
    }

    private void connectToUssdService() {
        if (!serviceConnected) {
            Intent service = new Intent(this, USSDService.class);
            startService(service);
            serviceConnected = true;
        }
    }

    private void disconnectFromUssdService() {
        if (serviceConnected) {
            Intent service = new Intent(this, USSDService.class);
            stopService(service);
            USSDService.isUSSDFromApp = false;
            serviceConnected = false;
            Log.i(TAG, "Service disconnected");
        } else {
            Log.i(TAG, "Service already disconnected");
        }
    }

    private String dialUSSDCode(String dialCode, int simSlotIndex) {
        try {
            if (isAccessibilitySettingsOff()) {
                // displays the toast
                Toast.makeText(this, "Warning! Accessibility service option is not enabled.", Toast.LENGTH_LONG).show();
                return "service_not_enabled";
            }
            // sets the isUSSDFromApp to true
            USSDService.isUSSDFromApp = true;

            // sends the call phone intent
            startCallActivity(dialCode, simSlotIndex);

            return "success";
        } catch (Exception e) {
            e.printStackTrace();
            return String.format("Error: %s", e.getMessage());
        }
    }

    private final int REQUEST_PERMISSION_PHONE_STATE = 1;
    private void showPhoneStatePermission() {
        int permissionCheck = ContextCompat.checkSelfPermission(
                this, Manifest.permission.READ_PHONE_STATE);
        if (permissionCheck != PackageManager.PERMISSION_GRANTED) {
            if (ActivityCompat.shouldShowRequestPermissionRationale(this,
                    Manifest.permission.READ_PHONE_STATE)) {
                showExplanation("Permission Needed", "Rationale", Manifest.permission.READ_PHONE_STATE, REQUEST_PERMISSION_PHONE_STATE);
            } else {
                requestPermission(Manifest.permission.READ_PHONE_STATE, REQUEST_PERMISSION_PHONE_STATE);
            }
        } else {
            Toast.makeText(MainActivity.this, "Permission (already) Granted!", Toast.LENGTH_SHORT).show();
        }
    }

    private void showExplanation(String title,
                             String message,
                             final String permission,
                             final int permissionRequestCode) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(title)
                .setMessage(message)
                .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        requestPermission(permission, permissionRequestCode);
                    }
                });
        builder.create().show();
    }

    private void requestPermission(String permissionName, int permissionRequestCode) {
        ActivityCompat.requestPermissions(this,
                new String[]{permissionName}, permissionRequestCode);
    }

    @Override 
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        switch (requestCode) {
            case REQUEST_PERMISSION_PHONE_STATE:
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    Toast.makeText(MainActivity.this, "Permission Granted!", Toast.LENGTH_SHORT).show();
                } else {
                    Toast.makeText(MainActivity.this, "Permission Denied!", Toast.LENGTH_SHORT).show();
                }
        }
    }

    // @SuppressLint("MissingPermission")
    private void startCallActivity(String dialCode, int slotIndex) {
        TelecomManager telecomManager = (TelecomManager) this.getSystemService(Context.TELECOM_SERVICE);
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) { 
            // Shows state permssion
            showPhoneStatePermission();
            // Consider calling
            //    ActivityCompat#requestPermissions
            // here to request the missing permissions, and then overriding
            //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
            //                                          int[] grantResults)
            // to handle the case where the user grants the permission. See the documentation
            // for ActivityCompat#requestPermissions for more details.
            return;
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            List<PhoneAccountHandle> phoneAccountHandleList = telecomManager.getCallCapablePhoneAccounts();
            Intent intent = new Intent(Intent.ACTION_CALL, convertToUri(dialCode)).setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.putExtra("com.android.phone.force.slot", true);
            if (slotIndex == 0) {   //0 for sim1
                intent.putExtra("com.android.phone.extra.slot", 0); //0 or 1 according to sim.......
                if (phoneAccountHandleList != null && phoneAccountHandleList.size() > 0) {
                    intent.putExtra("android.telecom.extra.PHONE_ACCOUNT_HANDLE", phoneAccountHandleList.get(0));
                }
            } else {    //0 for sim1
                intent.putExtra("com.android.phone.extra.slot", 1); //0 or 1 according to sim.......
                if (phoneAccountHandleList != null && phoneAccountHandleList.size() > 1) {
                    intent.putExtra("android.telecom.extra.PHONE_ACCOUNT_HANDLE", phoneAccountHandleList.get(1));
                }
            }
            startActivity(intent);
        } else {
            Intent intent = new Intent(Intent.ACTION_CALL, convertToUri(dialCode));
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.putExtra("com.android.phone.force.slot", true);
            intent.putExtra("Cdma_Supp", true);
            //Add all slots here, according to device.. (different device require different key so put all together)
            for (String s : simSlotNames)
                intent.putExtra(s, slotIndex); // slot index of the sim to dial from
            startActivity(intent);
        }
    }

    boolean isAccessibilitySettingsOff() {
        final String service = getPackageName() + "/" + USSDService.class.getCanonicalName();
        try {
            int accessibilityEnabled = Secure.getInt(this.getApplicationContext().getContentResolver(), Secure.ACCESSIBILITY_ENABLED);
            TextUtils.SimpleStringSplitter mStringColonSplitter = new TextUtils.SimpleStringSplitter(':');
            if (accessibilityEnabled == 1) {
                String settingValue = Secure.getString(this.getApplicationContext().getContentResolver(), Secure.ENABLED_ACCESSIBILITY_SERVICES);
                if (settingValue != null) {
                    mStringColonSplitter.setString((settingValue));
                    while (mStringColonSplitter.hasNext()) {
                        String accessibilityService = mStringColonSplitter.next();
                        if (accessibilityService.equalsIgnoreCase(service)) {
                            return false;
                        }
                    }
                }
            }
        } catch (SettingNotFoundException e) {
            Log.w(TAG, Objects.requireNonNull(e.getMessage()));
            e.printStackTrace();
        }
        return true;
    }
}
