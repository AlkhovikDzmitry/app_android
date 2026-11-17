package com.reactnativepagerview;

import android.view.View;
import android.view.ViewGroup;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewpager2.widget.ViewPager2;
import com.facebook.infer.annotation.Assertions;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.PixelUtil;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.UIManagerModule;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.ViewProps;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.events.EventDispatcher;
import com.reactcommunity.rndatetimepicker.RNConstants;
import com.reactnativepagerview.event.PageScrollEvent;
import com.reactnativepagerview.event.PageScrollStateChangedEvent;
import com.reactnativepagerview.event.PageSelectedEvent;
import java.util.Arrays;
import java.util.Map;
import java.util.Objects;
import kotlin.Metadata;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;
import kotlin.jvm.internal.StringCompanionObject;

/* compiled from: PagerViewViewManager.kt */
@Metadata(m41d1 = {"\u0000f\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0002\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\b\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0002\b\u0004\n\u0002\u0010$\n\u0002\u0010\u000e\n\u0000\n\u0002\u0010%\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0010\u000b\n\u0002\b\u0004\n\u0002\u0018\u0002\n\u0002\b\u000f\n\u0002\u0010\u0007\n\u0002\b\u0003\u0018\u0000 42\b\u0012\u0004\u0012\u00020\u00020\u0001:\u00014B\u0005¢\u0006\u0002\u0010\u0003J\"\u0010\u0006\u001a\u00020\u00072\u0006\u0010\b\u001a\u00020\u00022\b\u0010\t\u001a\u0004\u0018\u00010\n2\u0006\u0010\u000b\u001a\u00020\fH\u0016J\u0010\u0010\r\u001a\u00020\u00022\u0006\u0010\u000e\u001a\u00020\u000fH\u0014J\u0018\u0010\u0010\u001a\u00020\n2\u0006\u0010\u0011\u001a\u00020\u00022\u0006\u0010\u000b\u001a\u00020\fH\u0016J\u0010\u0010\u0012\u001a\u00020\f2\u0006\u0010\u0011\u001a\u00020\u0002H\u0016J\u0016\u0010\u0013\u001a\u0010\u0012\u0004\u0012\u00020\u0015\u0012\u0004\u0012\u00020\f\u0018\u00010\u0014H\u0016J \u0010\u0016\u001a\u001a\u0012\u0004\u0012\u00020\u0015\u0012\u0010\u0012\u000e\u0012\u0004\u0012\u00020\u0015\u0012\u0004\u0012\u00020\u00150\u00140\u0017H\u0016J\b\u0010\u0018\u001a\u00020\u0015H\u0016J\u0010\u0010\u0019\u001a\u00020\u001a2\u0006\u0010\u001b\u001a\u00020\u0002H\u0002J\b\u0010\u001c\u001a\u00020\u001dH\u0016J\"\u0010\u001e\u001a\u00020\u00072\u0006\u0010\u001f\u001a\u00020\u00022\u0006\u0010 \u001a\u00020\f2\b\u0010!\u001a\u0004\u0018\u00010\"H\u0016J\u0010\u0010#\u001a\u00020\u00072\u0006\u0010\u001b\u001a\u00020\nH\u0002J\u0010\u0010$\u001a\u00020\u00072\u0006\u0010\u0011\u001a\u00020\u0002H\u0016J\u0018\u0010%\u001a\u00020\u00072\u0006\u0010\u0011\u001a\u00020\u00022\u0006\u0010\u001b\u001a\u00020\nH\u0016J\u0018\u0010&\u001a\u00020\u00072\u0006\u0010\u0011\u001a\u00020\u00022\u0006\u0010\u000b\u001a\u00020\fH\u0016J\u0019\u0010'\u001a\u00020\u00072\u0006\u0010\b\u001a\u00020\u00022\u0006\u0010(\u001a\u00020\fH\u0087\u0002J \u0010)\u001a\u00020\u00072\u0006\u0010\u001b\u001a\u00020\u001a2\u0006\u0010*\u001a\u00020\f2\u0006\u0010+\u001a\u00020\u001dH\u0002J\u0018\u0010,\u001a\u00020\u00072\u0006\u0010\b\u001a\u00020\u00022\u0006\u0010(\u001a\u00020\fH\u0007J\u0018\u0010-\u001a\u00020\u00072\u0006\u0010\b\u001a\u00020\u00022\u0006\u0010(\u001a\u00020\u0015H\u0007J\u0018\u0010.\u001a\u00020\u00072\u0006\u0010\b\u001a\u00020\u00022\u0006\u0010(\u001a\u00020\u0015H\u0007J\u0018\u0010/\u001a\u00020\u00072\u0006\u0010\b\u001a\u00020\u00022\u0006\u0010(\u001a\u00020\u0015H\u0007J\u0018\u00100\u001a\u00020\u00072\u0006\u0010\b\u001a\u00020\u00022\u0006\u00101\u001a\u000202H\u0007J\u0018\u00103\u001a\u00020\u00072\u0006\u0010\b\u001a\u00020\u00022\u0006\u0010(\u001a\u00020\u001dH\u0007R\u000e\u0010\u0004\u001a\u00020\u0005X\u0082.¢\u0006\u0002\n\u0000¨\u00065"}, m40d2 = {"Lcom/reactnativepagerview/PagerViewViewManager;", "Lcom/facebook/react/uimanager/ViewGroupManager;", "Lcom/reactnativepagerview/NestedScrollableHost;", "()V", "eventDispatcher", "Lcom/facebook/react/uimanager/events/EventDispatcher;", "addView", "", "host", "child", "Landroid/view/View;", "index", "", "createViewInstance", "reactContext", "Lcom/facebook/react/uimanager/ThemedReactContext;", "getChildAt", "parent", "getChildCount", "getCommandsMap", "", "", "getExportedCustomDirectEventTypeConstants", "", "getName", "getViewPager", "Landroidx/viewpager2/widget/ViewPager2;", "view", "needsCustomLayoutForChildren", "", "receiveCommand", "root", "commandId", "args", "Lcom/facebook/react/bridge/ReadableArray;", "refreshViewChildrenLayout", "removeAllViews", "removeView", "removeViewAt", "set", RNConstants.ARG_VALUE, "setCurrentItem", "selectedTab", "scrollSmooth", "setInitialPage", "setLayoutDirection", "setOrientation", "setOverScrollMode", "setPageMargin", ViewProps.MARGIN, "", "setScrollEnabled", "Companion", "react-native-pager-view_release"}, m39k = 1, m38mv = {1, 5, 1}, m36xi = 48)
/* loaded from: classes2.dex */
public final class PagerViewViewManager extends ViewGroupManager<NestedScrollableHost> {
    private static final int COMMAND_SET_PAGE = 1;
    private static final int COMMAND_SET_PAGE_WITHOUT_ANIMATION = 2;
    private static final int COMMAND_SET_SCROLL_ENABLED = 3;
    public static final Companion Companion = new Companion(null);
    private static final String REACT_CLASS = "RNCViewPager";
    private EventDispatcher eventDispatcher;

    @Override // com.facebook.react.uimanager.ViewManager, com.facebook.react.bridge.NativeModule
    public String getName() {
        return REACT_CLASS;
    }

    @Override // com.facebook.react.uimanager.ViewGroupManager, com.facebook.react.uimanager.IViewManagerWithChildren
    public boolean needsCustomLayoutForChildren() {
        return true;
    }

    @Override // com.facebook.react.uimanager.ViewManager
    public NestedScrollableHost createViewInstance(ThemedReactContext reactContext) {
        Intrinsics.checkNotNullParameter(reactContext, "reactContext");
        ThemedReactContext themedReactContext = reactContext;
        final NestedScrollableHost nestedScrollableHost = new NestedScrollableHost(themedReactContext);
        nestedScrollableHost.setId(View.generateViewId());
        nestedScrollableHost.setLayoutParams(new ViewGroup.LayoutParams(-1, -1));
        nestedScrollableHost.setSaveEnabled(false);
        final ViewPager2 viewPager2 = new ViewPager2(themedReactContext);
        viewPager2.setAdapter(new ViewPagerAdapter());
        viewPager2.setSaveEnabled(false);
        NativeModule nativeModule = reactContext.getNativeModule(UIManagerModule.class);
        Intrinsics.checkNotNull(nativeModule);
        EventDispatcher eventDispatcher = ((UIManagerModule) nativeModule).getEventDispatcher();
        Intrinsics.checkNotNullExpressionValue(eventDispatcher, "reactContext.getNativeMo…s.java)!!.eventDispatcher");
        this.eventDispatcher = eventDispatcher;
        viewPager2.post(new Runnable() { // from class: com.reactnativepagerview.PagerViewViewManager$$ExternalSyntheticLambda2
            @Override // java.lang.Runnable
            public final void run() {
                PagerViewViewManager.m348createViewInstance$lambda0(ViewPager2.this, this, nestedScrollableHost);
            }
        });
        nestedScrollableHost.addView(viewPager2);
        return nestedScrollableHost;
    }

    /* renamed from: createViewInstance$lambda-0 */
    public static final void m348createViewInstance$lambda0(ViewPager2 vp, PagerViewViewManager this$0, final NestedScrollableHost host) {
        Intrinsics.checkNotNullParameter(vp, "$vp");
        Intrinsics.checkNotNullParameter(this$0, "this$0");
        Intrinsics.checkNotNullParameter(host, "$host");
        vp.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() { // from class: com.reactnativepagerview.PagerViewViewManager$createViewInstance$1$1
            @Override // androidx.viewpager2.widget.ViewPager2.OnPageChangeCallback
            public void onPageScrolled(int i, float f, int i2) {
                EventDispatcher eventDispatcher;
                super.onPageScrolled(i, f, i2);
                eventDispatcher = PagerViewViewManager.this.eventDispatcher;
                if (eventDispatcher == null) {
                    Intrinsics.throwUninitializedPropertyAccessException("eventDispatcher");
                    eventDispatcher = null;
                }
                eventDispatcher.dispatchEvent(new PageScrollEvent(host.getId(), i, f));
            }

            @Override // androidx.viewpager2.widget.ViewPager2.OnPageChangeCallback
            public void onPageSelected(int i) {
                EventDispatcher eventDispatcher;
                super.onPageSelected(i);
                eventDispatcher = PagerViewViewManager.this.eventDispatcher;
                if (eventDispatcher == null) {
                    Intrinsics.throwUninitializedPropertyAccessException("eventDispatcher");
                    eventDispatcher = null;
                }
                eventDispatcher.dispatchEvent(new PageSelectedEvent(host.getId(), i));
            }

            @Override // androidx.viewpager2.widget.ViewPager2.OnPageChangeCallback
            public void onPageScrollStateChanged(int i) {
                String str;
                EventDispatcher eventDispatcher;
                super.onPageScrollStateChanged(i);
                if (i == 0) {
                    str = "idle";
                } else if (i == 1) {
                    str = "dragging";
                } else if (i != 2) {
                    throw new IllegalStateException("Unsupported pageScrollState");
                } else {
                    str = "settling";
                }
                eventDispatcher = PagerViewViewManager.this.eventDispatcher;
                if (eventDispatcher == null) {
                    Intrinsics.throwUninitializedPropertyAccessException("eventDispatcher");
                    eventDispatcher = null;
                }
                eventDispatcher.dispatchEvent(new PageScrollStateChangedEvent(host.getId(), str));
            }
        });
        EventDispatcher eventDispatcher = this$0.eventDispatcher;
        if (eventDispatcher == null) {
            Intrinsics.throwUninitializedPropertyAccessException("eventDispatcher");
            eventDispatcher = null;
        }
        eventDispatcher.dispatchEvent(new PageSelectedEvent(host.getId(), vp.getCurrentItem()));
    }

    private final ViewPager2 getViewPager(NestedScrollableHost nestedScrollableHost) {
        if (nestedScrollableHost.getChildAt(0) instanceof ViewPager2) {
            View childAt = nestedScrollableHost.getChildAt(0);
            Objects.requireNonNull(childAt, "null cannot be cast to non-null type androidx.viewpager2.widget.ViewPager2");
            return (ViewPager2) childAt;
        }
        throw new ClassNotFoundException("Could not retrieve ViewPager2 instance");
    }

    private final void setCurrentItem(ViewPager2 viewPager2, int i, boolean z) {
        refreshViewChildrenLayout(viewPager2);
        viewPager2.setCurrentItem(i, z);
    }

    @Override // com.facebook.react.uimanager.ViewGroupManager
    public void addView(NestedScrollableHost host, View view, int i) {
        Integer initialIndex;
        Intrinsics.checkNotNullParameter(host, "host");
        if (view == null) {
            return;
        }
        ViewPager2 viewPager = getViewPager(host);
        ViewPagerAdapter viewPagerAdapter = (ViewPagerAdapter) viewPager.getAdapter();
        if (viewPagerAdapter != null) {
            viewPagerAdapter.addChild(view, i);
        }
        if (viewPager.getCurrentItem() == i) {
            refreshViewChildrenLayout(viewPager);
        }
        if (host.getDidSetInitialIndex() || (initialIndex = host.getInitialIndex()) == null || initialIndex.intValue() != i) {
            return;
        }
        host.setDidSetInitialIndex(true);
        setCurrentItem(viewPager, i, false);
    }

    @Override // com.facebook.react.uimanager.ViewGroupManager
    public int getChildCount(NestedScrollableHost parent) {
        Intrinsics.checkNotNullParameter(parent, "parent");
        RecyclerView.Adapter adapter = getViewPager(parent).getAdapter();
        if (adapter == null) {
            return 0;
        }
        return adapter.getItemCount();
    }

    @Override // com.facebook.react.uimanager.ViewGroupManager
    public View getChildAt(NestedScrollableHost parent, int i) {
        Intrinsics.checkNotNullParameter(parent, "parent");
        ViewPagerAdapter viewPagerAdapter = (ViewPagerAdapter) getViewPager(parent).getAdapter();
        Intrinsics.checkNotNull(viewPagerAdapter);
        return viewPagerAdapter.getChildAt(i);
    }

    @Override // com.facebook.react.uimanager.ViewGroupManager
    public void removeView(NestedScrollableHost parent, View view) {
        Intrinsics.checkNotNullParameter(parent, "parent");
        Intrinsics.checkNotNullParameter(view, "view");
        ViewPager2 viewPager = getViewPager(parent);
        ViewPagerAdapter viewPagerAdapter = (ViewPagerAdapter) viewPager.getAdapter();
        if (viewPagerAdapter != null) {
            viewPagerAdapter.removeChild(view);
        }
        refreshViewChildrenLayout(viewPager);
    }

    @Override // com.facebook.react.uimanager.ViewGroupManager
    public void removeAllViews(NestedScrollableHost parent) {
        Intrinsics.checkNotNullParameter(parent, "parent");
        ViewPager2 viewPager = getViewPager(parent);
        viewPager.setUserInputEnabled(false);
        ViewPagerAdapter viewPagerAdapter = (ViewPagerAdapter) viewPager.getAdapter();
        if (viewPagerAdapter == null) {
            return;
        }
        viewPagerAdapter.removeAll();
    }

    @Override // com.facebook.react.uimanager.ViewGroupManager
    public void removeViewAt(NestedScrollableHost parent, int i) {
        Intrinsics.checkNotNullParameter(parent, "parent");
        ViewPager2 viewPager = getViewPager(parent);
        ViewPagerAdapter viewPagerAdapter = (ViewPagerAdapter) viewPager.getAdapter();
        if (viewPagerAdapter != null) {
            viewPagerAdapter.removeChildAt(i);
        }
        refreshViewChildrenLayout(viewPager);
    }

    @ReactProp(defaultBoolean = com.swmansion.reanimated.BuildConfig.DEBUG, name = "scrollEnabled")
    public final void setScrollEnabled(NestedScrollableHost host, boolean z) {
        Intrinsics.checkNotNullParameter(host, "host");
        getViewPager(host).setUserInputEnabled(z);
    }

    @ReactProp(defaultInt = 0, name = "initialPage")
    public final void setInitialPage(final NestedScrollableHost host, int i) {
        Intrinsics.checkNotNullParameter(host, "host");
        ViewPager2 viewPager = getViewPager(host);
        if (host.getInitialIndex() == null) {
            host.setInitialIndex(Integer.valueOf(i));
            viewPager.post(new Runnable() { // from class: com.reactnativepagerview.PagerViewViewManager$$ExternalSyntheticLambda3
                @Override // java.lang.Runnable
                public final void run() {
                    PagerViewViewManager.m350setInitialPage$lambda1(NestedScrollableHost.this);
                }
            });
        }
    }

    /* renamed from: setInitialPage$lambda-1 */
    public static final void m350setInitialPage$lambda1(NestedScrollableHost host) {
        Intrinsics.checkNotNullParameter(host, "$host");
        host.setDidSetInitialIndex(true);
    }

    @ReactProp(name = "orientation")
    public final void setOrientation(NestedScrollableHost host, String value) {
        Intrinsics.checkNotNullParameter(host, "host");
        Intrinsics.checkNotNullParameter(value, "value");
        getViewPager(host).setOrientation(Intrinsics.areEqual(value, "vertical") ? 1 : 0);
    }

    @ReactProp(defaultInt = -1, name = "offscreenPageLimit")
    public final void set(NestedScrollableHost host, int i) {
        Intrinsics.checkNotNullParameter(host, "host");
        getViewPager(host).setOffscreenPageLimit(i);
    }

    @ReactProp(name = "overScrollMode")
    public final void setOverScrollMode(NestedScrollableHost host, String value) {
        Intrinsics.checkNotNullParameter(host, "host");
        Intrinsics.checkNotNullParameter(value, "value");
        View childAt = getViewPager(host).getChildAt(0);
        if (Intrinsics.areEqual(value, "never")) {
            childAt.setOverScrollMode(2);
        } else if (Intrinsics.areEqual(value, "always")) {
            childAt.setOverScrollMode(0);
        } else {
            childAt.setOverScrollMode(1);
        }
    }

    @ReactProp(name = ViewProps.LAYOUT_DIRECTION)
    public final void setLayoutDirection(NestedScrollableHost host, String value) {
        Intrinsics.checkNotNullParameter(host, "host");
        Intrinsics.checkNotNullParameter(value, "value");
        ViewPager2 viewPager = getViewPager(host);
        if (Intrinsics.areEqual(value, "rtl")) {
            viewPager.setLayoutDirection(1);
        } else {
            viewPager.setLayoutDirection(0);
        }
    }

    @Override // com.facebook.react.uimanager.BaseViewManager, com.facebook.react.uimanager.ViewManager
    public Map<String, Map<String, String>> getExportedCustomDirectEventTypeConstants() {
        Map<String, Map<String, String>> m178of = MapBuilder.m178of(PageScrollEvent.EVENT_NAME, MapBuilder.m180of("registrationName", "onPageScroll"), PageScrollStateChangedEvent.EVENT_NAME, MapBuilder.m180of("registrationName", "onPageScrollStateChanged"), PageSelectedEvent.EVENT_NAME, MapBuilder.m180of("registrationName", "onPageSelected"));
        Intrinsics.checkNotNullExpressionValue(m178of, "of(\n      PageScrollEven…Name\", \"onPageSelected\"))");
        return m178of;
    }

    @Override // com.facebook.react.uimanager.ViewManager
    public Map<String, Integer> getCommandsMap() {
        return MapBuilder.m178of("setPage", 1, "setPageWithoutAnimation", 2, "setScrollEnabled", 3);
    }

    @Override // com.facebook.react.uimanager.ViewManager
    public void receiveCommand(NestedScrollableHost root, int i, ReadableArray readableArray) {
        Intrinsics.checkNotNullParameter(root, "root");
        super.receiveCommand((PagerViewViewManager) root, i, readableArray);
        ViewPager2 viewPager = getViewPager(root);
        Assertions.assertNotNull(viewPager);
        Assertions.assertNotNull(readableArray);
        RecyclerView.Adapter adapter = viewPager.getAdapter();
        EventDispatcher eventDispatcher = null;
        Integer valueOf = adapter == null ? null : Integer.valueOf(adapter.getItemCount());
        if (i != 1 && i != 2) {
            if (i == 3) {
                Intrinsics.checkNotNull(readableArray);
                viewPager.setUserInputEnabled(readableArray.getBoolean(0));
                return;
            }
            StringCompanionObject stringCompanionObject = StringCompanionObject.INSTANCE;
            String format = String.format("Unsupported command %d received by %s.", Arrays.copyOf(new Object[]{Integer.valueOf(i), getClass().getSimpleName()}, 2));
            Intrinsics.checkNotNullExpressionValue(format, "format(format, *args)");
            throw new IllegalArgumentException(format);
        }
        Intrinsics.checkNotNull(readableArray);
        int i2 = readableArray.getInt(0);
        if (valueOf != null && valueOf.intValue() > 0 && i2 >= 0 && i2 < valueOf.intValue()) {
            setCurrentItem(viewPager, i2, i == 1);
            EventDispatcher eventDispatcher2 = this.eventDispatcher;
            if (eventDispatcher2 == null) {
                Intrinsics.throwUninitializedPropertyAccessException("eventDispatcher");
            } else {
                eventDispatcher = eventDispatcher2;
            }
            eventDispatcher.dispatchEvent(new PageSelectedEvent(root.getId(), i2));
        }
    }

    @ReactProp(defaultFloat = 0.0f, name = "pageMargin")
    public final void setPageMargin(NestedScrollableHost host, float f) {
        Intrinsics.checkNotNullParameter(host, "host");
        final ViewPager2 viewPager = getViewPager(host);
        final int pixelFromDIP = (int) PixelUtil.toPixelFromDIP(f);
        viewPager.setPageTransformer(new ViewPager2.PageTransformer() { // from class: com.reactnativepagerview.PagerViewViewManager$$ExternalSyntheticLambda0
            @Override // androidx.viewpager2.widget.ViewPager2.PageTransformer
            public final void transformPage(View view, float f2) {
                PagerViewViewManager.m351setPageMargin$lambda2(pixelFromDIP, viewPager, view, f2);
            }
        });
    }

    /* renamed from: setPageMargin$lambda-2 */
    public static final void m351setPageMargin$lambda2(int i, ViewPager2 pager, View page, float f) {
        Intrinsics.checkNotNullParameter(pager, "$pager");
        Intrinsics.checkNotNullParameter(page, "page");
        float f2 = i * f;
        if (pager.getOrientation() == 0) {
            if (pager.getLayoutDirection() == 1) {
                f2 = -f2;
            }
            page.setTranslationX(f2);
            return;
        }
        page.setTranslationY(f2);
    }

    private final void refreshViewChildrenLayout(final View view) {
        view.post(new Runnable() { // from class: com.reactnativepagerview.PagerViewViewManager$$ExternalSyntheticLambda1
            @Override // java.lang.Runnable
            public final void run() {
                PagerViewViewManager.m349refreshViewChildrenLayout$lambda3(view);
            }
        });
    }

    /* renamed from: refreshViewChildrenLayout$lambda-3 */
    public static final void m349refreshViewChildrenLayout$lambda3(View view) {
        Intrinsics.checkNotNullParameter(view, "$view");
        view.measure(View.MeasureSpec.makeMeasureSpec(view.getWidth(), 1073741824), View.MeasureSpec.makeMeasureSpec(view.getHeight(), 1073741824));
        view.layout(view.getLeft(), view.getTop(), view.getRight(), view.getBottom());
    }

    /* compiled from: PagerViewViewManager.kt */
    @Metadata(m41d1 = {"\u0000\u001a\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0002\n\u0002\u0010\b\n\u0002\b\u0003\n\u0002\u0010\u000e\n\u0000\b\u0086\u0003\u0018\u00002\u00020\u0001B\u0007\b\u0002¢\u0006\u0002\u0010\u0002R\u000e\u0010\u0003\u001a\u00020\u0004X\u0082T¢\u0006\u0002\n\u0000R\u000e\u0010\u0005\u001a\u00020\u0004X\u0082T¢\u0006\u0002\n\u0000R\u000e\u0010\u0006\u001a\u00020\u0004X\u0082T¢\u0006\u0002\n\u0000R\u000e\u0010\u0007\u001a\u00020\bX\u0082T¢\u0006\u0002\n\u0000¨\u0006\t"}, m40d2 = {"Lcom/reactnativepagerview/PagerViewViewManager$Companion;", "", "()V", "COMMAND_SET_PAGE", "", "COMMAND_SET_PAGE_WITHOUT_ANIMATION", "COMMAND_SET_SCROLL_ENABLED", "REACT_CLASS", "", "react-native-pager-view_release"}, m39k = 1, m38mv = {1, 5, 1}, m36xi = 48)
    /* loaded from: classes2.dex */
    public static final class Companion {
        public /* synthetic */ Companion(DefaultConstructorMarker defaultConstructorMarker) {
            this();
        }

        private Companion() {
        }
    }
}
