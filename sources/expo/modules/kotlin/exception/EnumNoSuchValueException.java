package expo.modules.kotlin.exception;

import com.reactcommunity.rndatetimepicker.RNConstants;
import kotlin.Metadata;
import kotlin.jvm.functions.Function1;
import kotlin.jvm.internal.Intrinsics;
import kotlin.jvm.internal.Lambda;

/* compiled from: CodedException.kt */
@Metadata(m41d1 = {"\u0000\"\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\u0010\u0010\n\u0000\n\u0002\u0010\u0011\n\u0000\n\u0002\u0010\u0000\n\u0002\b\u0002\b\u0000\u0018\u00002\u00020\u0001B5\u0012\u0010\u0010\u0002\u001a\f\u0012\b\u0012\u0006\u0012\u0002\b\u00030\u00040\u0003\u0012\u0012\u0010\u0005\u001a\u000e\u0012\n\b\u0001\u0012\u0006\u0012\u0002\b\u00030\u00040\u0006\u0012\b\u0010\u0007\u001a\u0004\u0018\u00010\b¢\u0006\u0002\u0010\t¨\u0006\n"}, m40d2 = {"Lexpo/modules/kotlin/exception/EnumNoSuchValueException;", "Lexpo/modules/kotlin/exception/CodedException;", "enumType", "Lkotlin/reflect/KClass;", "", "enumConstants", "", RNConstants.ARG_VALUE, "", "(Lkotlin/reflect/KClass;[Ljava/lang/Enum;Ljava/lang/Object;)V", "expo-modules-core_release"}, m39k = 1, m38mv = {1, 6, 0}, m36xi = 48)
/* loaded from: classes2.dex */
public final class EnumNoSuchValueException extends CodedException {

    /* JADX INFO: Access modifiers changed from: package-private */
    /* compiled from: CodedException.kt */
    @Metadata(m41d1 = {"\u0000\u000e\n\u0000\n\u0002\u0010\r\n\u0000\n\u0002\u0010\u0010\n\u0000\u0010\u0000\u001a\u00020\u00012\n\u0010\u0002\u001a\u0006\u0012\u0002\b\u00030\u0003H\n¢\u0006\u0002\b\u0004"}, m40d2 = {"<anonymous>", "", "it", "", "invoke"}, m39k = 3, m38mv = {1, 6, 0}, m36xi = 48)
    /* renamed from: expo.modules.kotlin.exception.EnumNoSuchValueException$1 */
    /* loaded from: classes2.dex */
    public static final class C19021 extends Lambda implements Function1<Enum<?>, CharSequence> {
        @Override // kotlin.jvm.functions.Function1
        public final CharSequence invoke(Enum<?> it) {
            Intrinsics.checkNotNullParameter(it, "it");
            String name = it.name();
            return "'" + name + "'";
        }
    }

    /* JADX WARN: Illegal instructions before constructor call */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public EnumNoSuchValueException(kotlin.reflect.KClass<java.lang.Enum<?>> r11, java.lang.Enum<?>[] r12, java.lang.Object r13) {
        /*
            r10 = this;
            java.lang.String r0 = "enumType"
            kotlin.jvm.internal.Intrinsics.checkNotNullParameter(r11, r0)
            java.lang.String r0 = "enumConstants"
            kotlin.jvm.internal.Intrinsics.checkNotNullParameter(r12, r0)
            java.lang.String r11 = r11.getSimpleName()
            java.lang.String r0 = ", "
            r2 = r0
            java.lang.CharSequence r2 = (java.lang.CharSequence) r2
            expo.modules.kotlin.exception.EnumNoSuchValueException$1 r0 = expo.modules.kotlin.exception.EnumNoSuchValueException.C19021.INSTANCE
            r7 = r0
            kotlin.jvm.functions.Function1 r7 = (kotlin.jvm.functions.Function1) r7
            r3 = 0
            r4 = 0
            r5 = 0
            r6 = 0
            r8 = 30
            r9 = 0
            r1 = r12
            java.lang.String r12 = kotlin.collections.ArraysKt.joinToString$default(r1, r2, r3, r4, r5, r6, r7, r8, r9)
            java.lang.StringBuilder r0 = new java.lang.StringBuilder
            r0.<init>()
            java.lang.String r1 = "'"
            r0.append(r1)
            r0.append(r13)
            java.lang.String r13 = "' is not present in "
            r0.append(r13)
            r0.append(r11)
            java.lang.String r11 = " enum, it must be one of: "
            r0.append(r11)
            r0.append(r12)
            java.lang.String r11 = r0.toString()
            r12 = 0
            r13 = 2
            r10.<init>(r11, r12, r13, r12)
            return
        */
        throw new UnsupportedOperationException("Method not decompiled: expo.modules.kotlin.exception.EnumNoSuchValueException.<init>(kotlin.reflect.KClass, java.lang.Enum[], java.lang.Object):void");
    }
}
