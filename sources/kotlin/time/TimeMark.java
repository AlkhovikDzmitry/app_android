package kotlin.time;

import kotlin.Metadata;

/* compiled from: TimeSource.kt */
@Metadata(m41d1 = {"\u0000\u0018\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u000b\n\u0002\b\u0005\bg\u0018\u00002\u00020\u0001J\u000e\u0010\u0002\u001a\u00020\u0003H&ø\u0001\u0000ø\u0001\u0001J\b\u0010\u0004\u001a\u00020\u0005H\u0016J\b\u0010\u0006\u001a\u00020\u0005H\u0016J\u0014\u0010\u0007\u001a\u00020\u00002\u0006\u0010\b\u001a\u00020\u0003H\u0096\u0002ø\u0001\u0001J\u0014\u0010\t\u001a\u00020\u00002\u0006\u0010\b\u001a\u00020\u0003H\u0096\u0002ø\u0001\u0001\u0082\u0002\b\n\u0002\b!\n\u0002\b\u0019¨\u0006\n"}, m40d2 = {"Lkotlin/time/TimeMark;", "", "elapsedNow", "Lkotlin/time/Duration;", "hasNotPassedNow", "", "hasPassedNow", "minus", "duration", "plus", "kotlin-stdlib"}, m39k = 1, m38mv = {1, 7, 1}, m36xi = 48)
/* loaded from: classes3.dex */
public interface TimeMark {
    /* renamed from: elapsedNow-UwyO8pc */
    long mo1796elapsedNowUwyO8pc();

    boolean hasNotPassedNow();

    boolean hasPassedNow();

    /* renamed from: minus-LRDsOJo */
    TimeMark mo1797minusLRDsOJo(long j);

    /* renamed from: plus-LRDsOJo */
    TimeMark mo1798plusLRDsOJo(long j);

    /* compiled from: TimeSource.kt */
    @Metadata(m39k = 3, m38mv = {1, 7, 1}, m36xi = 48)
    /* loaded from: classes3.dex */
    public static final class DefaultImpls {
        /* renamed from: plus-LRDsOJo */
        public static TimeMark m1940plusLRDsOJo(TimeMark timeMark, long j) {
            return new AdjustedTimeMark(timeMark, j, null);
        }

        /* renamed from: minus-LRDsOJo */
        public static TimeMark m1939minusLRDsOJo(TimeMark timeMark, long j) {
            return timeMark.mo1798plusLRDsOJo(Duration.m1856unaryMinusUwyO8pc(j));
        }

        public static boolean hasPassedNow(TimeMark timeMark) {
            return !Duration.m1837isNegativeimpl(timeMark.mo1796elapsedNowUwyO8pc());
        }

        public static boolean hasNotPassedNow(TimeMark timeMark) {
            return Duration.m1837isNegativeimpl(timeMark.mo1796elapsedNowUwyO8pc());
        }
    }
}
