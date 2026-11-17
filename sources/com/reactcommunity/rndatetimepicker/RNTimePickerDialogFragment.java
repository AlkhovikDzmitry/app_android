package com.reactcommunity.rndatetimepicker;

import android.app.Dialog;
import android.app.TimePickerDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.text.format.DateFormat;
import androidx.fragment.app.DialogFragment;

/* loaded from: classes2.dex */
public class RNTimePickerDialogFragment extends DialogFragment {
    private static DialogInterface.OnClickListener mOnNeutralButtonActionListener;
    private TimePickerDialog instance;
    private DialogInterface.OnDismissListener mOnDismissListener;
    private TimePickerDialog.OnTimeSetListener mOnTimeSetListener;

    @Override // androidx.fragment.app.DialogFragment
    public Dialog onCreateDialog(Bundle bundle) {
        TimePickerDialog createDialog = createDialog(getArguments(), getActivity(), this.mOnTimeSetListener);
        this.instance = createDialog;
        return createDialog;
    }

    public void update(Bundle bundle) {
        RNDate rNDate = new RNDate(bundle);
        this.instance.updateTime(rNDate.hour(), rNDate.minute());
    }

    static TimePickerDialog getDialog(Bundle bundle, Context context, TimePickerDialog.OnTimeSetListener onTimeSetListener) {
        RNDate rNDate = new RNDate(bundle);
        int hour = rNDate.hour();
        int minute = rNDate.minute();
        boolean is24HourFormat = DateFormat.is24HourFormat(context);
        if (bundle != null) {
            is24HourFormat = bundle.getBoolean(RNConstants.ARG_IS24HOUR, DateFormat.is24HourFormat(context));
        }
        boolean z = is24HourFormat;
        int i = (bundle == null || !MinuteIntervalSnappableTimePickerDialog.isValidMinuteInterval(bundle.getInt(RNConstants.ARG_INTERVAL))) ? 1 : bundle.getInt(RNConstants.ARG_INTERVAL);
        RNTimePickerDisplay displayTime = Common.getDisplayTime(bundle);
        if (displayTime == RNTimePickerDisplay.SPINNER) {
            return new RNDismissableTimePickerDialog(context, C1670R.style.SpinnerTimePickerDialog, onTimeSetListener, hour, minute, i, z, displayTime);
        }
        return new RNDismissableTimePickerDialog(context, onTimeSetListener, hour, minute, i, z, displayTime);
    }

    static TimePickerDialog createDialog(Bundle bundle, Context context, TimePickerDialog.OnTimeSetListener onTimeSetListener) {
        TimePickerDialog dialog = getDialog(bundle, context, onTimeSetListener);
        if (bundle != null) {
            if (bundle.containsKey(RNConstants.ARG_NEUTRAL_BUTTON_LABEL)) {
                dialog.setButton(-3, bundle.getString(RNConstants.ARG_NEUTRAL_BUTTON_LABEL), mOnNeutralButtonActionListener);
            }
            if (bundle.containsKey(RNConstants.ARG_POSITIVE_BUTTON_LABEL)) {
                dialog.setButton(-1, bundle.getString(RNConstants.ARG_POSITIVE_BUTTON_LABEL), dialog);
            }
            if (bundle.containsKey(RNConstants.ARG_NEGATIVE_BUTTON_LABEL)) {
                dialog.setButton(-2, bundle.getString(RNConstants.ARG_NEGATIVE_BUTTON_LABEL), dialog);
            }
            if (Common.getDisplayTime(bundle) == RNTimePickerDisplay.SPINNER) {
                dialog.setOnShowListener(Common.setButtonTextColor(context, dialog));
            }
        }
        return dialog;
    }

    @Override // androidx.fragment.app.DialogFragment, android.content.DialogInterface.OnDismissListener
    public void onDismiss(DialogInterface dialogInterface) {
        super.onDismiss(dialogInterface);
        DialogInterface.OnDismissListener onDismissListener = this.mOnDismissListener;
        if (onDismissListener != null) {
            onDismissListener.onDismiss(dialogInterface);
        }
    }

    public void setOnDismissListener(DialogInterface.OnDismissListener onDismissListener) {
        this.mOnDismissListener = onDismissListener;
    }

    public void setOnTimeSetListener(TimePickerDialog.OnTimeSetListener onTimeSetListener) {
        this.mOnTimeSetListener = onTimeSetListener;
    }

    public void setOnNeutralButtonActionListener(DialogInterface.OnClickListener onClickListener) {
        mOnNeutralButtonActionListener = onClickListener;
    }
}
