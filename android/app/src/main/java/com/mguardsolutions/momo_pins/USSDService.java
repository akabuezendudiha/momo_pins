package com.mguardsolutions.momo_pins;

import android.accessibilityservice.AccessibilityService;
import android.accessibilityservice.AccessibilityServiceInfo;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.accessibility.AccessibilityEvent;
import android.view.accessibility.AccessibilityNodeInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ScrollView;
import android.widget.TextView;

public class USSDService extends AccessibilityService {
    final static String BROADCAST_ACTION = "com.mguardsolutions.momo_pins/broadcast";

    // App mode variables
    public static AppMode mode;
    public static boolean isUSSDFromApp = false;

    @Override
    public void onAccessibilityEvent(AccessibilityEvent event) {
        Context context = getApplicationContext();
        if (isUSSDFromApp && event.getPackageName().toString().equals("com.android.phone") && event.getClassName().toString().toLowerCase().contains("alert")) {
            AccessibilityNodeInfo source = event.getSource();
            if (source != null) {
                switch (mode) {
                    case SINGLE_STEP:
                        String stringResult = getText(source);
                        clickButton(source, "ok");
                        clickButton(source, "cancel");
                        Intent singleStepIntent = new Intent();
                        singleStepIntent.setPackage(context.getPackageName());
                        singleStepIntent.setAction(BROADCAST_ACTION);
                        singleStepIntent.putExtra(MainActivity.ARG_DIAL_CODE_RESULT, stringResult);
                        context.sendBroadcast(singleStepIntent);
                        isUSSDFromApp = false;
                        break;
                    case MULTI_STEP:
                        String eventResult = fetchUssdResponse(source);
                        Intent multiStepIntent = new Intent();
                        multiStepIntent.setPackage(context.getPackageName());
                        multiStepIntent.setAction(BROADCAST_ACTION);
                        multiStepIntent.putExtra(MainActivity.ARG_DIAL_CODE_RESULT, eventResult);
                        context.sendBroadcast(multiStepIntent);
                        break;
                    default:
                }
            }
        }
    }

    @Override
    public void onCreate() {
        isUSSDFromApp = false;
        super.onCreate();
    }

    @Override
    public void onDestroy() {
        isUSSDFromApp = false;
        super.onDestroy();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d("mguardsolutions.com", "Services is working background");
        isUSSDFromApp = false;
        return START_STICKY;
    }


    String fetchUssdResponse(AccessibilityNodeInfo node) {
        String response = "";
        String text;
        if (node != null) {
            text = getText(node).toLowerCase();
            response = text;
        }
        return response;
    }

    String getText(AccessibilityNodeInfo node) {
        StringBuilder text = new StringBuilder();
        if (node != null) {
            for (int i = 0; i < node.getChildCount(); i++) {
                AccessibilityNodeInfo child = node.getChild(i);
                if (child != null) {
                    if (child.getClassName().toString().equals(TextView.class.getName())) {
                        text.append(child.getText().toString())
                                .append("\n");
                    } else if (child.getClassName().equals(ScrollView.class.getName())) {
                        for (int j = 0; j < child.getChildCount(); j++) {
                            AccessibilityNodeInfo subChild = child.getChild(j);
                            if (subChild != null) {
                                if (subChild.getClassName().toString().equals(TextView.class.getName())) {
                                    text.append(subChild.getText().toString())
                                            .append("\n");
                                }
                            }
                        }
                    }
                }
            }
        }
        return text.toString();
    }

    void clickButton(AccessibilityNodeInfo node, String buttonTextToClick) {
        if (node != null) {
            for (int i = 0; i < node.getChildCount(); i++) {
                AccessibilityNodeInfo child = node.getChild(i);
                if (child != null) {
                    if (child.getClassName().toString().equals(Button.class.getName())) {
                        String buttonText = child.getText().toString().toLowerCase();
                        if (buttonText.equals(buttonTextToClick)) {
                            child.performAction(AccessibilityNodeInfo.ACTION_CLICK);
                        }
                    } else if (child.getClassName().equals(ScrollView.class.getName())) {
                        for (int j = 0; j < child.getChildCount(); j++) {
                            AccessibilityNodeInfo subChild = child.getChild(j);
                            if (subChild != null) {
                                if (subChild.getClassName().toString().equals(Button.class.getName())) {
                                    String buttonText = subChild.getText().toString().toLowerCase();
                                    if (buttonText.equals(buttonTextToClick)) {
                                        subChild.performAction(AccessibilityNodeInfo.ACTION_CLICK);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    void setEditText(AccessibilityNodeInfo node, String text) {
        if (node != null) {
            for (int i = 0; i < node.getChildCount(); i++) {
                AccessibilityNodeInfo child = node.getChild(i);
                if (child != null) {
                    if (child.getClassName().toString().equals(EditText.class.getName())) {
                        Bundle args = new Bundle();
                        args.putCharSequence(AccessibilityNodeInfo.ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE, text);
                        child.performAction(AccessibilityNodeInfo.ACTION_SET_TEXT, args);
                    }
                }
            }
        }
    }

    @Override
    public void onInterrupt() {
    }

    @Override
    protected void onServiceConnected() {
        super.onServiceConnected();
        AccessibilityServiceInfo info = new AccessibilityServiceInfo();
        info.flags = AccessibilityServiceInfo.DEFAULT;
        info.packageNames = new String[]{"com.android.phone"};
        info.eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED;
        info.feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC;
        setServiceInfo(info);
    }
}
