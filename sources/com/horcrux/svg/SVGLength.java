package com.horcrux.svg;

import com.facebook.react.bridge.Dynamic;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableType;
import java.util.ArrayList;

/* loaded from: classes2.dex */
class SVGLength {
    final UnitType unit;
    final double value;

    /* loaded from: classes2.dex */
    public enum UnitType {
        UNKNOWN,
        NUMBER,
        PERCENTAGE,
        EMS,
        EXS,
        PX,
        CM,
        MM,
        IN,
        PT,
        PC
    }

    private SVGLength() {
        this.value = 0.0d;
        this.unit = UnitType.UNKNOWN;
    }

    public SVGLength(double d) {
        this.value = d;
        this.unit = UnitType.NUMBER;
    }

    private SVGLength(String str) {
        String trim = str.trim();
        int length = trim.length();
        int i = length - 1;
        if (length == 0 || trim.equals("normal")) {
            this.unit = UnitType.UNKNOWN;
            this.value = 0.0d;
        } else if (trim.codePointAt(i) == 37) {
            this.unit = UnitType.PERCENTAGE;
            this.value = Double.valueOf(trim.substring(0, i)).doubleValue();
        } else {
            int i2 = length - 2;
            if (i2 > 0) {
                String substring = trim.substring(i2);
                substring.hashCode();
                char c = 65535;
                switch (substring.hashCode()) {
                    case 3178:
                        if (substring.equals("cm")) {
                            c = 0;
                            break;
                        }
                        break;
                    case 3240:
                        if (substring.equals("em")) {
                            c = 1;
                            break;
                        }
                        break;
                    case 3251:
                        if (substring.equals("ex")) {
                            c = 2;
                            break;
                        }
                        break;
                    case 3365:
                        if (substring.equals("in")) {
                            c = 3;
                            break;
                        }
                        break;
                    case 3488:
                        if (substring.equals("mm")) {
                            c = 4;
                            break;
                        }
                        break;
                    case 3571:
                        if (substring.equals("pc")) {
                            c = 5;
                            break;
                        }
                        break;
                    case 3588:
                        if (substring.equals("pt")) {
                            c = 6;
                            break;
                        }
                        break;
                    case 3592:
                        if (substring.equals("px")) {
                            c = 7;
                            break;
                        }
                        break;
                }
                switch (c) {
                    case 0:
                        this.unit = UnitType.CM;
                        length = i2;
                        break;
                    case 1:
                        this.unit = UnitType.EMS;
                        length = i2;
                        break;
                    case 2:
                        this.unit = UnitType.EXS;
                        length = i2;
                        break;
                    case 3:
                        this.unit = UnitType.IN;
                        length = i2;
                        break;
                    case 4:
                        this.unit = UnitType.MM;
                        length = i2;
                        break;
                    case 5:
                        this.unit = UnitType.PC;
                        length = i2;
                        break;
                    case 6:
                        this.unit = UnitType.PT;
                        length = i2;
                        break;
                    case 7:
                        this.unit = UnitType.NUMBER;
                        length = i2;
                        break;
                    default:
                        this.unit = UnitType.NUMBER;
                        break;
                }
                this.value = Double.valueOf(trim.substring(0, length)).doubleValue();
                return;
            }
            this.unit = UnitType.NUMBER;
            this.value = Double.valueOf(trim).doubleValue();
        }
    }

    /* renamed from: com.horcrux.svg.SVGLength$1 */
    /* loaded from: classes2.dex */
    public static /* synthetic */ class C16581 {
        static final /* synthetic */ int[] $SwitchMap$com$facebook$react$bridge$ReadableType;

        static {
            int[] iArr = new int[ReadableType.values().length];
            $SwitchMap$com$facebook$react$bridge$ReadableType = iArr;
            try {
                iArr[ReadableType.Number.ordinal()] = 1;
            } catch (NoSuchFieldError unused) {
            }
            try {
                $SwitchMap$com$facebook$react$bridge$ReadableType[ReadableType.String.ordinal()] = 2;
            } catch (NoSuchFieldError unused2) {
            }
            try {
                $SwitchMap$com$facebook$react$bridge$ReadableType[ReadableType.Array.ordinal()] = 3;
            } catch (NoSuchFieldError unused3) {
            }
        }
    }

    public static SVGLength from(Dynamic dynamic) {
        int i = C16581.$SwitchMap$com$facebook$react$bridge$ReadableType[dynamic.getType().ordinal()];
        if (i != 1) {
            if (i == 2) {
                return new SVGLength(dynamic.asString());
            }
            return new SVGLength();
        }
        return new SVGLength(dynamic.asDouble());
    }

    public static SVGLength from(String str) {
        return new SVGLength(str);
    }

    public static SVGLength from(Double d) {
        return new SVGLength(d.doubleValue());
    }

    public static String toString(Dynamic dynamic) {
        int i = C16581.$SwitchMap$com$facebook$react$bridge$ReadableType[dynamic.getType().ordinal()];
        if (i != 1) {
            if (i != 2) {
                return null;
            }
            return dynamic.asString();
        }
        return String.valueOf(dynamic.asDouble());
    }

    public static ArrayList<SVGLength> arrayFrom(Dynamic dynamic) {
        int i = C16581.$SwitchMap$com$facebook$react$bridge$ReadableType[dynamic.getType().ordinal()];
        if (i == 1) {
            ArrayList<SVGLength> arrayList = new ArrayList<>(1);
            arrayList.add(new SVGLength(dynamic.asDouble()));
            return arrayList;
        } else if (i == 2) {
            ArrayList<SVGLength> arrayList2 = new ArrayList<>(1);
            arrayList2.add(new SVGLength(dynamic.asString()));
            return arrayList2;
        } else if (i != 3) {
            return null;
        } else {
            ReadableArray asArray = dynamic.asArray();
            int size = asArray.size();
            ArrayList<SVGLength> arrayList3 = new ArrayList<>(size);
            for (int i2 = 0; i2 < size; i2++) {
                arrayList3.add(from(asArray.getDynamic(i2)));
            }
            return arrayList3;
        }
    }

    public static ArrayList<SVGLength> arrayFrom(ReadableArray readableArray) {
        int size = readableArray.size();
        ArrayList<SVGLength> arrayList = new ArrayList<>(size);
        for (int i = 0; i < size; i++) {
            arrayList.add(from(readableArray.getDynamic(i)));
        }
        return arrayList;
    }
}
