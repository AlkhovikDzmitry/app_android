package kotlin.reflect.jvm.internal.impl.builtins;

import kotlin.jvm.internal.Intrinsics;
import kotlin.reflect.jvm.internal.impl.name.ClassId;
import kotlin.reflect.jvm.internal.impl.name.Name;

/* compiled from: UnsignedType.kt */
/* loaded from: classes2.dex */
public final class UnsignedType {
    private static final /* synthetic */ UnsignedType[] $VALUES;
    public static final UnsignedType UBYTE;
    public static final UnsignedType UINT;
    public static final UnsignedType ULONG;
    public static final UnsignedType USHORT;
    private final ClassId arrayClassId;
    private final ClassId classId;
    private final Name typeName;

    private static final /* synthetic */ UnsignedType[] $values() {
        return new UnsignedType[]{UBYTE, USHORT, UINT, ULONG};
    }

    public static UnsignedType valueOf(String str) {
        return (UnsignedType) Enum.valueOf(UnsignedType.class, str);
    }

    public static UnsignedType[] values() {
        return (UnsignedType[]) $VALUES.clone();
    }

    private UnsignedType(String str, int i, ClassId classId) {
        super(str, i);
        this.classId = classId;
        Name shortClassName = classId.getShortClassName();
        Intrinsics.checkNotNullExpressionValue(shortClassName, "classId.shortClassName");
        this.typeName = shortClassName;
        this.arrayClassId = new ClassId(classId.getPackageFqName(), Name.identifier(Intrinsics.stringPlus(shortClassName.asString(), "Array")));
    }

    public final ClassId getClassId() {
        return this.classId;
    }

    static {
        ClassId fromString = ClassId.fromString("kotlin/UByte");
        Intrinsics.checkNotNullExpressionValue(fromString, "fromString(\"kotlin/UByte\")");
        UBYTE = new UnsignedType("UBYTE", 0, fromString);
        ClassId fromString2 = ClassId.fromString("kotlin/UShort");
        Intrinsics.checkNotNullExpressionValue(fromString2, "fromString(\"kotlin/UShort\")");
        USHORT = new UnsignedType("USHORT", 1, fromString2);
        ClassId fromString3 = ClassId.fromString("kotlin/UInt");
        Intrinsics.checkNotNullExpressionValue(fromString3, "fromString(\"kotlin/UInt\")");
        UINT = new UnsignedType("UINT", 2, fromString3);
        ClassId fromString4 = ClassId.fromString("kotlin/ULong");
        Intrinsics.checkNotNullExpressionValue(fromString4, "fromString(\"kotlin/ULong\")");
        ULONG = new UnsignedType("ULONG", 3, fromString4);
        $VALUES = $values();
    }

    public final Name getTypeName() {
        return this.typeName;
    }

    public final ClassId getArrayClassId() {
        return this.arrayClassId;
    }
}
