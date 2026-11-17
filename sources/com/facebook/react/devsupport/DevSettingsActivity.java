package com.facebook.react.devsupport;

import android.os.Bundle;
import android.preference.PreferenceActivity;
import com.facebook.react.C1040R;

/* loaded from: classes.dex */
public class DevSettingsActivity extends PreferenceActivity {
    @Override // android.preference.PreferenceActivity, android.app.Activity
    public void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setTitle(getApplication().getResources().getString(C1040R.string.catalyst_settings_title));
        addPreferencesFromResource(C1040R.xml.rn_dev_preferences);
    }
}
