package androidx.work.impl.utils;

import androidx.arch.core.util.Function;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MediatorLiveData;
import androidx.lifecycle.Observer;
import androidx.work.impl.utils.taskexecutor.TaskExecutor;

/* loaded from: classes.dex */
public class LiveDataUtils {
    public static <In, Out> LiveData<Out> dedupedMappedLiveDataFor(LiveData<In> inputLiveData, final Function<In, Out> mappingMethod, final TaskExecutor workTaskExecutor) {
        Object obj = new Object();
        MediatorLiveData mediatorLiveData = new MediatorLiveData();
        mediatorLiveData.addSource(inputLiveData, new C07351(workTaskExecutor, obj, mappingMethod, mediatorLiveData));
        return mediatorLiveData;
    }

    /* renamed from: androidx.work.impl.utils.LiveDataUtils$1 */
    /* loaded from: classes.dex */
    public class C07351<In> implements Observer<In> {
        Out mCurrentOutput = null;
        final /* synthetic */ Object val$lock;
        final /* synthetic */ Function val$mappingMethod;
        final /* synthetic */ MediatorLiveData val$outputLiveData;
        final /* synthetic */ TaskExecutor val$workTaskExecutor;

        C07351(final TaskExecutor val$workTaskExecutor, final Object val$lock, final Function val$mappingMethod, final MediatorLiveData val$outputLiveData) {
            this.val$workTaskExecutor = val$workTaskExecutor;
            this.val$lock = val$lock;
            this.val$mappingMethod = val$mappingMethod;
            this.val$outputLiveData = val$outputLiveData;
        }

        @Override // androidx.lifecycle.Observer
        public void onChanged(final In input) {
            this.val$workTaskExecutor.executeOnBackgroundThread(new Runnable() { // from class: androidx.work.impl.utils.LiveDataUtils.1.1
                /* JADX WARN: Multi-variable type inference failed */
                /* JADX WARN: Type inference failed for: r1v3, types: [java.lang.Object, Out] */
                @Override // java.lang.Runnable
                public void run() {
                    synchronized (C07351.this.val$lock) {
                        ?? apply = C07351.this.val$mappingMethod.apply(input);
                        if (C07351.this.mCurrentOutput == 0 && apply != 0) {
                            C07351.this.mCurrentOutput = apply;
                            C07351.this.val$outputLiveData.postValue(apply);
                        } else if (C07351.this.mCurrentOutput != 0 && !C07351.this.mCurrentOutput.equals(apply)) {
                            C07351.this.mCurrentOutput = apply;
                            C07351.this.val$outputLiveData.postValue(apply);
                        }
                    }
                }
            });
        }
    }

    private LiveDataUtils() {
    }
}
