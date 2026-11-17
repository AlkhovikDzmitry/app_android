package com.horcrux.svg;

import android.util.SparseArray;
import com.facebook.react.bridge.Dynamic;
import com.facebook.react.uimanager.PointerEvents;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewManagerDelegate;
import com.facebook.react.uimanager.ViewProps;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.viewmanagers.RNSVGSvgViewManagerDelegate;
import com.facebook.react.viewmanagers.RNSVGSvgViewManagerInterface;
import com.facebook.react.views.view.ReactViewGroup;
import com.facebook.react.views.view.ReactViewManager;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Locale;
import javax.annotation.Nonnull;
import javax.annotation.Nullable;

/* loaded from: classes2.dex */
class SvgViewManager extends ReactViewManager implements RNSVGSvgViewManagerInterface<SvgView> {
    private static final String REACT_CLASS = "RNSVGSvgView";
    private final ViewManagerDelegate<SvgView> mDelegate = new RNSVGSvgViewManagerDelegate(this);
    private static final SparseArray<SvgView> mTagToSvgView = new SparseArray<>();
    private static final SparseArray<Runnable> mTagToRunnable = new SparseArray<>();

    @Override // com.facebook.react.views.view.ReactViewManager, com.facebook.react.uimanager.ViewManager, com.facebook.react.bridge.NativeModule
    @Nonnull
    public String getName() {
        return REACT_CLASS;
    }

    @Override // com.facebook.react.uimanager.ViewGroupManager, com.facebook.react.uimanager.IViewManagerWithChildren
    public boolean needsCustomLayoutForChildren() {
        return true;
    }

    @Override // com.facebook.react.uimanager.ViewManager
    public ViewManagerDelegate getDelegate() {
        return this.mDelegate;
    }

    public static void setSvgView(int i, SvgView svgView) {
        mTagToSvgView.put(i, svgView);
        SparseArray<Runnable> sparseArray = mTagToRunnable;
        Runnable runnable = sparseArray.get(i);
        if (runnable != null) {
            runnable.run();
            sparseArray.delete(i);
        }
    }

    public static void runWhenViewIsAvailable(int i, Runnable runnable) {
        mTagToRunnable.put(i, runnable);
    }

    @Nullable
    public static SvgView getSvgViewByTag(int i) {
        return mTagToSvgView.get(i);
    }

    @Override // com.facebook.react.views.view.ReactViewManager, com.facebook.react.uimanager.ViewManager
    @Nonnull
    public ReactViewGroup createViewInstance(ThemedReactContext themedReactContext) {
        return new SvgView(themedReactContext);
    }

    @Override // com.facebook.react.uimanager.ViewGroupManager
    public void updateExtraData(ReactViewGroup reactViewGroup, Object obj) {
        super.updateExtraData((SvgViewManager) reactViewGroup, obj);
        reactViewGroup.invalidate();
    }

    @Override // com.facebook.react.uimanager.ViewManager
    public void onDropViewInstance(@Nonnull ReactViewGroup reactViewGroup) {
        super.onDropViewInstance((SvgViewManager) reactViewGroup);
        mTagToSvgView.remove(reactViewGroup.getId());
    }

    @Override // com.facebook.react.viewmanagers.RNSVGSvgViewManagerInterface
    @ReactProp(customType = "Color", name = "tintColor")
    public void setTintColor(SvgView svgView, Integer num) {
        svgView.setTintColor(num);
    }

    @Override // com.facebook.react.viewmanagers.RNSVGSvgViewManagerInterface
    @ReactProp(customType = "Color", name = ViewProps.COLOR)
    public void setColor(SvgView svgView, Integer num) {
        svgView.setTintColor(num);
    }

    @Override // com.facebook.react.viewmanagers.RNSVGSvgViewManagerInterface
    @ReactProp(name = "minX")
    public void setMinX(SvgView svgView, float f) {
        svgView.setMinX(f);
    }

    @Override // com.facebook.react.viewmanagers.RNSVGSvgViewManagerInterface
    @ReactProp(name = "minY")
    public void setMinY(SvgView svgView, float f) {
        svgView.setMinY(f);
    }

    @Override // com.facebook.react.viewmanagers.RNSVGSvgViewManagerInterface
    @ReactProp(name = "vbWidth")
    public void setVbWidth(SvgView svgView, float f) {
        svgView.setVbWidth(f);
    }

    @Override // com.facebook.react.viewmanagers.RNSVGSvgViewManagerInterface
    @ReactProp(name = "vbHeight")
    public void setVbHeight(SvgView svgView, float f) {
        svgView.setVbHeight(f);
    }

    @ReactProp(name = "bbWidth")
    public void setBbWidth(SvgView svgView, Dynamic dynamic) {
        svgView.setBbWidth(dynamic);
    }

    @ReactProp(name = "bbHeight")
    public void setBbHeight(SvgView svgView, Dynamic dynamic) {
        svgView.setBbHeight(dynamic);
    }

    @Override // com.facebook.react.viewmanagers.RNSVGSvgViewManagerInterface
    @ReactProp(name = "align")
    public void setAlign(SvgView svgView, String str) {
        svgView.setAlign(str);
    }

    @Override // com.facebook.react.viewmanagers.RNSVGSvgViewManagerInterface
    @ReactProp(name = "meetOrSlice")
    public void setMeetOrSlice(SvgView svgView, int i) {
        svgView.setMeetOrSlice(i);
    }

    @Override // com.facebook.react.viewmanagers.RNSVGSvgViewManagerInterface
    public void setBbWidth(SvgView svgView, @Nullable String str) {
        svgView.setBbWidth(str);
    }

    @Override // com.facebook.react.viewmanagers.RNSVGSvgViewManagerInterface
    public void setBbWidth(SvgView svgView, @Nullable Double d) {
        svgView.setBbWidth(d);
    }

    @Override // com.facebook.react.viewmanagers.RNSVGSvgViewManagerInterface
    public void setBbHeight(SvgView svgView, @Nullable String str) {
        svgView.setBbHeight(str);
    }

    @Override // com.facebook.react.viewmanagers.RNSVGSvgViewManagerInterface
    public void setBbHeight(SvgView svgView, @Nullable Double d) {
        svgView.setBbHeight(d);
    }

    @Override // com.facebook.react.viewmanagers.RNSVGSvgViewManagerInterface
    @ReactProp(name = ViewProps.POINTER_EVENTS)
    public void setPointerEvents(SvgView svgView, @Nullable String str) {
        try {
            Class<? super Object> superclass = svgView.getClass().getSuperclass();
            if (superclass != null) {
                Method declaredMethod = superclass.getDeclaredMethod("setPointerEvents", PointerEvents.class);
                declaredMethod.setAccessible(true);
                declaredMethod.invoke(svgView, PointerEvents.valueOf(str.toUpperCase(Locale.US).replace("-", "_")));
            }
        } catch (IllegalAccessException | NoSuchMethodException | InvocationTargetException e) {
            e.printStackTrace();
        }
    }
}
