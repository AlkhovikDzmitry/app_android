package com.facebook.react.uimanager.layoutanimation;

/* JADX INFO: Access modifiers changed from: package-private */
/* loaded from: classes.dex */
public enum LayoutAnimationType {
    CREATE,
    UPDATE,
    DELETE;

    /* JADX INFO: Access modifiers changed from: package-private */
    /* renamed from: com.facebook.react.uimanager.layoutanimation.LayoutAnimationType$1 */
    /* loaded from: classes.dex */
    public static /* synthetic */ class C13261 {

        /* renamed from: $SwitchMap$com$facebook$react$uimanager$layoutanimation$LayoutAnimationType */
        static final /* synthetic */ int[] f114x364296ff;

        static {
            int[] iArr = new int[LayoutAnimationType.values().length];
            f114x364296ff = iArr;
            try {
                iArr[LayoutAnimationType.CREATE.ordinal()] = 1;
            } catch (NoSuchFieldError unused) {
            }
            try {
                f114x364296ff[LayoutAnimationType.UPDATE.ordinal()] = 2;
            } catch (NoSuchFieldError unused2) {
            }
            try {
                f114x364296ff[LayoutAnimationType.DELETE.ordinal()] = 3;
            } catch (NoSuchFieldError unused3) {
            }
        }
    }

    public static String toString(LayoutAnimationType layoutAnimationType) {
        int i = C13261.f114x364296ff[layoutAnimationType.ordinal()];
        if (i != 1) {
            if (i != 2) {
                if (i == 3) {
                    return "delete";
                }
                throw new IllegalArgumentException("Unsupported LayoutAnimationType: " + layoutAnimationType);
            }
            return "update";
        }
        return "create";
    }
}
