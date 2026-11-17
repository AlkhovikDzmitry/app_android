package kotlinx.coroutines;

import kotlin.Metadata;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.ContinuationInterceptor;
import kotlin.coroutines.CoroutineContext;
import kotlin.coroutines.EmptyCoroutineContext;
import kotlin.coroutines.jvm.internal.CoroutineStackFrame;
import kotlin.jvm.functions.Function2;
import kotlin.jvm.functions.Functions;
import kotlin.jvm.internal.InlineMarker;
import kotlinx.coroutines.internal.ThreadContext;

@Metadata(m41d1 = {"\u00006\n\u0000\n\u0002\u0010\u000e\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0005\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0000\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0006\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\b\u0003\u001a8\u0010\u0006\u001a\u0002H\u0007\"\u0004\b\u0000\u0010\u00072\n\u0010\b\u001a\u0006\u0012\u0002\b\u00030\t2\b\u0010\n\u001a\u0004\u0018\u00010\u000b2\f\u0010\f\u001a\b\u0012\u0004\u0012\u0002H\u00070\rH\u0080\b¢\u0006\u0002\u0010\u000e\u001a4\u0010\u000f\u001a\u0002H\u0007\"\u0004\b\u0000\u0010\u00072\u0006\u0010\u0010\u001a\u00020\u00032\b\u0010\n\u001a\u0004\u0018\u00010\u000b2\f\u0010\f\u001a\b\u0012\u0004\u0012\u0002H\u00070\rH\u0080\b¢\u0006\u0002\u0010\u0011\u001a\f\u0010\u0012\u001a\u00020\u0003*\u00020\u0003H\u0002\u001a\u0014\u0010\u0013\u001a\u00020\u0003*\u00020\u00142\u0006\u0010\u0010\u001a\u00020\u0003H\u0007\u001a\u0013\u0010\u0015\u001a\b\u0012\u0002\b\u0003\u0018\u00010\u0016*\u00020\u0017H\u0080\u0010\u001a(\u0010\u0018\u001a\b\u0012\u0002\b\u0003\u0018\u00010\u0016*\u0006\u0012\u0002\b\u00030\t2\u0006\u0010\u0010\u001a\u00020\u00032\b\u0010\u0019\u001a\u0004\u0018\u00010\u000bH\u0000\"\u000e\u0010\u0000\u001a\u00020\u0001X\u0082T¢\u0006\u0002\n\u0000\"\u001a\u0010\u0002\u001a\u0004\u0018\u00010\u0001*\u00020\u00038@X\u0080\u0004¢\u0006\u0006\u001a\u0004\b\u0004\u0010\u0005¨\u0006\u001a"}, m40d2 = {"DEBUG_THREAD_NAME_SEPARATOR", "", "coroutineName", "Lkotlin/coroutines/CoroutineContext;", "getCoroutineName", "(Lkotlin/coroutines/CoroutineContext;)Ljava/lang/String;", "withContinuationContext", "T", "continuation", "Lkotlin/coroutines/Continuation;", "countOrElement", "", "block", "Lkotlin/Function0;", "(Lkotlin/coroutines/Continuation;Ljava/lang/Object;Lkotlin/jvm/functions/Function0;)Ljava/lang/Object;", "withCoroutineContext", "context", "(Lkotlin/coroutines/CoroutineContext;Ljava/lang/Object;Lkotlin/jvm/functions/Function0;)Ljava/lang/Object;", "foldCopiesForChildCoroutine", "newCoroutineContext", "Lkotlinx/coroutines/CoroutineScope;", "undispatchedCompletion", "Lkotlinx/coroutines/UndispatchedCoroutine;", "Lkotlin/coroutines/jvm/internal/CoroutineStackFrame;", "updateUndispatchedCompletion", "oldValue", "kotlinx-coroutines-core"}, m39k = 2, m38mv = {1, 6, 0}, m36xi = 48)
/* renamed from: kotlinx.coroutines.CoroutineContextKt */
/* loaded from: classes3.dex */
public final class CoroutineContext {
    private static final String DEBUG_THREAD_NAME_SEPARATOR = " @";

    public static final kotlin.coroutines.CoroutineContext newCoroutineContext(CoroutineScope coroutineScope, kotlin.coroutines.CoroutineContext coroutineContext) {
        kotlin.coroutines.CoroutineContext plus = foldCopiesForChildCoroutine(coroutineScope.getCoroutineContext()).plus(coroutineContext);
        kotlin.coroutines.CoroutineContext plus2 = Debug.getDEBUG() ? plus.plus(new CoroutineId(Debug.getCOROUTINE_ID().incrementAndGet())) : plus;
        return (plus == Dispatchers.getDefault() || plus.get(ContinuationInterceptor.Key) != null) ? plus2 : plus2.plus(Dispatchers.getDefault());
    }

    private static final kotlin.coroutines.CoroutineContext foldCopiesForChildCoroutine(kotlin.coroutines.CoroutineContext coroutineContext) {
        return !((Boolean) coroutineContext.fold(false, new Function2<Boolean, CoroutineContext.Element, Boolean>() { // from class: kotlinx.coroutines.CoroutineContextKt$foldCopiesForChildCoroutine$hasToCopy$1
            @Override // kotlin.jvm.functions.Function2
            public /* bridge */ /* synthetic */ Boolean invoke(Boolean bool, CoroutineContext.Element element) {
                return invoke(bool.booleanValue(), element);
            }

            public final Boolean invoke(boolean z, CoroutineContext.Element element) {
                return Boolean.valueOf(z || (element instanceof CopyableThreadContextElement));
            }
        })).booleanValue() ? coroutineContext : (kotlin.coroutines.CoroutineContext) coroutineContext.fold(EmptyCoroutineContext.INSTANCE, new Function2<kotlin.coroutines.CoroutineContext, CoroutineContext.Element, kotlin.coroutines.CoroutineContext>() { // from class: kotlinx.coroutines.CoroutineContextKt$foldCopiesForChildCoroutine$1
            @Override // kotlin.jvm.functions.Function2
            public final CoroutineContext invoke(CoroutineContext coroutineContext2, CoroutineContext.Element element) {
                if (element instanceof CopyableThreadContextElement) {
                    element = ((CopyableThreadContextElement) element).copyForChildCoroutine();
                }
                return coroutineContext2.plus(element);
            }
        });
    }

    public static final <T> T withCoroutineContext(kotlin.coroutines.CoroutineContext coroutineContext, Object obj, Functions<? extends T> functions) {
        Object updateThreadContext = ThreadContext.updateThreadContext(coroutineContext, obj);
        try {
            return functions.invoke();
        } finally {
            InlineMarker.finallyStart(1);
            ThreadContext.restoreThreadContext(coroutineContext, updateThreadContext);
            InlineMarker.finallyEnd(1);
        }
    }

    public static final <T> T withContinuationContext(Continuation<?> continuation, Object obj, Functions<? extends T> functions) {
        kotlin.coroutines.CoroutineContext context = continuation.getContext();
        Object updateThreadContext = ThreadContext.updateThreadContext(context, obj);
        UndispatchedCoroutine<?> updateUndispatchedCompletion = updateThreadContext != ThreadContext.NO_THREAD_ELEMENTS ? updateUndispatchedCompletion(continuation, context, updateThreadContext) : null;
        try {
            return functions.invoke();
        } finally {
            InlineMarker.finallyStart(1);
            if (updateUndispatchedCompletion == null || updateUndispatchedCompletion.clearThreadContext()) {
                ThreadContext.restoreThreadContext(context, updateThreadContext);
            }
            InlineMarker.finallyEnd(1);
        }
    }

    public static final UndispatchedCoroutine<?> updateUndispatchedCompletion(Continuation<?> continuation, kotlin.coroutines.CoroutineContext coroutineContext, Object obj) {
        if (continuation instanceof CoroutineStackFrame) {
            if (coroutineContext.get(UndispatchedMarker.INSTANCE) != null) {
                UndispatchedCoroutine<?> undispatchedCompletion = undispatchedCompletion((CoroutineStackFrame) continuation);
                if (undispatchedCompletion != null) {
                    undispatchedCompletion.saveThreadContext(coroutineContext, obj);
                }
                return undispatchedCompletion;
            }
            return null;
        }
        return null;
    }

    public static final UndispatchedCoroutine<?> undispatchedCompletion(CoroutineStackFrame coroutineStackFrame) {
        while (!(coroutineStackFrame instanceof DispatchedCoroutine) && (coroutineStackFrame = coroutineStackFrame.getCallerFrame()) != null) {
            if (coroutineStackFrame instanceof UndispatchedCoroutine) {
                return (UndispatchedCoroutine) coroutineStackFrame;
            }
        }
        return null;
    }

    public static final String getCoroutineName(kotlin.coroutines.CoroutineContext coroutineContext) {
        CoroutineId coroutineId;
        String name;
        if (Debug.getDEBUG() && (coroutineId = (CoroutineId) coroutineContext.get(CoroutineId.Key)) != null) {
            CoroutineName coroutineName = (CoroutineName) coroutineContext.get(CoroutineName.Key);
            String str = "coroutine";
            if (coroutineName != null && (name = coroutineName.getName()) != null) {
                str = name;
            }
            return str + '#' + coroutineId.getId();
        }
        return null;
    }
}
