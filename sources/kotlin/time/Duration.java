package kotlin.time;

import androidx.autofill.HintConstants;
import com.reactcommunity.rndatetimepicker.RNConstants;
import kotlin.Deprecated;
import kotlin.DeprecatedSinceKotlin;
import kotlin.Metadata;
import kotlin.ReplaceWith;
import kotlin.comparisons.ComparisonsKt;
import kotlin.jvm.JvmInline;
import kotlin.jvm.functions.Function2;
import kotlin.jvm.functions.Function3;
import kotlin.jvm.functions.Function4;
import kotlin.jvm.functions.Function5;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;
import kotlin.math.MathKt;
import kotlin.ranges.LongRange;
import kotlin.ranges.RangesKt;
import kotlin.text.StringsKt;
import okhttp3.internal.http2.Http2Connection;
import org.apache.commons.p018io.FilenameUtils;

/* compiled from: Duration.kt */
@Metadata(m41d1 = {"\u0000n\n\u0002\u0018\u0002\n\u0002\u0010\u000f\n\u0000\n\u0002\u0010\t\n\u0002\b\u0005\n\u0002\u0010\b\n\u0002\b\u0005\n\u0002\u0010\u0006\n\u0002\b-\n\u0002\u0018\u0002\n\u0002\b\u0017\n\u0002\u0010\u000b\n\u0002\u0010\u0000\n\u0002\b\u001b\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\b\b\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\t\n\u0002\u0010\u000e\n\u0002\b\u0010\n\u0002\u0010\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\b\b\b\u0087@\u0018\u0000 ¤\u00012\b\u0012\u0004\u0012\u00020\u00000\u0001:\u0002¤\u0001B\u0014\b\u0000\u0012\u0006\u0010\u0002\u001a\u00020\u0003ø\u0001\u0000¢\u0006\u0004\b\u0004\u0010\u0005J%\u0010D\u001a\u00020\u00002\u0006\u0010E\u001a\u00020\u00032\u0006\u0010F\u001a\u00020\u0003H\u0002ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\bG\u0010HJ\u001b\u0010I\u001a\u00020\t2\u0006\u0010J\u001a\u00020\u0000H\u0096\u0002ø\u0001\u0000¢\u0006\u0004\bK\u0010LJ\u001e\u0010M\u001a\u00020\u00002\u0006\u0010N\u001a\u00020\u000fH\u0086\u0002ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\bO\u0010PJ\u001e\u0010M\u001a\u00020\u00002\u0006\u0010N\u001a\u00020\tH\u0086\u0002ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\bO\u0010QJ\u001b\u0010M\u001a\u00020\u000f2\u0006\u0010J\u001a\u00020\u0000H\u0086\u0002ø\u0001\u0000¢\u0006\u0004\bR\u0010SJ\u001a\u0010T\u001a\u00020U2\b\u0010J\u001a\u0004\u0018\u00010VHÖ\u0003¢\u0006\u0004\bW\u0010XJ\u0010\u0010Y\u001a\u00020\tHÖ\u0001¢\u0006\u0004\bZ\u0010\rJ\r\u0010[\u001a\u00020U¢\u0006\u0004\b\\\u0010]J\u000f\u0010^\u001a\u00020UH\u0002¢\u0006\u0004\b_\u0010]J\u000f\u0010`\u001a\u00020UH\u0002¢\u0006\u0004\ba\u0010]J\r\u0010b\u001a\u00020U¢\u0006\u0004\bc\u0010]J\r\u0010d\u001a\u00020U¢\u0006\u0004\be\u0010]J\r\u0010f\u001a\u00020U¢\u0006\u0004\bg\u0010]J\u001b\u0010h\u001a\u00020\u00002\u0006\u0010J\u001a\u00020\u0000H\u0086\u0002ø\u0001\u0000¢\u0006\u0004\bi\u0010jJ\u001b\u0010k\u001a\u00020\u00002\u0006\u0010J\u001a\u00020\u0000H\u0086\u0002ø\u0001\u0000¢\u0006\u0004\bl\u0010jJ\u001e\u0010m\u001a\u00020\u00002\u0006\u0010N\u001a\u00020\u000fH\u0086\u0002ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\bn\u0010PJ\u001e\u0010m\u001a\u00020\u00002\u0006\u0010N\u001a\u00020\tH\u0086\u0002ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\bn\u0010QJ\u009d\u0001\u0010o\u001a\u0002Hp\"\u0004\b\u0000\u0010p2u\u0010q\u001aq\u0012\u0013\u0012\u00110\u0003¢\u0006\f\bs\u0012\b\bt\u0012\u0004\b\b(u\u0012\u0013\u0012\u00110\t¢\u0006\f\bs\u0012\b\bt\u0012\u0004\b\b(v\u0012\u0013\u0012\u00110\t¢\u0006\f\bs\u0012\b\bt\u0012\u0004\b\b(w\u0012\u0013\u0012\u00110\t¢\u0006\f\bs\u0012\b\bt\u0012\u0004\b\b(x\u0012\u0013\u0012\u00110\t¢\u0006\f\bs\u0012\b\bt\u0012\u0004\b\b(y\u0012\u0004\u0012\u0002Hp0rH\u0086\bø\u0001\u0002\u0082\u0002\n\n\b\b\u0001\u0012\u0002\u0010\u0001 \u0001¢\u0006\u0004\bz\u0010{J\u0088\u0001\u0010o\u001a\u0002Hp\"\u0004\b\u0000\u0010p2`\u0010q\u001a\\\u0012\u0013\u0012\u00110\u0003¢\u0006\f\bs\u0012\b\bt\u0012\u0004\b\b(v\u0012\u0013\u0012\u00110\t¢\u0006\f\bs\u0012\b\bt\u0012\u0004\b\b(w\u0012\u0013\u0012\u00110\t¢\u0006\f\bs\u0012\b\bt\u0012\u0004\b\b(x\u0012\u0013\u0012\u00110\t¢\u0006\f\bs\u0012\b\bt\u0012\u0004\b\b(y\u0012\u0004\u0012\u0002Hp0|H\u0086\bø\u0001\u0002\u0082\u0002\n\n\b\b\u0001\u0012\u0002\u0010\u0001 \u0001¢\u0006\u0004\bz\u0010}Js\u0010o\u001a\u0002Hp\"\u0004\b\u0000\u0010p2K\u0010q\u001aG\u0012\u0013\u0012\u00110\u0003¢\u0006\f\bs\u0012\b\bt\u0012\u0004\b\b(w\u0012\u0013\u0012\u00110\t¢\u0006\f\bs\u0012\b\bt\u0012\u0004\b\b(x\u0012\u0013\u0012\u00110\t¢\u0006\f\bs\u0012\b\bt\u0012\u0004\b\b(y\u0012\u0004\u0012\u0002Hp0~H\u0086\bø\u0001\u0002\u0082\u0002\n\n\b\b\u0001\u0012\u0002\u0010\u0001 \u0001¢\u0006\u0004\bz\u0010\u007fJ`\u0010o\u001a\u0002Hp\"\u0004\b\u0000\u0010p27\u0010q\u001a3\u0012\u0013\u0012\u00110\u0003¢\u0006\f\bs\u0012\b\bt\u0012\u0004\b\b(x\u0012\u0013\u0012\u00110\t¢\u0006\f\bs\u0012\b\bt\u0012\u0004\b\b(y\u0012\u0004\u0012\u0002Hp0\u0080\u0001H\u0086\bø\u0001\u0002\u0082\u0002\n\n\b\b\u0001\u0012\u0002\u0010\u0001 \u0001¢\u0006\u0005\bz\u0010\u0081\u0001J\u0019\u0010\u0082\u0001\u001a\u00020\u000f2\u0007\u0010\u0083\u0001\u001a\u00020=¢\u0006\u0006\b\u0084\u0001\u0010\u0085\u0001J\u0019\u0010\u0086\u0001\u001a\u00020\t2\u0007\u0010\u0083\u0001\u001a\u00020=¢\u0006\u0006\b\u0087\u0001\u0010\u0088\u0001J\u0011\u0010\u0089\u0001\u001a\u00030\u008a\u0001¢\u0006\u0006\b\u008b\u0001\u0010\u008c\u0001J\u0019\u0010\u008d\u0001\u001a\u00020\u00032\u0007\u0010\u0083\u0001\u001a\u00020=¢\u0006\u0006\b\u008e\u0001\u0010\u008f\u0001J\u0011\u0010\u0090\u0001\u001a\u00020\u0003H\u0007¢\u0006\u0005\b\u0091\u0001\u0010\u0005J\u0011\u0010\u0092\u0001\u001a\u00020\u0003H\u0007¢\u0006\u0005\b\u0093\u0001\u0010\u0005J\u0013\u0010\u0094\u0001\u001a\u00030\u008a\u0001H\u0016¢\u0006\u0006\b\u0095\u0001\u0010\u008c\u0001J%\u0010\u0094\u0001\u001a\u00030\u008a\u00012\u0007\u0010\u0083\u0001\u001a\u00020=2\t\b\u0002\u0010\u0096\u0001\u001a\u00020\t¢\u0006\u0006\b\u0095\u0001\u0010\u0097\u0001J\u0018\u0010\u0098\u0001\u001a\u00020\u0000H\u0086\u0002ø\u0001\u0001ø\u0001\u0000¢\u0006\u0005\b\u0099\u0001\u0010\u0005JK\u0010\u009a\u0001\u001a\u00030\u009b\u0001*\b0\u009c\u0001j\u0003`\u009d\u00012\u0007\u0010\u009e\u0001\u001a\u00020\t2\u0007\u0010\u009f\u0001\u001a\u00020\t2\u0007\u0010 \u0001\u001a\u00020\t2\b\u0010\u0083\u0001\u001a\u00030\u008a\u00012\u0007\u0010¡\u0001\u001a\u00020UH\u0002¢\u0006\u0006\b¢\u0001\u0010£\u0001R\u0017\u0010\u0006\u001a\u00020\u00008Fø\u0001\u0000ø\u0001\u0001¢\u0006\u0006\u001a\u0004\b\u0007\u0010\u0005R\u001a\u0010\b\u001a\u00020\t8@X\u0081\u0004¢\u0006\f\u0012\u0004\b\n\u0010\u000b\u001a\u0004\b\f\u0010\rR\u001a\u0010\u000e\u001a\u00020\u000f8FX\u0087\u0004¢\u0006\f\u0012\u0004\b\u0010\u0010\u000b\u001a\u0004\b\u0011\u0010\u0012R\u001a\u0010\u0013\u001a\u00020\u000f8FX\u0087\u0004¢\u0006\f\u0012\u0004\b\u0014\u0010\u000b\u001a\u0004\b\u0015\u0010\u0012R\u001a\u0010\u0016\u001a\u00020\u000f8FX\u0087\u0004¢\u0006\f\u0012\u0004\b\u0017\u0010\u000b\u001a\u0004\b\u0018\u0010\u0012R\u001a\u0010\u0019\u001a\u00020\u000f8FX\u0087\u0004¢\u0006\f\u0012\u0004\b\u001a\u0010\u000b\u001a\u0004\b\u001b\u0010\u0012R\u001a\u0010\u001c\u001a\u00020\u000f8FX\u0087\u0004¢\u0006\f\u0012\u0004\b\u001d\u0010\u000b\u001a\u0004\b\u001e\u0010\u0012R\u001a\u0010\u001f\u001a\u00020\u000f8FX\u0087\u0004¢\u0006\f\u0012\u0004\b \u0010\u000b\u001a\u0004\b!\u0010\u0012R\u001a\u0010\"\u001a\u00020\u000f8FX\u0087\u0004¢\u0006\f\u0012\u0004\b#\u0010\u000b\u001a\u0004\b$\u0010\u0012R\u0011\u0010%\u001a\u00020\u00038F¢\u0006\u0006\u001a\u0004\b&\u0010\u0005R\u0011\u0010'\u001a\u00020\u00038F¢\u0006\u0006\u001a\u0004\b(\u0010\u0005R\u0011\u0010)\u001a\u00020\u00038F¢\u0006\u0006\u001a\u0004\b*\u0010\u0005R\u0011\u0010+\u001a\u00020\u00038F¢\u0006\u0006\u001a\u0004\b,\u0010\u0005R\u0011\u0010-\u001a\u00020\u00038F¢\u0006\u0006\u001a\u0004\b.\u0010\u0005R\u0011\u0010/\u001a\u00020\u00038F¢\u0006\u0006\u001a\u0004\b0\u0010\u0005R\u0011\u00101\u001a\u00020\u00038F¢\u0006\u0006\u001a\u0004\b2\u0010\u0005R\u001a\u00103\u001a\u00020\t8@X\u0081\u0004¢\u0006\f\u0012\u0004\b4\u0010\u000b\u001a\u0004\b5\u0010\rR\u001a\u00106\u001a\u00020\t8@X\u0081\u0004¢\u0006\f\u0012\u0004\b7\u0010\u000b\u001a\u0004\b8\u0010\rR\u000e\u0010\u0002\u001a\u00020\u0003X\u0082\u0004¢\u0006\u0002\n\u0000R\u001a\u00109\u001a\u00020\t8@X\u0081\u0004¢\u0006\f\u0012\u0004\b:\u0010\u000b\u001a\u0004\b;\u0010\rR\u0014\u0010<\u001a\u00020=8BX\u0082\u0004¢\u0006\u0006\u001a\u0004\b>\u0010?R\u0015\u0010@\u001a\u00020\t8Â\u0002X\u0082\u0004¢\u0006\u0006\u001a\u0004\bA\u0010\rR\u0014\u0010B\u001a\u00020\u00038BX\u0082\u0004¢\u0006\u0006\u001a\u0004\bC\u0010\u0005\u0088\u0001\u0002\u0092\u0001\u00020\u0003ø\u0001\u0000\u0082\u0002\u000f\n\u0002\b\u0019\n\u0002\b!\n\u0005\b\u009920\u0001¨\u0006¥\u0001"}, m40d2 = {"Lkotlin/time/Duration;", "", "rawValue", "", "constructor-impl", "(J)J", "absoluteValue", "getAbsoluteValue-UwyO8pc", "hoursComponent", "", "getHoursComponent$annotations", "()V", "getHoursComponent-impl", "(J)I", "inDays", "", "getInDays$annotations", "getInDays-impl", "(J)D", "inHours", "getInHours$annotations", "getInHours-impl", "inMicroseconds", "getInMicroseconds$annotations", "getInMicroseconds-impl", "inMilliseconds", "getInMilliseconds$annotations", "getInMilliseconds-impl", "inMinutes", "getInMinutes$annotations", "getInMinutes-impl", "inNanoseconds", "getInNanoseconds$annotations", "getInNanoseconds-impl", "inSeconds", "getInSeconds$annotations", "getInSeconds-impl", "inWholeDays", "getInWholeDays-impl", "inWholeHours", "getInWholeHours-impl", "inWholeMicroseconds", "getInWholeMicroseconds-impl", "inWholeMilliseconds", "getInWholeMilliseconds-impl", "inWholeMinutes", "getInWholeMinutes-impl", "inWholeNanoseconds", "getInWholeNanoseconds-impl", "inWholeSeconds", "getInWholeSeconds-impl", "minutesComponent", "getMinutesComponent$annotations", "getMinutesComponent-impl", "nanosecondsComponent", "getNanosecondsComponent$annotations", "getNanosecondsComponent-impl", "secondsComponent", "getSecondsComponent$annotations", "getSecondsComponent-impl", "storageUnit", "Lkotlin/time/DurationUnit;", "getStorageUnit-impl", "(J)Lkotlin/time/DurationUnit;", "unitDiscriminator", "getUnitDiscriminator-impl", RNConstants.ARG_VALUE, "getValue-impl", "addValuesMixedRanges", "thisMillis", "otherNanos", "addValuesMixedRanges-UwyO8pc", "(JJJ)J", "compareTo", "other", "compareTo-LRDsOJo", "(JJ)I", "div", "scale", "div-UwyO8pc", "(JD)J", "(JI)J", "div-LRDsOJo", "(JJ)D", "equals", "", "", "equals-impl", "(JLjava/lang/Object;)Z", "hashCode", "hashCode-impl", "isFinite", "isFinite-impl", "(J)Z", "isInMillis", "isInMillis-impl", "isInNanos", "isInNanos-impl", "isInfinite", "isInfinite-impl", "isNegative", "isNegative-impl", "isPositive", "isPositive-impl", "minus", "minus-LRDsOJo", "(JJ)J", "plus", "plus-LRDsOJo", "times", "times-UwyO8pc", "toComponents", "T", "action", "Lkotlin/Function5;", "Lkotlin/ParameterName;", HintConstants.AUTOFILL_HINT_NAME, "days", "hours", "minutes", "seconds", "nanoseconds", "toComponents-impl", "(JLkotlin/jvm/functions/Function5;)Ljava/lang/Object;", "Lkotlin/Function4;", "(JLkotlin/jvm/functions/Function4;)Ljava/lang/Object;", "Lkotlin/Function3;", "(JLkotlin/jvm/functions/Function3;)Ljava/lang/Object;", "Lkotlin/Function2;", "(JLkotlin/jvm/functions/Function2;)Ljava/lang/Object;", "toDouble", "unit", "toDouble-impl", "(JLkotlin/time/DurationUnit;)D", "toInt", "toInt-impl", "(JLkotlin/time/DurationUnit;)I", "toIsoString", "", "toIsoString-impl", "(J)Ljava/lang/String;", "toLong", "toLong-impl", "(JLkotlin/time/DurationUnit;)J", "toLongMilliseconds", "toLongMilliseconds-impl", "toLongNanoseconds", "toLongNanoseconds-impl", "toString", "toString-impl", "decimals", "(JLkotlin/time/DurationUnit;I)Ljava/lang/String;", "unaryMinus", "unaryMinus-UwyO8pc", "appendFractional", "", "Ljava/lang/StringBuilder;", "Lkotlin/text/StringBuilder;", "whole", "fractional", "fractionalSize", "isoZeroes", "appendFractional-impl", "(JLjava/lang/StringBuilder;IIILjava/lang/String;Z)V", "Companion", "kotlin-stdlib"}, m39k = 1, m38mv = {1, 7, 1}, m36xi = 48)
@JvmInline
/* loaded from: classes3.dex */
public final class Duration implements Comparable<Duration> {
    private final long rawValue;
    public static final Companion Companion = new Companion(null);
    private static final long ZERO = m1804constructorimpl(0);
    private static final long INFINITE = DurationKt.access$durationOfMillis(DurationKt.MAX_MILLIS);
    private static final long NEG_INFINITE = DurationKt.access$durationOfMillis(-4611686018427387903L);

    /* renamed from: box-impl */
    public static final /* synthetic */ Duration m1802boximpl(long j) {
        return new Duration(j);
    }

    /* renamed from: equals-impl */
    public static boolean m1808equalsimpl(long j, Object obj) {
        return (obj instanceof Duration) && j == ((Duration) obj).m1858unboximpl();
    }

    /* renamed from: equals-impl0 */
    public static final boolean m1809equalsimpl0(long j, long j2) {
        return j == j2;
    }

    public static /* synthetic */ void getHoursComponent$annotations() {
    }

    @Deprecated(message = "Use inWholeDays property instead or convert toDouble(DAYS) if a double value is required.", replaceWith = @ReplaceWith(expression = "toDouble(DurationUnit.DAYS)", imports = {}))
    public static /* synthetic */ void getInDays$annotations() {
    }

    @Deprecated(message = "Use inWholeHours property instead or convert toDouble(HOURS) if a double value is required.", replaceWith = @ReplaceWith(expression = "toDouble(DurationUnit.HOURS)", imports = {}))
    public static /* synthetic */ void getInHours$annotations() {
    }

    @Deprecated(message = "Use inWholeMicroseconds property instead or convert toDouble(MICROSECONDS) if a double value is required.", replaceWith = @ReplaceWith(expression = "toDouble(DurationUnit.MICROSECONDS)", imports = {}))
    public static /* synthetic */ void getInMicroseconds$annotations() {
    }

    @Deprecated(message = "Use inWholeMilliseconds property instead or convert toDouble(MILLISECONDS) if a double value is required.", replaceWith = @ReplaceWith(expression = "toDouble(DurationUnit.MILLISECONDS)", imports = {}))
    public static /* synthetic */ void getInMilliseconds$annotations() {
    }

    @Deprecated(message = "Use inWholeMinutes property instead or convert toDouble(MINUTES) if a double value is required.", replaceWith = @ReplaceWith(expression = "toDouble(DurationUnit.MINUTES)", imports = {}))
    public static /* synthetic */ void getInMinutes$annotations() {
    }

    @Deprecated(message = "Use inWholeNanoseconds property instead or convert toDouble(NANOSECONDS) if a double value is required.", replaceWith = @ReplaceWith(expression = "toDouble(DurationUnit.NANOSECONDS)", imports = {}))
    public static /* synthetic */ void getInNanoseconds$annotations() {
    }

    @Deprecated(message = "Use inWholeSeconds property instead or convert toDouble(SECONDS) if a double value is required.", replaceWith = @ReplaceWith(expression = "toDouble(DurationUnit.SECONDS)", imports = {}))
    public static /* synthetic */ void getInSeconds$annotations() {
    }

    public static /* synthetic */ void getMinutesComponent$annotations() {
    }

    public static /* synthetic */ void getNanosecondsComponent$annotations() {
    }

    public static /* synthetic */ void getSecondsComponent$annotations() {
    }

    /* renamed from: getUnitDiscriminator-impl */
    private static final int m1830getUnitDiscriminatorimpl(long j) {
        return ((int) j) & 1;
    }

    /* renamed from: getValue-impl */
    private static final long m1831getValueimpl(long j) {
        return j >> 1;
    }

    /* renamed from: hashCode-impl */
    public static int m1832hashCodeimpl(long j) {
        return (int) (j ^ (j >>> 32));
    }

    /* renamed from: isInMillis-impl */
    private static final boolean m1834isInMillisimpl(long j) {
        return (((int) j) & 1) == 1;
    }

    /* renamed from: isInNanos-impl */
    private static final boolean m1835isInNanosimpl(long j) {
        return (((int) j) & 1) == 0;
    }

    /* renamed from: isNegative-impl */
    public static final boolean m1837isNegativeimpl(long j) {
        return j < 0;
    }

    /* renamed from: isPositive-impl */
    public static final boolean m1838isPositiveimpl(long j) {
        return j > 0;
    }

    public boolean equals(Object obj) {
        return m1808equalsimpl(this.rawValue, obj);
    }

    public int hashCode() {
        return m1832hashCodeimpl(this.rawValue);
    }

    /* renamed from: unbox-impl */
    public final /* synthetic */ long m1858unboximpl() {
        return this.rawValue;
    }

    @Override // java.lang.Comparable
    public /* bridge */ /* synthetic */ int compareTo(Duration duration) {
        return m1857compareToLRDsOJo(duration.m1858unboximpl());
    }

    private /* synthetic */ Duration(long j) {
        this.rawValue = j;
    }

    /* renamed from: getStorageUnit-impl */
    private static final DurationUnitJvm m1829getStorageUnitimpl(long j) {
        return m1835isInNanosimpl(j) ? DurationUnitJvm.NANOSECONDS : DurationUnitJvm.MILLISECONDS;
    }

    /* renamed from: constructor-impl */
    public static long m1804constructorimpl(long j) {
        if (DurationJvm.getDurationAssertionsEnabled()) {
            if (m1835isInNanosimpl(j)) {
                if (!new LongRange(-4611686018426999999L, DurationKt.MAX_NANOS).contains(m1831getValueimpl(j))) {
                    throw new AssertionError(m1831getValueimpl(j) + " ns is out of nanoseconds range");
                }
            } else if (!new LongRange(-4611686018427387903L, DurationKt.MAX_MILLIS).contains(m1831getValueimpl(j))) {
                throw new AssertionError(m1831getValueimpl(j) + " ms is out of milliseconds range");
            } else if (new LongRange(-4611686018426L, 4611686018426L).contains(m1831getValueimpl(j))) {
                throw new AssertionError(m1831getValueimpl(j) + " ms is denormalized");
            }
        }
        return j;
    }

    /* compiled from: Duration.kt */
    @Metadata(m41d1 = {"\u0000<\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0002\b\b\n\u0002\u0010\u0006\n\u0002\b\u0004\n\u0002\u0010\b\n\u0002\b\u0002\n\u0002\u0010\t\n\u0002\b\u0017\n\u0002\u0018\u0002\n\u0002\b\b\n\u0002\u0010\u000e\n\u0002\b\n\b\u0086\u0003\u0018\u00002\u00020\u0001B\u0007\b\u0002¢\u0006\u0002\u0010\u0002J \u0010*\u001a\u00020\r2\u0006\u0010+\u001a\u00020\r2\u0006\u0010,\u001a\u00020-2\u0006\u0010.\u001a\u00020-H\u0007J\u001d\u0010\f\u001a\u00020\u00042\u0006\u0010+\u001a\u00020\rH\u0007ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\b/\u0010\u0011J\u001d\u0010\f\u001a\u00020\u00042\u0006\u0010+\u001a\u00020\u0012H\u0007ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\b/\u0010\u0014J\u001d\u0010\f\u001a\u00020\u00042\u0006\u0010+\u001a\u00020\u0015H\u0007ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\b/\u0010\u0017J\u001d\u0010\u0018\u001a\u00020\u00042\u0006\u0010+\u001a\u00020\rH\u0007ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\b0\u0010\u0011J\u001d\u0010\u0018\u001a\u00020\u00042\u0006\u0010+\u001a\u00020\u0012H\u0007ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\b0\u0010\u0014J\u001d\u0010\u0018\u001a\u00020\u00042\u0006\u0010+\u001a\u00020\u0015H\u0007ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\b0\u0010\u0017J\u001d\u0010\u001b\u001a\u00020\u00042\u0006\u0010+\u001a\u00020\rH\u0007ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\b1\u0010\u0011J\u001d\u0010\u001b\u001a\u00020\u00042\u0006\u0010+\u001a\u00020\u0012H\u0007ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\b1\u0010\u0014J\u001d\u0010\u001b\u001a\u00020\u00042\u0006\u0010+\u001a\u00020\u0015H\u0007ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\b1\u0010\u0017J\u001d\u0010\u001e\u001a\u00020\u00042\u0006\u0010+\u001a\u00020\rH\u0007ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\b2\u0010\u0011J\u001d\u0010\u001e\u001a\u00020\u00042\u0006\u0010+\u001a\u00020\u0012H\u0007ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\b2\u0010\u0014J\u001d\u0010\u001e\u001a\u00020\u00042\u0006\u0010+\u001a\u00020\u0015H\u0007ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\b2\u0010\u0017J\u001d\u0010!\u001a\u00020\u00042\u0006\u0010+\u001a\u00020\rH\u0007ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\b3\u0010\u0011J\u001d\u0010!\u001a\u00020\u00042\u0006\u0010+\u001a\u00020\u0012H\u0007ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\b3\u0010\u0014J\u001d\u0010!\u001a\u00020\u00042\u0006\u0010+\u001a\u00020\u0015H\u0007ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\b3\u0010\u0017J\u001d\u0010$\u001a\u00020\u00042\u0006\u0010+\u001a\u00020\rH\u0007ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\b4\u0010\u0011J\u001d\u0010$\u001a\u00020\u00042\u0006\u0010+\u001a\u00020\u0012H\u0007ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\b4\u0010\u0014J\u001d\u0010$\u001a\u00020\u00042\u0006\u0010+\u001a\u00020\u0015H\u0007ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\b4\u0010\u0017J\u001b\u00105\u001a\u00020\u00042\u0006\u0010+\u001a\u000206ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\b7\u00108J\u001b\u00109\u001a\u00020\u00042\u0006\u0010+\u001a\u000206ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\b:\u00108J\u001b\u0010;\u001a\u0004\u0018\u00010\u00042\u0006\u0010+\u001a\u000206ø\u0001\u0001ø\u0001\u0000¢\u0006\u0002\b<J\u001b\u0010=\u001a\u0004\u0018\u00010\u00042\u0006\u0010+\u001a\u000206ø\u0001\u0001ø\u0001\u0000¢\u0006\u0002\b>J\u001d\u0010'\u001a\u00020\u00042\u0006\u0010+\u001a\u00020\rH\u0007ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\b?\u0010\u0011J\u001d\u0010'\u001a\u00020\u00042\u0006\u0010+\u001a\u00020\u0012H\u0007ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\b?\u0010\u0014J\u001d\u0010'\u001a\u00020\u00042\u0006\u0010+\u001a\u00020\u0015H\u0007ø\u0001\u0001ø\u0001\u0000¢\u0006\u0004\b?\u0010\u0017R\u0019\u0010\u0003\u001a\u00020\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\n\n\u0002\u0010\u0007\u001a\u0004\b\u0005\u0010\u0006R\u001c\u0010\b\u001a\u00020\u0004X\u0080\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\n\n\u0002\u0010\u0007\u001a\u0004\b\t\u0010\u0006R\u0019\u0010\n\u001a\u00020\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\n\n\u0002\u0010\u0007\u001a\u0004\b\u000b\u0010\u0006R%\u0010\f\u001a\u00020\u0004*\u00020\r8Æ\u0002X\u0087\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\f\u0012\u0004\b\u000e\u0010\u000f\u001a\u0004\b\u0010\u0010\u0011R%\u0010\f\u001a\u00020\u0004*\u00020\u00128Æ\u0002X\u0087\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\f\u0012\u0004\b\u000e\u0010\u0013\u001a\u0004\b\u0010\u0010\u0014R%\u0010\f\u001a\u00020\u0004*\u00020\u00158Æ\u0002X\u0087\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\f\u0012\u0004\b\u000e\u0010\u0016\u001a\u0004\b\u0010\u0010\u0017R%\u0010\u0018\u001a\u00020\u0004*\u00020\r8Æ\u0002X\u0087\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\f\u0012\u0004\b\u0019\u0010\u000f\u001a\u0004\b\u001a\u0010\u0011R%\u0010\u0018\u001a\u00020\u0004*\u00020\u00128Æ\u0002X\u0087\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\f\u0012\u0004\b\u0019\u0010\u0013\u001a\u0004\b\u001a\u0010\u0014R%\u0010\u0018\u001a\u00020\u0004*\u00020\u00158Æ\u0002X\u0087\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\f\u0012\u0004\b\u0019\u0010\u0016\u001a\u0004\b\u001a\u0010\u0017R%\u0010\u001b\u001a\u00020\u0004*\u00020\r8Æ\u0002X\u0087\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\f\u0012\u0004\b\u001c\u0010\u000f\u001a\u0004\b\u001d\u0010\u0011R%\u0010\u001b\u001a\u00020\u0004*\u00020\u00128Æ\u0002X\u0087\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\f\u0012\u0004\b\u001c\u0010\u0013\u001a\u0004\b\u001d\u0010\u0014R%\u0010\u001b\u001a\u00020\u0004*\u00020\u00158Æ\u0002X\u0087\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\f\u0012\u0004\b\u001c\u0010\u0016\u001a\u0004\b\u001d\u0010\u0017R%\u0010\u001e\u001a\u00020\u0004*\u00020\r8Æ\u0002X\u0087\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\f\u0012\u0004\b\u001f\u0010\u000f\u001a\u0004\b \u0010\u0011R%\u0010\u001e\u001a\u00020\u0004*\u00020\u00128Æ\u0002X\u0087\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\f\u0012\u0004\b\u001f\u0010\u0013\u001a\u0004\b \u0010\u0014R%\u0010\u001e\u001a\u00020\u0004*\u00020\u00158Æ\u0002X\u0087\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\f\u0012\u0004\b\u001f\u0010\u0016\u001a\u0004\b \u0010\u0017R%\u0010!\u001a\u00020\u0004*\u00020\r8Æ\u0002X\u0087\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\f\u0012\u0004\b\"\u0010\u000f\u001a\u0004\b#\u0010\u0011R%\u0010!\u001a\u00020\u0004*\u00020\u00128Æ\u0002X\u0087\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\f\u0012\u0004\b\"\u0010\u0013\u001a\u0004\b#\u0010\u0014R%\u0010!\u001a\u00020\u0004*\u00020\u00158Æ\u0002X\u0087\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\f\u0012\u0004\b\"\u0010\u0016\u001a\u0004\b#\u0010\u0017R%\u0010$\u001a\u00020\u0004*\u00020\r8Æ\u0002X\u0087\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\f\u0012\u0004\b%\u0010\u000f\u001a\u0004\b&\u0010\u0011R%\u0010$\u001a\u00020\u0004*\u00020\u00128Æ\u0002X\u0087\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\f\u0012\u0004\b%\u0010\u0013\u001a\u0004\b&\u0010\u0014R%\u0010$\u001a\u00020\u0004*\u00020\u00158Æ\u0002X\u0087\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\f\u0012\u0004\b%\u0010\u0016\u001a\u0004\b&\u0010\u0017R%\u0010'\u001a\u00020\u0004*\u00020\r8Æ\u0002X\u0087\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\f\u0012\u0004\b(\u0010\u000f\u001a\u0004\b)\u0010\u0011R%\u0010'\u001a\u00020\u0004*\u00020\u00128Æ\u0002X\u0087\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\f\u0012\u0004\b(\u0010\u0013\u001a\u0004\b)\u0010\u0014R%\u0010'\u001a\u00020\u0004*\u00020\u00158Æ\u0002X\u0087\u0004ø\u0001\u0000ø\u0001\u0001¢\u0006\f\u0012\u0004\b(\u0010\u0016\u001a\u0004\b)\u0010\u0017\u0082\u0002\b\n\u0002\b\u0019\n\u0002\b!¨\u0006@"}, m40d2 = {"Lkotlin/time/Duration$Companion;", "", "()V", "INFINITE", "Lkotlin/time/Duration;", "getINFINITE-UwyO8pc", "()J", "J", "NEG_INFINITE", "getNEG_INFINITE-UwyO8pc$kotlin_stdlib", "ZERO", "getZERO-UwyO8pc", "days", "", "getDays-UwyO8pc$annotations", "(D)V", "getDays-UwyO8pc", "(D)J", "", "(I)V", "(I)J", "", "(J)V", "(J)J", "hours", "getHours-UwyO8pc$annotations", "getHours-UwyO8pc", "microseconds", "getMicroseconds-UwyO8pc$annotations", "getMicroseconds-UwyO8pc", "milliseconds", "getMilliseconds-UwyO8pc$annotations", "getMilliseconds-UwyO8pc", "minutes", "getMinutes-UwyO8pc$annotations", "getMinutes-UwyO8pc", "nanoseconds", "getNanoseconds-UwyO8pc$annotations", "getNanoseconds-UwyO8pc", "seconds", "getSeconds-UwyO8pc$annotations", "getSeconds-UwyO8pc", "convert", RNConstants.ARG_VALUE, "sourceUnit", "Lkotlin/time/DurationUnit;", "targetUnit", "days-UwyO8pc", "hours-UwyO8pc", "microseconds-UwyO8pc", "milliseconds-UwyO8pc", "minutes-UwyO8pc", "nanoseconds-UwyO8pc", "parse", "", "parse-UwyO8pc", "(Ljava/lang/String;)J", "parseIsoString", "parseIsoString-UwyO8pc", "parseIsoStringOrNull", "parseIsoStringOrNull-FghU774", "parseOrNull", "parseOrNull-FghU774", "seconds-UwyO8pc", "kotlin-stdlib"}, m39k = 1, m38mv = {1, 7, 1}, m36xi = 48)
    /* loaded from: classes3.dex */
    public static final class Companion {
        public /* synthetic */ Companion(DefaultConstructorMarker defaultConstructorMarker) {
            this();
        }

        /* renamed from: getDays-UwyO8pc$annotations */
        public static /* synthetic */ void m1862getDaysUwyO8pc$annotations(double d) {
        }

        /* renamed from: getDays-UwyO8pc$annotations */
        public static /* synthetic */ void m1863getDaysUwyO8pc$annotations(int i) {
        }

        /* renamed from: getDays-UwyO8pc$annotations */
        public static /* synthetic */ void m1864getDaysUwyO8pc$annotations(long j) {
        }

        /* renamed from: getHours-UwyO8pc$annotations */
        public static /* synthetic */ void m1868getHoursUwyO8pc$annotations(double d) {
        }

        /* renamed from: getHours-UwyO8pc$annotations */
        public static /* synthetic */ void m1869getHoursUwyO8pc$annotations(int i) {
        }

        /* renamed from: getHours-UwyO8pc$annotations */
        public static /* synthetic */ void m1870getHoursUwyO8pc$annotations(long j) {
        }

        /* renamed from: getMicroseconds-UwyO8pc$annotations */
        public static /* synthetic */ void m1874getMicrosecondsUwyO8pc$annotations(double d) {
        }

        /* renamed from: getMicroseconds-UwyO8pc$annotations */
        public static /* synthetic */ void m1875getMicrosecondsUwyO8pc$annotations(int i) {
        }

        /* renamed from: getMicroseconds-UwyO8pc$annotations */
        public static /* synthetic */ void m1876getMicrosecondsUwyO8pc$annotations(long j) {
        }

        /* renamed from: getMilliseconds-UwyO8pc$annotations */
        public static /* synthetic */ void m1880getMillisecondsUwyO8pc$annotations(double d) {
        }

        /* renamed from: getMilliseconds-UwyO8pc$annotations */
        public static /* synthetic */ void m1881getMillisecondsUwyO8pc$annotations(int i) {
        }

        /* renamed from: getMilliseconds-UwyO8pc$annotations */
        public static /* synthetic */ void m1882getMillisecondsUwyO8pc$annotations(long j) {
        }

        /* renamed from: getMinutes-UwyO8pc$annotations */
        public static /* synthetic */ void m1886getMinutesUwyO8pc$annotations(double d) {
        }

        /* renamed from: getMinutes-UwyO8pc$annotations */
        public static /* synthetic */ void m1887getMinutesUwyO8pc$annotations(int i) {
        }

        /* renamed from: getMinutes-UwyO8pc$annotations */
        public static /* synthetic */ void m1888getMinutesUwyO8pc$annotations(long j) {
        }

        /* renamed from: getNanoseconds-UwyO8pc$annotations */
        public static /* synthetic */ void m1892getNanosecondsUwyO8pc$annotations(double d) {
        }

        /* renamed from: getNanoseconds-UwyO8pc$annotations */
        public static /* synthetic */ void m1893getNanosecondsUwyO8pc$annotations(int i) {
        }

        /* renamed from: getNanoseconds-UwyO8pc$annotations */
        public static /* synthetic */ void m1894getNanosecondsUwyO8pc$annotations(long j) {
        }

        /* renamed from: getSeconds-UwyO8pc$annotations */
        public static /* synthetic */ void m1898getSecondsUwyO8pc$annotations(double d) {
        }

        /* renamed from: getSeconds-UwyO8pc$annotations */
        public static /* synthetic */ void m1899getSecondsUwyO8pc$annotations(int i) {
        }

        /* renamed from: getSeconds-UwyO8pc$annotations */
        public static /* synthetic */ void m1900getSecondsUwyO8pc$annotations(long j) {
        }

        private Companion() {
        }

        /* renamed from: getZERO-UwyO8pc */
        public final long m1906getZEROUwyO8pc() {
            return Duration.ZERO;
        }

        /* renamed from: getINFINITE-UwyO8pc */
        public final long m1904getINFINITEUwyO8pc() {
            return Duration.INFINITE;
        }

        /* renamed from: getNEG_INFINITE-UwyO8pc$kotlin_stdlib */
        public final long m1905getNEG_INFINITEUwyO8pc$kotlin_stdlib() {
            return Duration.NEG_INFINITE;
        }

        public final double convert(double d, DurationUnitJvm sourceUnit, DurationUnitJvm targetUnit) {
            Intrinsics.checkNotNullParameter(sourceUnit, "sourceUnit");
            Intrinsics.checkNotNullParameter(targetUnit, "targetUnit");
            return DurationUnitKt.convertDurationUnit(d, sourceUnit, targetUnit);
        }

        /* renamed from: getNanoseconds-UwyO8pc */
        private final long m1890getNanosecondsUwyO8pc(int i) {
            return DurationKt.toDuration(i, DurationUnitJvm.NANOSECONDS);
        }

        /* renamed from: getNanoseconds-UwyO8pc */
        private final long m1891getNanosecondsUwyO8pc(long j) {
            return DurationKt.toDuration(j, DurationUnitJvm.NANOSECONDS);
        }

        /* renamed from: getNanoseconds-UwyO8pc */
        private final long m1889getNanosecondsUwyO8pc(double d) {
            return DurationKt.toDuration(d, DurationUnitJvm.NANOSECONDS);
        }

        /* renamed from: getMicroseconds-UwyO8pc */
        private final long m1872getMicrosecondsUwyO8pc(int i) {
            return DurationKt.toDuration(i, DurationUnitJvm.MICROSECONDS);
        }

        /* renamed from: getMicroseconds-UwyO8pc */
        private final long m1873getMicrosecondsUwyO8pc(long j) {
            return DurationKt.toDuration(j, DurationUnitJvm.MICROSECONDS);
        }

        /* renamed from: getMicroseconds-UwyO8pc */
        private final long m1871getMicrosecondsUwyO8pc(double d) {
            return DurationKt.toDuration(d, DurationUnitJvm.MICROSECONDS);
        }

        /* renamed from: getMilliseconds-UwyO8pc */
        private final long m1878getMillisecondsUwyO8pc(int i) {
            return DurationKt.toDuration(i, DurationUnitJvm.MILLISECONDS);
        }

        /* renamed from: getMilliseconds-UwyO8pc */
        private final long m1879getMillisecondsUwyO8pc(long j) {
            return DurationKt.toDuration(j, DurationUnitJvm.MILLISECONDS);
        }

        /* renamed from: getMilliseconds-UwyO8pc */
        private final long m1877getMillisecondsUwyO8pc(double d) {
            return DurationKt.toDuration(d, DurationUnitJvm.MILLISECONDS);
        }

        /* renamed from: getSeconds-UwyO8pc */
        private final long m1896getSecondsUwyO8pc(int i) {
            return DurationKt.toDuration(i, DurationUnitJvm.SECONDS);
        }

        /* renamed from: getSeconds-UwyO8pc */
        private final long m1897getSecondsUwyO8pc(long j) {
            return DurationKt.toDuration(j, DurationUnitJvm.SECONDS);
        }

        /* renamed from: getSeconds-UwyO8pc */
        private final long m1895getSecondsUwyO8pc(double d) {
            return DurationKt.toDuration(d, DurationUnitJvm.SECONDS);
        }

        /* renamed from: getMinutes-UwyO8pc */
        private final long m1884getMinutesUwyO8pc(int i) {
            return DurationKt.toDuration(i, DurationUnitJvm.MINUTES);
        }

        /* renamed from: getMinutes-UwyO8pc */
        private final long m1885getMinutesUwyO8pc(long j) {
            return DurationKt.toDuration(j, DurationUnitJvm.MINUTES);
        }

        /* renamed from: getMinutes-UwyO8pc */
        private final long m1883getMinutesUwyO8pc(double d) {
            return DurationKt.toDuration(d, DurationUnitJvm.MINUTES);
        }

        /* renamed from: getHours-UwyO8pc */
        private final long m1866getHoursUwyO8pc(int i) {
            return DurationKt.toDuration(i, DurationUnitJvm.HOURS);
        }

        /* renamed from: getHours-UwyO8pc */
        private final long m1867getHoursUwyO8pc(long j) {
            return DurationKt.toDuration(j, DurationUnitJvm.HOURS);
        }

        /* renamed from: getHours-UwyO8pc */
        private final long m1865getHoursUwyO8pc(double d) {
            return DurationKt.toDuration(d, DurationUnitJvm.HOURS);
        }

        /* renamed from: getDays-UwyO8pc */
        private final long m1860getDaysUwyO8pc(int i) {
            return DurationKt.toDuration(i, DurationUnitJvm.DAYS);
        }

        /* renamed from: getDays-UwyO8pc */
        private final long m1861getDaysUwyO8pc(long j) {
            return DurationKt.toDuration(j, DurationUnitJvm.DAYS);
        }

        /* renamed from: getDays-UwyO8pc */
        private final long m1859getDaysUwyO8pc(double d) {
            return DurationKt.toDuration(d, DurationUnitJvm.DAYS);
        }

        @Deprecated(message = "Use 'Int.nanoseconds' extension property from Duration.Companion instead.", replaceWith = @ReplaceWith(expression = "value.nanoseconds", imports = {"kotlin.time.Duration.Companion.nanoseconds"}))
        @DeprecatedSinceKotlin(warningSince = "1.6")
        /* renamed from: nanoseconds-UwyO8pc */
        public final long m1920nanosecondsUwyO8pc(int i) {
            return DurationKt.toDuration(i, DurationUnitJvm.NANOSECONDS);
        }

        @Deprecated(message = "Use 'Long.nanoseconds' extension property from Duration.Companion instead.", replaceWith = @ReplaceWith(expression = "value.nanoseconds", imports = {"kotlin.time.Duration.Companion.nanoseconds"}))
        @DeprecatedSinceKotlin(warningSince = "1.6")
        /* renamed from: nanoseconds-UwyO8pc */
        public final long m1921nanosecondsUwyO8pc(long j) {
            return DurationKt.toDuration(j, DurationUnitJvm.NANOSECONDS);
        }

        @Deprecated(message = "Use 'Double.nanoseconds' extension property from Duration.Companion instead.", replaceWith = @ReplaceWith(expression = "value.nanoseconds", imports = {"kotlin.time.Duration.Companion.nanoseconds"}))
        @DeprecatedSinceKotlin(warningSince = "1.6")
        /* renamed from: nanoseconds-UwyO8pc */
        public final long m1919nanosecondsUwyO8pc(double d) {
            return DurationKt.toDuration(d, DurationUnitJvm.NANOSECONDS);
        }

        @Deprecated(message = "Use 'Int.microseconds' extension property from Duration.Companion instead.", replaceWith = @ReplaceWith(expression = "value.microseconds", imports = {"kotlin.time.Duration.Companion.microseconds"}))
        @DeprecatedSinceKotlin(warningSince = "1.6")
        /* renamed from: microseconds-UwyO8pc */
        public final long m1911microsecondsUwyO8pc(int i) {
            return DurationKt.toDuration(i, DurationUnitJvm.MICROSECONDS);
        }

        @Deprecated(message = "Use 'Long.microseconds' extension property from Duration.Companion instead.", replaceWith = @ReplaceWith(expression = "value.microseconds", imports = {"kotlin.time.Duration.Companion.microseconds"}))
        @DeprecatedSinceKotlin(warningSince = "1.6")
        /* renamed from: microseconds-UwyO8pc */
        public final long m1912microsecondsUwyO8pc(long j) {
            return DurationKt.toDuration(j, DurationUnitJvm.MICROSECONDS);
        }

        @Deprecated(message = "Use 'Double.microseconds' extension property from Duration.Companion instead.", replaceWith = @ReplaceWith(expression = "value.microseconds", imports = {"kotlin.time.Duration.Companion.microseconds"}))
        @DeprecatedSinceKotlin(warningSince = "1.6")
        /* renamed from: microseconds-UwyO8pc */
        public final long m1910microsecondsUwyO8pc(double d) {
            return DurationKt.toDuration(d, DurationUnitJvm.MICROSECONDS);
        }

        @Deprecated(message = "Use 'Int.milliseconds' extension property from Duration.Companion instead.", replaceWith = @ReplaceWith(expression = "value.milliseconds", imports = {"kotlin.time.Duration.Companion.milliseconds"}))
        @DeprecatedSinceKotlin(warningSince = "1.6")
        /* renamed from: milliseconds-UwyO8pc */
        public final long m1914millisecondsUwyO8pc(int i) {
            return DurationKt.toDuration(i, DurationUnitJvm.MILLISECONDS);
        }

        @Deprecated(message = "Use 'Long.milliseconds' extension property from Duration.Companion instead.", replaceWith = @ReplaceWith(expression = "value.milliseconds", imports = {"kotlin.time.Duration.Companion.milliseconds"}))
        @DeprecatedSinceKotlin(warningSince = "1.6")
        /* renamed from: milliseconds-UwyO8pc */
        public final long m1915millisecondsUwyO8pc(long j) {
            return DurationKt.toDuration(j, DurationUnitJvm.MILLISECONDS);
        }

        @Deprecated(message = "Use 'Double.milliseconds' extension property from Duration.Companion instead.", replaceWith = @ReplaceWith(expression = "value.milliseconds", imports = {"kotlin.time.Duration.Companion.milliseconds"}))
        @DeprecatedSinceKotlin(warningSince = "1.6")
        /* renamed from: milliseconds-UwyO8pc */
        public final long m1913millisecondsUwyO8pc(double d) {
            return DurationKt.toDuration(d, DurationUnitJvm.MILLISECONDS);
        }

        @Deprecated(message = "Use 'Int.seconds' extension property from Duration.Companion instead.", replaceWith = @ReplaceWith(expression = "value.seconds", imports = {"kotlin.time.Duration.Companion.seconds"}))
        @DeprecatedSinceKotlin(warningSince = "1.6")
        /* renamed from: seconds-UwyO8pc */
        public final long m1927secondsUwyO8pc(int i) {
            return DurationKt.toDuration(i, DurationUnitJvm.SECONDS);
        }

        @Deprecated(message = "Use 'Long.seconds' extension property from Duration.Companion instead.", replaceWith = @ReplaceWith(expression = "value.seconds", imports = {"kotlin.time.Duration.Companion.seconds"}))
        @DeprecatedSinceKotlin(warningSince = "1.6")
        /* renamed from: seconds-UwyO8pc */
        public final long m1928secondsUwyO8pc(long j) {
            return DurationKt.toDuration(j, DurationUnitJvm.SECONDS);
        }

        @Deprecated(message = "Use 'Double.seconds' extension property from Duration.Companion instead.", replaceWith = @ReplaceWith(expression = "value.seconds", imports = {"kotlin.time.Duration.Companion.seconds"}))
        @DeprecatedSinceKotlin(warningSince = "1.6")
        /* renamed from: seconds-UwyO8pc */
        public final long m1926secondsUwyO8pc(double d) {
            return DurationKt.toDuration(d, DurationUnitJvm.SECONDS);
        }

        @Deprecated(message = "Use 'Int.minutes' extension property from Duration.Companion instead.", replaceWith = @ReplaceWith(expression = "value.minutes", imports = {"kotlin.time.Duration.Companion.minutes"}))
        @DeprecatedSinceKotlin(warningSince = "1.6")
        /* renamed from: minutes-UwyO8pc */
        public final long m1917minutesUwyO8pc(int i) {
            return DurationKt.toDuration(i, DurationUnitJvm.MINUTES);
        }

        @Deprecated(message = "Use 'Long.minutes' extension property from Duration.Companion instead.", replaceWith = @ReplaceWith(expression = "value.minutes", imports = {"kotlin.time.Duration.Companion.minutes"}))
        @DeprecatedSinceKotlin(warningSince = "1.6")
        /* renamed from: minutes-UwyO8pc */
        public final long m1918minutesUwyO8pc(long j) {
            return DurationKt.toDuration(j, DurationUnitJvm.MINUTES);
        }

        @Deprecated(message = "Use 'Double.minutes' extension property from Duration.Companion instead.", replaceWith = @ReplaceWith(expression = "value.minutes", imports = {"kotlin.time.Duration.Companion.minutes"}))
        @DeprecatedSinceKotlin(warningSince = "1.6")
        /* renamed from: minutes-UwyO8pc */
        public final long m1916minutesUwyO8pc(double d) {
            return DurationKt.toDuration(d, DurationUnitJvm.MINUTES);
        }

        @Deprecated(message = "Use 'Int.hours' extension property from Duration.Companion instead.", replaceWith = @ReplaceWith(expression = "value.hours", imports = {"kotlin.time.Duration.Companion.hours"}))
        @DeprecatedSinceKotlin(warningSince = "1.6")
        /* renamed from: hours-UwyO8pc */
        public final long m1908hoursUwyO8pc(int i) {
            return DurationKt.toDuration(i, DurationUnitJvm.HOURS);
        }

        @Deprecated(message = "Use 'Long.hours' extension property from Duration.Companion instead.", replaceWith = @ReplaceWith(expression = "value.hours", imports = {"kotlin.time.Duration.Companion.hours"}))
        @DeprecatedSinceKotlin(warningSince = "1.6")
        /* renamed from: hours-UwyO8pc */
        public final long m1909hoursUwyO8pc(long j) {
            return DurationKt.toDuration(j, DurationUnitJvm.HOURS);
        }

        @Deprecated(message = "Use 'Double.hours' extension property from Duration.Companion instead.", replaceWith = @ReplaceWith(expression = "value.hours", imports = {"kotlin.time.Duration.Companion.hours"}))
        @DeprecatedSinceKotlin(warningSince = "1.6")
        /* renamed from: hours-UwyO8pc */
        public final long m1907hoursUwyO8pc(double d) {
            return DurationKt.toDuration(d, DurationUnitJvm.HOURS);
        }

        @Deprecated(message = "Use 'Int.days' extension property from Duration.Companion instead.", replaceWith = @ReplaceWith(expression = "value.days", imports = {"kotlin.time.Duration.Companion.days"}))
        @DeprecatedSinceKotlin(warningSince = "1.6")
        /* renamed from: days-UwyO8pc */
        public final long m1902daysUwyO8pc(int i) {
            return DurationKt.toDuration(i, DurationUnitJvm.DAYS);
        }

        @Deprecated(message = "Use 'Long.days' extension property from Duration.Companion instead.", replaceWith = @ReplaceWith(expression = "value.days", imports = {"kotlin.time.Duration.Companion.days"}))
        @DeprecatedSinceKotlin(warningSince = "1.6")
        /* renamed from: days-UwyO8pc */
        public final long m1903daysUwyO8pc(long j) {
            return DurationKt.toDuration(j, DurationUnitJvm.DAYS);
        }

        @Deprecated(message = "Use 'Double.days' extension property from Duration.Companion instead.", replaceWith = @ReplaceWith(expression = "value.days", imports = {"kotlin.time.Duration.Companion.days"}))
        @DeprecatedSinceKotlin(warningSince = "1.6")
        /* renamed from: days-UwyO8pc */
        public final long m1901daysUwyO8pc(double d) {
            return DurationKt.toDuration(d, DurationUnitJvm.DAYS);
        }

        /* renamed from: parse-UwyO8pc */
        public final long m1922parseUwyO8pc(String value) {
            long parseDuration;
            Intrinsics.checkNotNullParameter(value, "value");
            try {
                parseDuration = DurationKt.parseDuration(value, false);
                return parseDuration;
            } catch (IllegalArgumentException e) {
                throw new IllegalArgumentException("Invalid duration string format: '" + value + "'.", e);
            }
        }

        /* renamed from: parseIsoString-UwyO8pc */
        public final long m1923parseIsoStringUwyO8pc(String value) {
            long parseDuration;
            Intrinsics.checkNotNullParameter(value, "value");
            try {
                parseDuration = DurationKt.parseDuration(value, true);
                return parseDuration;
            } catch (IllegalArgumentException e) {
                throw new IllegalArgumentException("Invalid ISO duration string format: '" + value + "'.", e);
            }
        }

        /* renamed from: parseOrNull-FghU774 */
        public final Duration m1925parseOrNullFghU774(String value) {
            long parseDuration;
            Intrinsics.checkNotNullParameter(value, "value");
            try {
                parseDuration = DurationKt.parseDuration(value, false);
                return Duration.m1802boximpl(parseDuration);
            } catch (IllegalArgumentException unused) {
                return null;
            }
        }

        /* renamed from: parseIsoStringOrNull-FghU774 */
        public final Duration m1924parseIsoStringOrNullFghU774(String value) {
            long parseDuration;
            Intrinsics.checkNotNullParameter(value, "value");
            try {
                parseDuration = DurationKt.parseDuration(value, true);
                return Duration.m1802boximpl(parseDuration);
            } catch (IllegalArgumentException unused) {
                return null;
            }
        }
    }

    /* renamed from: unaryMinus-UwyO8pc */
    public static final long m1856unaryMinusUwyO8pc(long j) {
        long durationOf;
        durationOf = DurationKt.durationOf(-m1831getValueimpl(j), ((int) j) & 1);
        return durationOf;
    }

    /* renamed from: plus-LRDsOJo */
    public static final long m1840plusLRDsOJo(long j, long j2) {
        long durationOfMillisNormalized;
        long durationOfNanosNormalized;
        if (m1836isInfiniteimpl(j)) {
            if (m1833isFiniteimpl(j2) || (j2 ^ j) >= 0) {
                return j;
            }
            throw new IllegalArgumentException("Summing infinite durations of different signs yields an undefined result.");
        } else if (m1836isInfiniteimpl(j2)) {
            return j2;
        } else {
            if ((((int) j) & 1) == (((int) j2) & 1)) {
                long m1831getValueimpl = m1831getValueimpl(j) + m1831getValueimpl(j2);
                if (m1835isInNanosimpl(j)) {
                    durationOfNanosNormalized = DurationKt.durationOfNanosNormalized(m1831getValueimpl);
                    return durationOfNanosNormalized;
                }
                durationOfMillisNormalized = DurationKt.durationOfMillisNormalized(m1831getValueimpl);
                return durationOfMillisNormalized;
            } else if (m1834isInMillisimpl(j)) {
                return m1800addValuesMixedRangesUwyO8pc(j, m1831getValueimpl(j), m1831getValueimpl(j2));
            } else {
                return m1800addValuesMixedRangesUwyO8pc(j, m1831getValueimpl(j2), m1831getValueimpl(j));
            }
        }
    }

    /* renamed from: addValuesMixedRanges-UwyO8pc */
    private static final long m1800addValuesMixedRangesUwyO8pc(long j, long j2, long j3) {
        long nanosToMillis;
        long durationOfMillis;
        long millisToNanos;
        long millisToNanos2;
        long durationOfNanos;
        nanosToMillis = DurationKt.nanosToMillis(j3);
        long j4 = j2 + nanosToMillis;
        if (new LongRange(-4611686018426L, 4611686018426L).contains(j4)) {
            millisToNanos = DurationKt.millisToNanos(nanosToMillis);
            long j5 = j3 - millisToNanos;
            millisToNanos2 = DurationKt.millisToNanos(j4);
            durationOfNanos = DurationKt.durationOfNanos(millisToNanos2 + j5);
            return durationOfNanos;
        }
        durationOfMillis = DurationKt.durationOfMillis(RangesKt.coerceIn(j4, -4611686018427387903L, (long) DurationKt.MAX_MILLIS));
        return durationOfMillis;
    }

    /* renamed from: minus-LRDsOJo */
    public static final long m1839minusLRDsOJo(long j, long j2) {
        return m1840plusLRDsOJo(j, m1856unaryMinusUwyO8pc(j2));
    }

    /* renamed from: times-UwyO8pc */
    public static final long m1842timesUwyO8pc(long j, int i) {
        long durationOfMillis;
        long nanosToMillis;
        long millisToNanos;
        long nanosToMillis2;
        long durationOfMillis2;
        long durationOfNanosNormalized;
        long durationOfNanos;
        if (m1836isInfiniteimpl(j)) {
            if (i != 0) {
                return i > 0 ? j : m1856unaryMinusUwyO8pc(j);
            }
            throw new IllegalArgumentException("Multiplying infinite duration by zero yields an undefined result.");
        } else if (i == 0) {
            return ZERO;
        } else {
            long m1831getValueimpl = m1831getValueimpl(j);
            long j2 = i;
            long j3 = m1831getValueimpl * j2;
            if (m1835isInNanosimpl(j)) {
                if (new LongRange(-2147483647L, 2147483647L).contains(m1831getValueimpl)) {
                    durationOfNanos = DurationKt.durationOfNanos(j3);
                    return durationOfNanos;
                } else if (j3 / j2 == m1831getValueimpl) {
                    durationOfNanosNormalized = DurationKt.durationOfNanosNormalized(j3);
                    return durationOfNanosNormalized;
                } else {
                    nanosToMillis = DurationKt.nanosToMillis(m1831getValueimpl);
                    millisToNanos = DurationKt.millisToNanos(nanosToMillis);
                    long j4 = nanosToMillis * j2;
                    nanosToMillis2 = DurationKt.nanosToMillis((m1831getValueimpl - millisToNanos) * j2);
                    long j5 = nanosToMillis2 + j4;
                    if (j4 / j2 != nanosToMillis || (j5 ^ j4) < 0) {
                        return MathKt.getSign(m1831getValueimpl) * MathKt.getSign(i) > 0 ? INFINITE : NEG_INFINITE;
                    }
                    durationOfMillis2 = DurationKt.durationOfMillis(RangesKt.coerceIn(j5, new LongRange(-4611686018427387903L, DurationKt.MAX_MILLIS)));
                    return durationOfMillis2;
                }
            } else if (j3 / j2 != m1831getValueimpl) {
                return MathKt.getSign(m1831getValueimpl) * MathKt.getSign(i) > 0 ? INFINITE : NEG_INFINITE;
            } else {
                durationOfMillis = DurationKt.durationOfMillis(RangesKt.coerceIn(j3, new LongRange(-4611686018427387903L, DurationKt.MAX_MILLIS)));
                return durationOfMillis;
            }
        }
    }

    /* renamed from: times-UwyO8pc */
    public static final long m1841timesUwyO8pc(long j, double d) {
        int roundToInt = MathKt.roundToInt(d);
        if (((double) roundToInt) == d) {
            return m1842timesUwyO8pc(j, roundToInt);
        }
        DurationUnitJvm m1829getStorageUnitimpl = m1829getStorageUnitimpl(j);
        return DurationKt.toDuration(m1847toDoubleimpl(j, m1829getStorageUnitimpl) * d, m1829getStorageUnitimpl);
    }

    /* renamed from: div-UwyO8pc */
    public static final long m1807divUwyO8pc(long j, int i) {
        long durationOfMillis;
        long millisToNanos;
        long millisToNanos2;
        long durationOfNanos;
        long durationOfNanos2;
        if (i == 0) {
            if (m1838isPositiveimpl(j)) {
                return INFINITE;
            }
            if (m1837isNegativeimpl(j)) {
                return NEG_INFINITE;
            }
            throw new IllegalArgumentException("Dividing zero duration by zero yields an undefined result.");
        } else if (m1835isInNanosimpl(j)) {
            durationOfNanos2 = DurationKt.durationOfNanos(m1831getValueimpl(j) / i);
            return durationOfNanos2;
        } else if (m1836isInfiniteimpl(j)) {
            return m1842timesUwyO8pc(j, MathKt.getSign(i));
        } else {
            long j2 = i;
            long m1831getValueimpl = m1831getValueimpl(j) / j2;
            if (new LongRange(-4611686018426L, 4611686018426L).contains(m1831getValueimpl)) {
                millisToNanos = DurationKt.millisToNanos(m1831getValueimpl(j) - (m1831getValueimpl * j2));
                millisToNanos2 = DurationKt.millisToNanos(m1831getValueimpl);
                durationOfNanos = DurationKt.durationOfNanos(millisToNanos2 + (millisToNanos / j2));
                return durationOfNanos;
            }
            durationOfMillis = DurationKt.durationOfMillis(m1831getValueimpl);
            return durationOfMillis;
        }
    }

    /* renamed from: div-UwyO8pc */
    public static final long m1806divUwyO8pc(long j, double d) {
        int roundToInt = MathKt.roundToInt(d);
        if ((((double) roundToInt) == d) && roundToInt != 0) {
            return m1807divUwyO8pc(j, roundToInt);
        }
        DurationUnitJvm m1829getStorageUnitimpl = m1829getStorageUnitimpl(j);
        return DurationKt.toDuration(m1847toDoubleimpl(j, m1829getStorageUnitimpl) / d, m1829getStorageUnitimpl);
    }

    /* renamed from: div-LRDsOJo */
    public static final double m1805divLRDsOJo(long j, long j2) {
        DurationUnitJvm durationUnitJvm = (DurationUnitJvm) ComparisonsKt.maxOf(m1829getStorageUnitimpl(j), m1829getStorageUnitimpl(j2));
        return m1847toDoubleimpl(j, durationUnitJvm) / m1847toDoubleimpl(j2, durationUnitJvm);
    }

    /* renamed from: isInfinite-impl */
    public static final boolean m1836isInfiniteimpl(long j) {
        return j == INFINITE || j == NEG_INFINITE;
    }

    /* renamed from: isFinite-impl */
    public static final boolean m1833isFiniteimpl(long j) {
        return !m1836isInfiniteimpl(j);
    }

    /* renamed from: getAbsoluteValue-UwyO8pc */
    public static final long m1810getAbsoluteValueUwyO8pc(long j) {
        return m1837isNegativeimpl(j) ? m1856unaryMinusUwyO8pc(j) : j;
    }

    /* renamed from: compareTo-LRDsOJo */
    public int m1857compareToLRDsOJo(long j) {
        return m1803compareToLRDsOJo(this.rawValue, j);
    }

    /* renamed from: compareTo-LRDsOJo */
    public static int m1803compareToLRDsOJo(long j, long j2) {
        long j3 = j ^ j2;
        if (j3 < 0 || (((int) j3) & 1) == 0) {
            return Intrinsics.compare(j, j2);
        }
        int i = (((int) j) & 1) - (((int) j2) & 1);
        return m1837isNegativeimpl(j) ? -i : i;
    }

    /* renamed from: toComponents-impl */
    public static final <T> T m1846toComponentsimpl(long j, Function5<? super Long, ? super Integer, ? super Integer, ? super Integer, ? super Integer, ? extends T> action) {
        Intrinsics.checkNotNullParameter(action, "action");
        return action.invoke(Long.valueOf(m1819getInWholeDaysimpl(j)), Integer.valueOf(m1811getHoursComponentimpl(j)), Integer.valueOf(m1826getMinutesComponentimpl(j)), Integer.valueOf(m1828getSecondsComponentimpl(j)), Integer.valueOf(m1827getNanosecondsComponentimpl(j)));
    }

    /* renamed from: toComponents-impl */
    public static final <T> T m1845toComponentsimpl(long j, Function4<? super Long, ? super Integer, ? super Integer, ? super Integer, ? extends T> action) {
        Intrinsics.checkNotNullParameter(action, "action");
        return action.invoke(Long.valueOf(m1820getInWholeHoursimpl(j)), Integer.valueOf(m1826getMinutesComponentimpl(j)), Integer.valueOf(m1828getSecondsComponentimpl(j)), Integer.valueOf(m1827getNanosecondsComponentimpl(j)));
    }

    /* renamed from: toComponents-impl */
    public static final <T> T m1844toComponentsimpl(long j, Function3<? super Long, ? super Integer, ? super Integer, ? extends T> action) {
        Intrinsics.checkNotNullParameter(action, "action");
        return action.invoke(Long.valueOf(m1823getInWholeMinutesimpl(j)), Integer.valueOf(m1828getSecondsComponentimpl(j)), Integer.valueOf(m1827getNanosecondsComponentimpl(j)));
    }

    /* renamed from: toComponents-impl */
    public static final <T> T m1843toComponentsimpl(long j, Function2<? super Long, ? super Integer, ? extends T> action) {
        Intrinsics.checkNotNullParameter(action, "action");
        return action.invoke(Long.valueOf(m1825getInWholeSecondsimpl(j)), Integer.valueOf(m1827getNanosecondsComponentimpl(j)));
    }

    /* renamed from: getHoursComponent-impl */
    public static final int m1811getHoursComponentimpl(long j) {
        if (m1836isInfiniteimpl(j)) {
            return 0;
        }
        return (int) (m1820getInWholeHoursimpl(j) % 24);
    }

    /* renamed from: getMinutesComponent-impl */
    public static final int m1826getMinutesComponentimpl(long j) {
        if (m1836isInfiniteimpl(j)) {
            return 0;
        }
        return (int) (m1823getInWholeMinutesimpl(j) % 60);
    }

    /* renamed from: getSecondsComponent-impl */
    public static final int m1828getSecondsComponentimpl(long j) {
        if (m1836isInfiniteimpl(j)) {
            return 0;
        }
        return (int) (m1825getInWholeSecondsimpl(j) % 60);
    }

    /* renamed from: getNanosecondsComponent-impl */
    public static final int m1827getNanosecondsComponentimpl(long j) {
        long m1831getValueimpl;
        if (m1836isInfiniteimpl(j)) {
            return 0;
        }
        if (m1834isInMillisimpl(j)) {
            m1831getValueimpl = DurationKt.millisToNanos(m1831getValueimpl(j) % 1000);
        } else {
            m1831getValueimpl = m1831getValueimpl(j) % ((long) Http2Connection.DEGRADED_PONG_TIMEOUT_NS);
        }
        return (int) m1831getValueimpl;
    }

    /* renamed from: toDouble-impl */
    public static final double m1847toDoubleimpl(long j, DurationUnitJvm unit) {
        Intrinsics.checkNotNullParameter(unit, "unit");
        if (j == INFINITE) {
            return Double.POSITIVE_INFINITY;
        }
        if (j == NEG_INFINITE) {
            return Double.NEGATIVE_INFINITY;
        }
        return DurationUnitKt.convertDurationUnit(m1831getValueimpl(j), m1829getStorageUnitimpl(j), unit);
    }

    /* renamed from: toLong-impl */
    public static final long m1850toLongimpl(long j, DurationUnitJvm unit) {
        Intrinsics.checkNotNullParameter(unit, "unit");
        if (j == INFINITE) {
            return Long.MAX_VALUE;
        }
        if (j == NEG_INFINITE) {
            return Long.MIN_VALUE;
        }
        return DurationUnitKt.convertDurationUnit(m1831getValueimpl(j), m1829getStorageUnitimpl(j), unit);
    }

    /* renamed from: toInt-impl */
    public static final int m1848toIntimpl(long j, DurationUnitJvm unit) {
        Intrinsics.checkNotNullParameter(unit, "unit");
        return (int) RangesKt.coerceIn(m1850toLongimpl(j, unit), -2147483648L, 2147483647L);
    }

    /* renamed from: getInDays-impl */
    public static final double m1812getInDaysimpl(long j) {
        return m1847toDoubleimpl(j, DurationUnitJvm.DAYS);
    }

    /* renamed from: getInHours-impl */
    public static final double m1813getInHoursimpl(long j) {
        return m1847toDoubleimpl(j, DurationUnitJvm.HOURS);
    }

    /* renamed from: getInMinutes-impl */
    public static final double m1816getInMinutesimpl(long j) {
        return m1847toDoubleimpl(j, DurationUnitJvm.MINUTES);
    }

    /* renamed from: getInSeconds-impl */
    public static final double m1818getInSecondsimpl(long j) {
        return m1847toDoubleimpl(j, DurationUnitJvm.SECONDS);
    }

    /* renamed from: getInMilliseconds-impl */
    public static final double m1815getInMillisecondsimpl(long j) {
        return m1847toDoubleimpl(j, DurationUnitJvm.MILLISECONDS);
    }

    /* renamed from: getInMicroseconds-impl */
    public static final double m1814getInMicrosecondsimpl(long j) {
        return m1847toDoubleimpl(j, DurationUnitJvm.MICROSECONDS);
    }

    /* renamed from: getInNanoseconds-impl */
    public static final double m1817getInNanosecondsimpl(long j) {
        return m1847toDoubleimpl(j, DurationUnitJvm.NANOSECONDS);
    }

    /* renamed from: getInWholeDays-impl */
    public static final long m1819getInWholeDaysimpl(long j) {
        return m1850toLongimpl(j, DurationUnitJvm.DAYS);
    }

    /* renamed from: getInWholeHours-impl */
    public static final long m1820getInWholeHoursimpl(long j) {
        return m1850toLongimpl(j, DurationUnitJvm.HOURS);
    }

    /* renamed from: getInWholeMinutes-impl */
    public static final long m1823getInWholeMinutesimpl(long j) {
        return m1850toLongimpl(j, DurationUnitJvm.MINUTES);
    }

    /* renamed from: getInWholeSeconds-impl */
    public static final long m1825getInWholeSecondsimpl(long j) {
        return m1850toLongimpl(j, DurationUnitJvm.SECONDS);
    }

    /* renamed from: getInWholeMilliseconds-impl */
    public static final long m1822getInWholeMillisecondsimpl(long j) {
        return (m1834isInMillisimpl(j) && m1833isFiniteimpl(j)) ? m1831getValueimpl(j) : m1850toLongimpl(j, DurationUnitJvm.MILLISECONDS);
    }

    /* renamed from: getInWholeMicroseconds-impl */
    public static final long m1821getInWholeMicrosecondsimpl(long j) {
        return m1850toLongimpl(j, DurationUnitJvm.MICROSECONDS);
    }

    /* renamed from: getInWholeNanoseconds-impl */
    public static final long m1824getInWholeNanosecondsimpl(long j) {
        long millisToNanos;
        long m1831getValueimpl = m1831getValueimpl(j);
        if (m1835isInNanosimpl(j)) {
            return m1831getValueimpl;
        }
        if (m1831getValueimpl > 9223372036854L) {
            return Long.MAX_VALUE;
        }
        if (m1831getValueimpl < -9223372036854L) {
            return Long.MIN_VALUE;
        }
        millisToNanos = DurationKt.millisToNanos(m1831getValueimpl);
        return millisToNanos;
    }

    @Deprecated(message = "Use inWholeNanoseconds property instead.", replaceWith = @ReplaceWith(expression = "this.inWholeNanoseconds", imports = {}))
    /* renamed from: toLongNanoseconds-impl */
    public static final long m1852toLongNanosecondsimpl(long j) {
        return m1824getInWholeNanosecondsimpl(j);
    }

    @Deprecated(message = "Use inWholeMilliseconds property instead.", replaceWith = @ReplaceWith(expression = "this.inWholeMilliseconds", imports = {}))
    /* renamed from: toLongMilliseconds-impl */
    public static final long m1851toLongMillisecondsimpl(long j) {
        return m1822getInWholeMillisecondsimpl(j);
    }

    public String toString() {
        return m1853toStringimpl(this.rawValue);
    }

    /* renamed from: toString-impl */
    public static String m1853toStringimpl(long j) {
        if (j == 0) {
            return "0s";
        }
        if (j == INFINITE) {
            return "Infinity";
        }
        if (j == NEG_INFINITE) {
            return "-Infinity";
        }
        boolean m1837isNegativeimpl = m1837isNegativeimpl(j);
        StringBuilder sb = new StringBuilder();
        if (m1837isNegativeimpl) {
            sb.append('-');
        }
        long m1810getAbsoluteValueUwyO8pc = m1810getAbsoluteValueUwyO8pc(j);
        long m1819getInWholeDaysimpl = m1819getInWholeDaysimpl(m1810getAbsoluteValueUwyO8pc);
        int m1811getHoursComponentimpl = m1811getHoursComponentimpl(m1810getAbsoluteValueUwyO8pc);
        int m1826getMinutesComponentimpl = m1826getMinutesComponentimpl(m1810getAbsoluteValueUwyO8pc);
        int m1828getSecondsComponentimpl = m1828getSecondsComponentimpl(m1810getAbsoluteValueUwyO8pc);
        int m1827getNanosecondsComponentimpl = m1827getNanosecondsComponentimpl(m1810getAbsoluteValueUwyO8pc);
        int i = 0;
        boolean z = m1819getInWholeDaysimpl != 0;
        boolean z2 = m1811getHoursComponentimpl != 0;
        boolean z3 = m1826getMinutesComponentimpl != 0;
        boolean z4 = (m1828getSecondsComponentimpl == 0 && m1827getNanosecondsComponentimpl == 0) ? false : true;
        if (z) {
            sb.append(m1819getInWholeDaysimpl);
            sb.append('d');
            i = 1;
        }
        if (z2 || (z && (z3 || z4))) {
            int i2 = i + 1;
            if (i > 0) {
                sb.append(' ');
            }
            sb.append(m1811getHoursComponentimpl);
            sb.append('h');
            i = i2;
        }
        if (z3 || (z4 && (z2 || z))) {
            int i3 = i + 1;
            if (i > 0) {
                sb.append(' ');
            }
            sb.append(m1826getMinutesComponentimpl);
            sb.append('m');
            i = i3;
        }
        if (z4) {
            int i4 = i + 1;
            if (i > 0) {
                sb.append(' ');
            }
            if (m1828getSecondsComponentimpl != 0 || z || z2 || z3) {
                m1801appendFractionalimpl(j, sb, m1828getSecondsComponentimpl, m1827getNanosecondsComponentimpl, 9, "s", false);
            } else if (m1827getNanosecondsComponentimpl >= 1000000) {
                m1801appendFractionalimpl(j, sb, m1827getNanosecondsComponentimpl / DurationKt.NANOS_IN_MILLIS, m1827getNanosecondsComponentimpl % DurationKt.NANOS_IN_MILLIS, 6, "ms", false);
            } else if (m1827getNanosecondsComponentimpl >= 1000) {
                m1801appendFractionalimpl(j, sb, m1827getNanosecondsComponentimpl / 1000, m1827getNanosecondsComponentimpl % 1000, 3, "us", false);
            } else {
                sb.append(m1827getNanosecondsComponentimpl);
                sb.append("ns");
            }
            i = i4;
        }
        if (m1837isNegativeimpl && i > 1) {
            sb.insert(1, '(').append(')');
        }
        String sb2 = sb.toString();
        Intrinsics.checkNotNullExpressionValue(sb2, "StringBuilder().apply(builderAction).toString()");
        return sb2;
    }

    /* renamed from: appendFractional-impl */
    private static final void m1801appendFractionalimpl(long j, StringBuilder sb, int i, int i2, int i3, String str, boolean z) {
        sb.append(i);
        if (i2 != 0) {
            sb.append(FilenameUtils.EXTENSION_SEPARATOR);
            String padStart = StringsKt.padStart(String.valueOf(i2), i3, '0');
            int i4 = -1;
            int length = padStart.length() - 1;
            if (length >= 0) {
                while (true) {
                    int i5 = length - 1;
                    if (padStart.charAt(length) != '0') {
                        i4 = length;
                        break;
                    } else if (i5 < 0) {
                        break;
                    } else {
                        length = i5;
                    }
                }
            }
            int i6 = i4 + 1;
            if (!z && i6 < 3) {
                sb.append((CharSequence) padStart, 0, i6);
                Intrinsics.checkNotNullExpressionValue(sb, "this.append(value, startIndex, endIndex)");
            } else {
                sb.append((CharSequence) padStart, 0, ((i6 + 2) / 3) * 3);
                Intrinsics.checkNotNullExpressionValue(sb, "this.append(value, startIndex, endIndex)");
            }
        }
        sb.append(str);
    }

    /* renamed from: toString-impl$default */
    public static /* synthetic */ String m1855toStringimpl$default(long j, DurationUnitJvm durationUnitJvm, int i, int i2, Object obj) {
        if ((i2 & 2) != 0) {
            i = 0;
        }
        return m1854toStringimpl(j, durationUnitJvm, i);
    }

    /* renamed from: toString-impl */
    public static final String m1854toStringimpl(long j, DurationUnitJvm unit, int i) {
        Intrinsics.checkNotNullParameter(unit, "unit");
        if (!(i >= 0)) {
            throw new IllegalArgumentException(("decimals must be not negative, but was " + i).toString());
        }
        double m1847toDoubleimpl = m1847toDoubleimpl(j, unit);
        if (Double.isInfinite(m1847toDoubleimpl)) {
            return String.valueOf(m1847toDoubleimpl);
        }
        return DurationJvm.formatToExactDecimals(m1847toDoubleimpl, RangesKt.coerceAtMost(i, 12)) + DurationUnitKt.shortName(unit);
    }

    /* renamed from: toIsoString-impl */
    public static final String m1849toIsoStringimpl(long j) {
        StringBuilder sb = new StringBuilder();
        if (m1837isNegativeimpl(j)) {
            sb.append('-');
        }
        sb.append("PT");
        long m1810getAbsoluteValueUwyO8pc = m1810getAbsoluteValueUwyO8pc(j);
        long m1820getInWholeHoursimpl = m1820getInWholeHoursimpl(m1810getAbsoluteValueUwyO8pc);
        int m1826getMinutesComponentimpl = m1826getMinutesComponentimpl(m1810getAbsoluteValueUwyO8pc);
        int m1828getSecondsComponentimpl = m1828getSecondsComponentimpl(m1810getAbsoluteValueUwyO8pc);
        int m1827getNanosecondsComponentimpl = m1827getNanosecondsComponentimpl(m1810getAbsoluteValueUwyO8pc);
        if (m1836isInfiniteimpl(j)) {
            m1820getInWholeHoursimpl = 9999999999999L;
        }
        boolean z = true;
        boolean z2 = m1820getInWholeHoursimpl != 0;
        boolean z3 = (m1828getSecondsComponentimpl == 0 && m1827getNanosecondsComponentimpl == 0) ? false : true;
        if (m1826getMinutesComponentimpl == 0 && (!z3 || !z2)) {
            z = false;
        }
        if (z2) {
            sb.append(m1820getInWholeHoursimpl);
            sb.append('H');
        }
        if (z) {
            sb.append(m1826getMinutesComponentimpl);
            sb.append('M');
        }
        if (z3 || (!z2 && !z)) {
            m1801appendFractionalimpl(j, sb, m1828getSecondsComponentimpl, m1827getNanosecondsComponentimpl, 9, "S", true);
        }
        String sb2 = sb.toString();
        Intrinsics.checkNotNullExpressionValue(sb2, "StringBuilder().apply(builderAction).toString()");
        return sb2;
    }
}
