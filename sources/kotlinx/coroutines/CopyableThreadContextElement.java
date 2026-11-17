package kotlinx.coroutines;

import kotlin.Metadata;
import kotlin.coroutines.CoroutineContext;
import kotlin.jvm.functions.Function2;
import kotlinx.coroutines.ThreadContextElement;

/* compiled from: ThreadContextElement.kt */
@Metadata(m41d1 = {"\u0000\u000e\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0002\bg\u0018\u0000*\u0004\b\u0000\u0010\u00012\b\u0012\u0004\u0012\u0002H\u00010\u0002J\u000e\u0010\u0003\u001a\b\u0012\u0004\u0012\u00028\u00000\u0000H&¨\u0006\u0004"}, m40d2 = {"Lkotlinx/coroutines/CopyableThreadContextElement;", "S", "Lkotlinx/coroutines/ThreadContextElement;", "copyForChildCoroutine", "kotlinx-coroutines-core"}, m39k = 1, m38mv = {1, 6, 0}, m36xi = 48)
/* loaded from: classes3.dex */
public interface CopyableThreadContextElement<S> extends ThreadContextElement<S> {
    CopyableThreadContextElement<S> copyForChildCoroutine();

    /* compiled from: ThreadContextElement.kt */
    @Metadata(m39k = 3, m38mv = {1, 6, 0}, m36xi = 48)
    /* loaded from: classes3.dex */
    public static final class DefaultImpls {
        public static <S, R> R fold(CopyableThreadContextElement<S> copyableThreadContextElement, R r, Function2<? super R, ? super CoroutineContext.Element, ? extends R> function2) {
            return (R) ThreadContextElement.DefaultImpls.fold(copyableThreadContextElement, r, function2);
        }

        public static <S, E extends CoroutineContext.Element> E get(CopyableThreadContextElement<S> copyableThreadContextElement, CoroutineContext.Key<E> key) {
            return (E) ThreadContextElement.DefaultImpls.get(copyableThreadContextElement, key);
        }

        public static <S> CoroutineContext minusKey(CopyableThreadContextElement<S> copyableThreadContextElement, CoroutineContext.Key<?> key) {
            return ThreadContextElement.DefaultImpls.minusKey(copyableThreadContextElement, key);
        }

        public static <S> CoroutineContext plus(CopyableThreadContextElement<S> copyableThreadContextElement, CoroutineContext coroutineContext) {
            return ThreadContextElement.DefaultImpls.plus(copyableThreadContextElement, coroutineContext);
        }
    }
}
