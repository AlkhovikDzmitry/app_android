package com.reactcommunity.rndatetimepicker;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.util.TypedValue;
import android.widget.Button;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.FragmentActivity;
import com.facebook.react.bridge.Promise;
import java.util.Locale;

/* loaded from: classes2.dex */
public class Common {
    public static void dismissDialog(FragmentActivity fragmentActivity, String str, Promise promise) {
        if (fragmentActivity == null) {
            promise.reject(RNConstants.ERROR_NO_ACTIVITY, "Tried to close a " + str + " dialog while not attached to an Activity");
            return;
        }
        try {
            DialogFragment dialogFragment = (DialogFragment) fragmentActivity.getSupportFragmentManager().findFragmentByTag(str);
            boolean z = dialogFragment != null;
            if (z) {
                dialogFragment.dismiss();
            }
            promise.resolve(Boolean.valueOf(z));
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    public static int getDefaultDialogButtonTextColor(Context context) {
        TypedValue typedValue = new TypedValue();
        context.getTheme().resolveAttribute(16842806, typedValue, true);
        return ContextCompat.getColor(context, typedValue.resourceId != 0 ? typedValue.resourceId : typedValue.data);
    }

    public static DialogInterface.OnShowListener setButtonTextColor(final Context context, final AlertDialog alertDialog) {
        return new DialogInterface.OnShowListener() { // from class: com.reactcommunity.rndatetimepicker.Common.1
            @Override // android.content.DialogInterface.OnShowListener
            public void onShow(DialogInterface dialogInterface) {
                Button button = alertDialog.getButton(-1);
                Button button2 = alertDialog.getButton(-2);
                Button button3 = alertDialog.getButton(-3);
                int defaultDialogButtonTextColor = Common.getDefaultDialogButtonTextColor(context);
                if (button != null) {
                    button.setTextColor(defaultDialogButtonTextColor);
                }
                if (button2 != null) {
                    button2.setTextColor(defaultDialogButtonTextColor);
                }
                if (button3 != null) {
                    button3.setTextColor(defaultDialogButtonTextColor);
                }
            }
        };
    }

    public static RNTimePickerDisplay getDisplayTime(Bundle bundle) {
        RNTimePickerDisplay rNTimePickerDisplay = RNTimePickerDisplay.DEFAULT;
        return (bundle == null || bundle.getString("display", null) == null) ? rNTimePickerDisplay : RNTimePickerDisplay.valueOf(bundle.getString("display").toUpperCase(Locale.US));
    }

    public static RNDatePickerDisplay getDisplayDate(Bundle bundle) {
        RNDatePickerDisplay rNDatePickerDisplay = RNDatePickerDisplay.DEFAULT;
        return (bundle == null || bundle.getString("display", null) == null) ? rNDatePickerDisplay : RNDatePickerDisplay.valueOf(bundle.getString("display").toUpperCase(Locale.US));
    }
}
