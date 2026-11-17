package expo.modules.kotlin;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableType;
import kotlin.Metadata;
import kotlin.NoWhenBranchMatchedException;
import kotlin.jvm.internal.Intrinsics;
import kotlin.jvm.internal.Reflection;
import kotlin.reflect.KType;
import kotlin.reflect.full.KClassifiers;

@Metadata(m41d1 = {"\u0000\f\n\u0000\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\u001a\n\u0010\u0000\u001a\u00020\u0001*\u00020\u0002¨\u0006\u0003"}, m40d2 = {"toKType", "Lkotlin/reflect/KType;", "Lcom/facebook/react/bridge/ReadableType;", "expo-modules-core_release"}, m39k = 2, m38mv = {1, 6, 0}, m36xi = 48)
/* renamed from: expo.modules.kotlin.ReadableTypeExtensionsKt */
/* loaded from: classes2.dex */
public final class ReadableTypeExtensions {

    /* compiled from: ReadableTypeExtensions.kt */
    @Metadata(m39k = 3, m38mv = {1, 6, 0}, m36xi = 48)
    /* renamed from: expo.modules.kotlin.ReadableTypeExtensionsKt$WhenMappings */
    /* loaded from: classes2.dex */
    public /* synthetic */ class WhenMappings {
        public static final /* synthetic */ int[] $EnumSwitchMapping$0;

        static {
            int[] iArr = new int[ReadableType.values().length];
            iArr[ReadableType.Null.ordinal()] = 1;
            iArr[ReadableType.Boolean.ordinal()] = 2;
            iArr[ReadableType.Number.ordinal()] = 3;
            iArr[ReadableType.String.ordinal()] = 4;
            iArr[ReadableType.Map.ordinal()] = 5;
            iArr[ReadableType.Array.ordinal()] = 6;
            $EnumSwitchMapping$0 = iArr;
        }
    }

    public static final KType toKType(ReadableType readableType) {
        Intrinsics.checkNotNullParameter(readableType, "<this>");
        switch (WhenMappings.$EnumSwitchMapping$0[readableType.ordinal()]) {
            case 1:
                return KClassifiers.createType$default(Reflection.getOrCreateKotlinClass(Object.class), null, true, null, 5, null);
            case 2:
                return KClassifiers.createType$default(Reflection.getOrCreateKotlinClass(Boolean.TYPE), null, false, null, 7, null);
            case 3:
                return KClassifiers.createType$default(Reflection.getOrCreateKotlinClass(Number.class), null, false, null, 7, null);
            case 4:
                return KClassifiers.createType$default(Reflection.getOrCreateKotlinClass(String.class), null, false, null, 7, null);
            case 5:
                return KClassifiers.createType$default(Reflection.getOrCreateKotlinClass(ReadableMap.class), null, false, null, 7, null);
            case 6:
                return KClassifiers.createType$default(Reflection.getOrCreateKotlinClass(ReadableArray.class), null, false, null, 7, null);
            default:
                throw new NoWhenBranchMatchedException();
        }
    }
}
