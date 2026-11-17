package com.reactcommunity.rndatetimepicker;

import android.app.TimePickerDialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.widget.TimePicker;
import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentManager;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.module.annotations.ReactModule;

@ReactModule(name = RNTimePickerDialogModule.FRAGMENT_TAG)
/* loaded from: classes2.dex */
public class RNTimePickerDialogModule extends ReactContextBaseJavaModule {
    public static final String FRAGMENT_TAG = "RNTimePickerAndroid";

    @Override // com.facebook.react.bridge.NativeModule
    public String getName() {
        return FRAGMENT_TAG;
    }

    public RNTimePickerDialogModule(ReactApplicationContext reactApplicationContext) {
        super(reactApplicationContext);
    }

    /* loaded from: classes2.dex */
    private class TimePickerDialogListener implements TimePickerDialog.OnTimeSetListener, DialogInterface.OnDismissListener, DialogInterface.OnClickListener {
        private final Promise mPromise;
        private boolean mPromiseResolved = false;

        public TimePickerDialogListener(Promise promise) {
            RNTimePickerDialogModule.this = r1;
            this.mPromise = promise;
        }

        @Override // android.app.TimePickerDialog.OnTimeSetListener
        public void onTimeSet(TimePicker timePicker, int i, int i2) {
            if (this.mPromiseResolved || !RNTimePickerDialogModule.this.getReactApplicationContext().hasActiveReactInstance()) {
                return;
            }
            WritableNativeMap writableNativeMap = new WritableNativeMap();
            writableNativeMap.putString("action", RNConstants.ACTION_TIME_SET);
            writableNativeMap.putInt("hour", i);
            writableNativeMap.putInt("minute", i2);
            this.mPromise.resolve(writableNativeMap);
            this.mPromiseResolved = true;
        }

        @Override // android.content.DialogInterface.OnDismissListener
        public void onDismiss(DialogInterface dialogInterface) {
            if (this.mPromiseResolved || !RNTimePickerDialogModule.this.getReactApplicationContext().hasActiveReactInstance()) {
                return;
            }
            WritableNativeMap writableNativeMap = new WritableNativeMap();
            writableNativeMap.putString("action", RNConstants.ACTION_DISMISSED);
            this.mPromise.resolve(writableNativeMap);
            this.mPromiseResolved = true;
        }

        @Override // android.content.DialogInterface.OnClickListener
        public void onClick(DialogInterface dialogInterface, int i) {
            if (this.mPromiseResolved || !RNTimePickerDialogModule.this.getReactApplicationContext().hasActiveReactInstance()) {
                return;
            }
            WritableNativeMap writableNativeMap = new WritableNativeMap();
            writableNativeMap.putString("action", RNConstants.ACTION_NEUTRAL_BUTTON);
            this.mPromise.resolve(writableNativeMap);
            this.mPromiseResolved = true;
        }
    }

    @ReactMethod
    public void dismiss(Promise promise) {
        Common.dismissDialog((FragmentActivity) getCurrentActivity(), FRAGMENT_TAG, promise);
    }

    @ReactMethod
    public void open(final ReadableMap readableMap, final Promise promise) {
        FragmentActivity fragmentActivity = (FragmentActivity) getCurrentActivity();
        if (fragmentActivity == null) {
            promise.reject(RNConstants.ERROR_NO_ACTIVITY, "Tried to open a TimePicker dialog while not attached to an Activity");
            return;
        }
        final FragmentManager supportFragmentManager = fragmentActivity.getSupportFragmentManager();
        UiThreadUtil.runOnUiThread(new Runnable() { // from class: com.reactcommunity.rndatetimepicker.RNTimePickerDialogModule.1
            @Override // java.lang.Runnable
            public void run() {
                ReadableMap readableMap2;
                RNTimePickerDialogFragment rNTimePickerDialogFragment = (RNTimePickerDialogFragment) supportFragmentManager.findFragmentByTag(RNTimePickerDialogModule.FRAGMENT_TAG);
                if (rNTimePickerDialogFragment != null && (readableMap2 = readableMap) != null) {
                    rNTimePickerDialogFragment.update(RNTimePickerDialogModule.this.createFragmentArguments(readableMap2));
                    return;
                }
                RNTimePickerDialogFragment rNTimePickerDialogFragment2 = new RNTimePickerDialogFragment();
                ReadableMap readableMap3 = readableMap;
                if (readableMap3 != null) {
                    rNTimePickerDialogFragment2.setArguments(RNTimePickerDialogModule.this.createFragmentArguments(readableMap3));
                }
                TimePickerDialogListener timePickerDialogListener = new TimePickerDialogListener(promise);
                rNTimePickerDialogFragment2.setOnDismissListener(timePickerDialogListener);
                rNTimePickerDialogFragment2.setOnTimeSetListener(timePickerDialogListener);
                rNTimePickerDialogFragment2.setOnNeutralButtonActionListener(timePickerDialogListener);
                rNTimePickerDialogFragment2.show(supportFragmentManager, RNTimePickerDialogModule.FRAGMENT_TAG);
            }
        });
    }

    public Bundle createFragmentArguments(ReadableMap readableMap) {
        Bundle bundle = new Bundle();
        if (readableMap.hasKey(RNConstants.ARG_VALUE) && !readableMap.isNull(RNConstants.ARG_VALUE)) {
            bundle.putLong(RNConstants.ARG_VALUE, (long) readableMap.getDouble(RNConstants.ARG_VALUE));
        }
        if (readableMap.hasKey(RNConstants.ARG_IS24HOUR) && !readableMap.isNull(RNConstants.ARG_IS24HOUR)) {
            bundle.putBoolean(RNConstants.ARG_IS24HOUR, readableMap.getBoolean(RNConstants.ARG_IS24HOUR));
        }
        if (readableMap.hasKey("display") && !readableMap.isNull("display")) {
            bundle.putString("display", readableMap.getString("display"));
        }
        if (readableMap.hasKey(RNConstants.ARG_NEUTRAL_BUTTON_LABEL) && !readableMap.isNull(RNConstants.ARG_NEUTRAL_BUTTON_LABEL)) {
            bundle.putString(RNConstants.ARG_NEUTRAL_BUTTON_LABEL, readableMap.getString(RNConstants.ARG_NEUTRAL_BUTTON_LABEL));
        }
        if (readableMap.hasKey(RNConstants.ARG_POSITIVE_BUTTON_LABEL) && !readableMap.isNull(RNConstants.ARG_POSITIVE_BUTTON_LABEL)) {
            bundle.putString(RNConstants.ARG_POSITIVE_BUTTON_LABEL, readableMap.getString(RNConstants.ARG_POSITIVE_BUTTON_LABEL));
        }
        if (readableMap.hasKey(RNConstants.ARG_NEGATIVE_BUTTON_LABEL) && !readableMap.isNull(RNConstants.ARG_NEGATIVE_BUTTON_LABEL)) {
            bundle.putString(RNConstants.ARG_NEGATIVE_BUTTON_LABEL, readableMap.getString(RNConstants.ARG_NEGATIVE_BUTTON_LABEL));
        }
        if (readableMap.hasKey(RNConstants.ARG_INTERVAL) && !readableMap.isNull(RNConstants.ARG_INTERVAL)) {
            bundle.putInt(RNConstants.ARG_INTERVAL, readableMap.getInt(RNConstants.ARG_INTERVAL));
        }
        if (readableMap.hasKey(RNConstants.ARG_TZOFFSET_MINS) && !readableMap.isNull(RNConstants.ARG_TZOFFSET_MINS)) {
            bundle.putInt(RNConstants.ARG_TZOFFSET_MINS, readableMap.getInt(RNConstants.ARG_TZOFFSET_MINS));
        }
        return bundle;
    }
}
