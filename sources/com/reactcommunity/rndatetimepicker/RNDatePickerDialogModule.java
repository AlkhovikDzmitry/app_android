package com.reactcommunity.rndatetimepicker;

import android.app.DatePickerDialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.widget.DatePicker;
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

@ReactModule(name = RNDatePickerDialogModule.FRAGMENT_TAG)
/* loaded from: classes2.dex */
public class RNDatePickerDialogModule extends ReactContextBaseJavaModule {
    public static final String FRAGMENT_TAG = "RNDatePickerAndroid";

    @Override // com.facebook.react.bridge.NativeModule
    public String getName() {
        return FRAGMENT_TAG;
    }

    public RNDatePickerDialogModule(ReactApplicationContext reactApplicationContext) {
        super(reactApplicationContext);
    }

    /* loaded from: classes2.dex */
    private class DatePickerDialogListener implements DatePickerDialog.OnDateSetListener, DialogInterface.OnDismissListener, DialogInterface.OnClickListener {
        private final Promise mPromise;
        private boolean mPromiseResolved = false;

        public DatePickerDialogListener(Promise promise) {
            RNDatePickerDialogModule.this = r1;
            this.mPromise = promise;
        }

        @Override // android.app.DatePickerDialog.OnDateSetListener
        public void onDateSet(DatePicker datePicker, int i, int i2, int i3) {
            if (this.mPromiseResolved || !RNDatePickerDialogModule.this.getReactApplicationContext().hasActiveReactInstance()) {
                return;
            }
            WritableNativeMap writableNativeMap = new WritableNativeMap();
            writableNativeMap.putString("action", RNConstants.ACTION_DATE_SET);
            writableNativeMap.putInt("year", i);
            writableNativeMap.putInt("month", i2);
            writableNativeMap.putInt("day", i3);
            this.mPromise.resolve(writableNativeMap);
            this.mPromiseResolved = true;
        }

        @Override // android.content.DialogInterface.OnDismissListener
        public void onDismiss(DialogInterface dialogInterface) {
            if (this.mPromiseResolved || !RNDatePickerDialogModule.this.getReactApplicationContext().hasActiveReactInstance()) {
                return;
            }
            WritableNativeMap writableNativeMap = new WritableNativeMap();
            writableNativeMap.putString("action", RNConstants.ACTION_DISMISSED);
            this.mPromise.resolve(writableNativeMap);
            this.mPromiseResolved = true;
        }

        @Override // android.content.DialogInterface.OnClickListener
        public void onClick(DialogInterface dialogInterface, int i) {
            if (this.mPromiseResolved || !RNDatePickerDialogModule.this.getReactApplicationContext().hasActiveReactInstance()) {
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
            promise.reject(RNConstants.ERROR_NO_ACTIVITY, "Tried to open a DatePicker dialog while not attached to an Activity");
            return;
        }
        final FragmentManager supportFragmentManager = fragmentActivity.getSupportFragmentManager();
        UiThreadUtil.runOnUiThread(new Runnable() { // from class: com.reactcommunity.rndatetimepicker.RNDatePickerDialogModule.1
            @Override // java.lang.Runnable
            public void run() {
                ReadableMap readableMap2;
                RNDatePickerDialogFragment rNDatePickerDialogFragment = (RNDatePickerDialogFragment) supportFragmentManager.findFragmentByTag(RNDatePickerDialogModule.FRAGMENT_TAG);
                if (rNDatePickerDialogFragment != null && (readableMap2 = readableMap) != null) {
                    rNDatePickerDialogFragment.update(RNDatePickerDialogModule.this.createFragmentArguments(readableMap2));
                    return;
                }
                RNDatePickerDialogFragment rNDatePickerDialogFragment2 = new RNDatePickerDialogFragment();
                ReadableMap readableMap3 = readableMap;
                if (readableMap3 != null) {
                    rNDatePickerDialogFragment2.setArguments(RNDatePickerDialogModule.this.createFragmentArguments(readableMap3));
                }
                DatePickerDialogListener datePickerDialogListener = new DatePickerDialogListener(promise);
                rNDatePickerDialogFragment2.setOnDismissListener(datePickerDialogListener);
                rNDatePickerDialogFragment2.setOnDateSetListener(datePickerDialogListener);
                rNDatePickerDialogFragment2.setOnNeutralButtonActionListener(datePickerDialogListener);
                rNDatePickerDialogFragment2.show(supportFragmentManager, RNDatePickerDialogModule.FRAGMENT_TAG);
            }
        });
    }

    public Bundle createFragmentArguments(ReadableMap readableMap) {
        Bundle bundle = new Bundle();
        if (readableMap.hasKey(RNConstants.ARG_VALUE) && !readableMap.isNull(RNConstants.ARG_VALUE)) {
            bundle.putLong(RNConstants.ARG_VALUE, (long) readableMap.getDouble(RNConstants.ARG_VALUE));
        }
        if (readableMap.hasKey(RNConstants.ARG_MINDATE) && !readableMap.isNull(RNConstants.ARG_MINDATE)) {
            bundle.putLong(RNConstants.ARG_MINDATE, (long) readableMap.getDouble(RNConstants.ARG_MINDATE));
        }
        if (readableMap.hasKey(RNConstants.ARG_MAXDATE) && !readableMap.isNull(RNConstants.ARG_MAXDATE)) {
            bundle.putLong(RNConstants.ARG_MAXDATE, (long) readableMap.getDouble(RNConstants.ARG_MAXDATE));
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
        if (readableMap.hasKey(RNConstants.ARG_TZOFFSET_MINS) && !readableMap.isNull(RNConstants.ARG_TZOFFSET_MINS)) {
            bundle.putLong(RNConstants.ARG_TZOFFSET_MINS, (long) readableMap.getDouble(RNConstants.ARG_TZOFFSET_MINS));
        }
        return bundle;
    }
}
