package com.facebook.react.animated;

import android.util.SparseArray;
import com.facebook.common.logging.FLog;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.JSApplicationCausedNativeException;
import com.facebook.react.bridge.JSApplicationIllegalArgumentException;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactNoCrashSoftException;
import com.facebook.react.bridge.ReactSoftExceptionLogger;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.UIManager;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.uimanager.UIManagerHelper;
import com.facebook.react.uimanager.ViewProps;
import com.facebook.react.uimanager.events.Event;
import com.facebook.react.uimanager.events.EventDispatcher;
import com.facebook.react.uimanager.events.EventDispatcherListener;
import com.reactcommunity.rndatetimepicker.RNConstants;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;

/* loaded from: classes.dex */
public class NativeAnimatedNodesManager implements EventDispatcherListener {
    private static final String TAG = "NativeAnimatedNodesManager";
    private final ReactApplicationContext mReactApplicationContext;
    private final SparseArray<AnimatedNode> mAnimatedNodes = new SparseArray<>();
    private final SparseArray<AnimationDriver> mActiveAnimations = new SparseArray<>();
    private final SparseArray<AnimatedNode> mUpdatedNodes = new SparseArray<>();
    private final Map<String, List<EventAnimationDriver>> mEventDrivers = new HashMap();
    private int mAnimatedGraphBFSColor = 0;
    private final List<AnimatedNode> mRunUpdateNodeList = new LinkedList();
    private boolean mEventListenerInitializedForFabric = false;
    private boolean mEventListenerInitializedForNonFabric = false;
    private boolean mWarnedAboutGraphTraversal = false;

    public NativeAnimatedNodesManager(ReactApplicationContext reactApplicationContext) {
        this.mReactApplicationContext = reactApplicationContext;
    }

    public void initializeEventListenerForUIManagerType(int i) {
        if (i == 2) {
            if (this.mEventListenerInitializedForFabric) {
                return;
            }
        } else if (this.mEventListenerInitializedForNonFabric) {
            return;
        }
        UIManager uIManager = UIManagerHelper.getUIManager(this.mReactApplicationContext, i);
        if (uIManager != null) {
            ((EventDispatcher) uIManager.getEventDispatcher()).addListener(this);
            if (i == 2) {
                this.mEventListenerInitializedForFabric = true;
            } else {
                this.mEventListenerInitializedForNonFabric = true;
            }
        }
    }

    public AnimatedNode getNodeById(int i) {
        return this.mAnimatedNodes.get(i);
    }

    public boolean hasActiveAnimations() {
        return this.mActiveAnimations.size() > 0 || this.mUpdatedNodes.size() > 0;
    }

    public void createAnimatedNode(int i, ReadableMap readableMap) {
        AnimatedNode trackingAnimatedNode;
        if (this.mAnimatedNodes.get(i) != null) {
            throw new JSApplicationIllegalArgumentException("createAnimatedNode: Animated node [" + i + "] already exists");
        }
        String string = readableMap.getString("type");
        if ("style".equals(string)) {
            trackingAnimatedNode = new StyleAnimatedNode(readableMap, this);
        } else if (RNConstants.ARG_VALUE.equals(string)) {
            trackingAnimatedNode = new ValueAnimatedNode(readableMap);
        } else if (ViewProps.COLOR.equals(string)) {
            trackingAnimatedNode = new ColorAnimatedNode(readableMap, this, this.mReactApplicationContext);
        } else if ("props".equals(string)) {
            trackingAnimatedNode = new PropsAnimatedNode(readableMap, this);
        } else if ("interpolation".equals(string)) {
            trackingAnimatedNode = new InterpolationAnimatedNode(readableMap);
        } else if ("addition".equals(string)) {
            trackingAnimatedNode = new AdditionAnimatedNode(readableMap, this);
        } else if ("subtraction".equals(string)) {
            trackingAnimatedNode = new SubtractionAnimatedNode(readableMap, this);
        } else if ("division".equals(string)) {
            trackingAnimatedNode = new DivisionAnimatedNode(readableMap, this);
        } else if ("multiplication".equals(string)) {
            trackingAnimatedNode = new MultiplicationAnimatedNode(readableMap, this);
        } else if ("modulus".equals(string)) {
            trackingAnimatedNode = new ModulusAnimatedNode(readableMap, this);
        } else if ("diffclamp".equals(string)) {
            trackingAnimatedNode = new DiffClampAnimatedNode(readableMap, this);
        } else if (ViewProps.TRANSFORM.equals(string)) {
            trackingAnimatedNode = new TransformAnimatedNode(readableMap, this);
        } else if ("tracking".equals(string)) {
            trackingAnimatedNode = new TrackingAnimatedNode(readableMap, this);
        } else {
            throw new JSApplicationIllegalArgumentException("Unsupported node type: " + string);
        }
        trackingAnimatedNode.mTag = i;
        this.mAnimatedNodes.put(i, trackingAnimatedNode);
        this.mUpdatedNodes.put(i, trackingAnimatedNode);
    }

    public void updateAnimatedNodeConfig(int i, ReadableMap readableMap) {
        AnimatedNode animatedNode = this.mAnimatedNodes.get(i);
        if (animatedNode == null) {
            throw new JSApplicationIllegalArgumentException("updateAnimatedNode: Animated node [" + i + "] does not exist");
        } else if (animatedNode instanceof AnimatedNodeWithUpdateableConfig) {
            stopAnimationsForNode(animatedNode);
            ((AnimatedNodeWithUpdateableConfig) animatedNode).onUpdateConfig(readableMap);
            this.mUpdatedNodes.put(i, animatedNode);
        }
    }

    public void dropAnimatedNode(int i) {
        this.mAnimatedNodes.remove(i);
        this.mUpdatedNodes.remove(i);
    }

    public void startListeningToAnimatedNodeValue(int i, AnimatedNodeValueListener animatedNodeValueListener) {
        AnimatedNode animatedNode = this.mAnimatedNodes.get(i);
        if (animatedNode == null || !(animatedNode instanceof ValueAnimatedNode)) {
            throw new JSApplicationIllegalArgumentException("startListeningToAnimatedNodeValue: Animated node [" + i + "] does not exist, or is not a 'value' node");
        }
        ((ValueAnimatedNode) animatedNode).setValueListener(animatedNodeValueListener);
    }

    public void stopListeningToAnimatedNodeValue(int i) {
        AnimatedNode animatedNode = this.mAnimatedNodes.get(i);
        if (animatedNode == null || !(animatedNode instanceof ValueAnimatedNode)) {
            throw new JSApplicationIllegalArgumentException("startListeningToAnimatedNodeValue: Animated node [" + i + "] does not exist, or is not a 'value' node");
        }
        ((ValueAnimatedNode) animatedNode).setValueListener(null);
    }

    public void setAnimatedNodeValue(int i, double d) {
        AnimatedNode animatedNode = this.mAnimatedNodes.get(i);
        if (animatedNode == null || !(animatedNode instanceof ValueAnimatedNode)) {
            throw new JSApplicationIllegalArgumentException("setAnimatedNodeValue: Animated node [" + i + "] does not exist, or is not a 'value' node");
        }
        stopAnimationsForNode(animatedNode);
        ((ValueAnimatedNode) animatedNode).mValue = d;
        this.mUpdatedNodes.put(i, animatedNode);
    }

    public void setAnimatedNodeOffset(int i, double d) {
        AnimatedNode animatedNode = this.mAnimatedNodes.get(i);
        if (animatedNode == null || !(animatedNode instanceof ValueAnimatedNode)) {
            throw new JSApplicationIllegalArgumentException("setAnimatedNodeOffset: Animated node [" + i + "] does not exist, or is not a 'value' node");
        }
        ((ValueAnimatedNode) animatedNode).mOffset = d;
        this.mUpdatedNodes.put(i, animatedNode);
    }

    public void flattenAnimatedNodeOffset(int i) {
        AnimatedNode animatedNode = this.mAnimatedNodes.get(i);
        if (animatedNode == null || !(animatedNode instanceof ValueAnimatedNode)) {
            throw new JSApplicationIllegalArgumentException("flattenAnimatedNodeOffset: Animated node [" + i + "] does not exist, or is not a 'value' node");
        }
        ((ValueAnimatedNode) animatedNode).flattenOffset();
    }

    public void extractAnimatedNodeOffset(int i) {
        AnimatedNode animatedNode = this.mAnimatedNodes.get(i);
        if (animatedNode == null || !(animatedNode instanceof ValueAnimatedNode)) {
            throw new JSApplicationIllegalArgumentException("extractAnimatedNodeOffset: Animated node [" + i + "] does not exist, or is not a 'value' node");
        }
        ((ValueAnimatedNode) animatedNode).extractOffset();
    }

    public void startAnimatingNode(int i, int i2, ReadableMap readableMap, Callback callback) {
        AnimationDriver decayAnimation;
        AnimatedNode animatedNode = this.mAnimatedNodes.get(i2);
        if (animatedNode == null) {
            throw new JSApplicationIllegalArgumentException("startAnimatingNode: Animated node [" + i2 + "] does not exist");
        } else if (!(animatedNode instanceof ValueAnimatedNode)) {
            throw new JSApplicationIllegalArgumentException("startAnimatingNode: Animated node [" + i2 + "] should be of type " + ValueAnimatedNode.class.getName());
        } else {
            AnimationDriver animationDriver = this.mActiveAnimations.get(i);
            if (animationDriver != null) {
                animationDriver.resetConfig(readableMap);
                return;
            }
            String string = readableMap.getString("type");
            if ("frames".equals(string)) {
                decayAnimation = new FrameBasedAnimationDriver(readableMap);
            } else if ("spring".equals(string)) {
                decayAnimation = new SpringAnimation(readableMap);
            } else if ("decay".equals(string)) {
                decayAnimation = new DecayAnimation(readableMap);
            } else {
                throw new JSApplicationIllegalArgumentException("startAnimatingNode: Unsupported animation type [" + i2 + "]: " + string);
            }
            decayAnimation.mId = i;
            decayAnimation.mEndCallback = callback;
            decayAnimation.mAnimatedValue = (ValueAnimatedNode) animatedNode;
            this.mActiveAnimations.put(i, decayAnimation);
        }
    }

    private void stopAnimationsForNode(AnimatedNode animatedNode) {
        int i = 0;
        while (i < this.mActiveAnimations.size()) {
            AnimationDriver valueAt = this.mActiveAnimations.valueAt(i);
            if (animatedNode.equals(valueAt.mAnimatedValue)) {
                if (valueAt.mEndCallback != null) {
                    WritableMap createMap = Arguments.createMap();
                    createMap.putBoolean("finished", false);
                    valueAt.mEndCallback.invoke(createMap);
                } else if (this.mReactApplicationContext != null) {
                    WritableMap createMap2 = Arguments.createMap();
                    createMap2.putInt("animationId", valueAt.mId);
                    createMap2.putBoolean("finished", false);
                    ((DeviceEventManagerModule.RCTDeviceEventEmitter) this.mReactApplicationContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)).emit("onNativeAnimatedModuleAnimationFinished", createMap2);
                }
                this.mActiveAnimations.removeAt(i);
                i--;
            }
            i++;
        }
    }

    public void stopAnimation(int i) {
        for (int i2 = 0; i2 < this.mActiveAnimations.size(); i2++) {
            AnimationDriver valueAt = this.mActiveAnimations.valueAt(i2);
            if (valueAt.mId == i) {
                if (valueAt.mEndCallback != null) {
                    WritableMap createMap = Arguments.createMap();
                    createMap.putBoolean("finished", false);
                    valueAt.mEndCallback.invoke(createMap);
                } else if (this.mReactApplicationContext != null) {
                    WritableMap createMap2 = Arguments.createMap();
                    createMap2.putInt("animationId", valueAt.mId);
                    createMap2.putBoolean("finished", false);
                    ((DeviceEventManagerModule.RCTDeviceEventEmitter) this.mReactApplicationContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)).emit("onNativeAnimatedModuleAnimationFinished", createMap2);
                }
                this.mActiveAnimations.removeAt(i2);
                return;
            }
        }
    }

    public void connectAnimatedNodes(int i, int i2) {
        AnimatedNode animatedNode = this.mAnimatedNodes.get(i);
        if (animatedNode == null) {
            throw new JSApplicationIllegalArgumentException("connectAnimatedNodes: Animated node with tag (parent) [" + i + "] does not exist");
        }
        AnimatedNode animatedNode2 = this.mAnimatedNodes.get(i2);
        if (animatedNode2 == null) {
            throw new JSApplicationIllegalArgumentException("connectAnimatedNodes: Animated node with tag (child) [" + i2 + "] does not exist");
        }
        animatedNode.addChild(animatedNode2);
        this.mUpdatedNodes.put(i2, animatedNode2);
    }

    public void disconnectAnimatedNodes(int i, int i2) {
        AnimatedNode animatedNode = this.mAnimatedNodes.get(i);
        if (animatedNode == null) {
            throw new JSApplicationIllegalArgumentException("disconnectAnimatedNodes: Animated node with tag (parent) [" + i + "] does not exist");
        }
        AnimatedNode animatedNode2 = this.mAnimatedNodes.get(i2);
        if (animatedNode2 == null) {
            throw new JSApplicationIllegalArgumentException("disconnectAnimatedNodes: Animated node with tag (child) [" + i2 + "] does not exist");
        }
        animatedNode.removeChild(animatedNode2);
        this.mUpdatedNodes.put(i2, animatedNode2);
    }

    public void connectAnimatedNodeToView(int i, int i2) {
        AnimatedNode animatedNode = this.mAnimatedNodes.get(i);
        if (animatedNode == null) {
            throw new JSApplicationIllegalArgumentException("connectAnimatedNodeToView: Animated node with tag [" + i + "] does not exist");
        } else if (!(animatedNode instanceof PropsAnimatedNode)) {
            throw new JSApplicationIllegalArgumentException("connectAnimatedNodeToView: Animated node connected to view [" + i2 + "] should be of type " + PropsAnimatedNode.class.getName());
        } else {
            ReactApplicationContext reactApplicationContext = this.mReactApplicationContext;
            if (reactApplicationContext == null) {
                throw new IllegalStateException("connectAnimatedNodeToView: Animated node could not be connected, no ReactApplicationContext: " + i2);
            }
            UIManager uIManagerForReactTag = UIManagerHelper.getUIManagerForReactTag(reactApplicationContext, i2);
            if (uIManagerForReactTag == null) {
                ReactSoftExceptionLogger.logSoftException(TAG, new ReactNoCrashSoftException("connectAnimatedNodeToView: Animated node could not be connected to UIManager - uiManager disappeared for tag: " + i2));
                return;
            }
            ((PropsAnimatedNode) animatedNode).connectToView(i2, uIManagerForReactTag);
            this.mUpdatedNodes.put(i, animatedNode);
        }
    }

    public void disconnectAnimatedNodeFromView(int i, int i2) {
        AnimatedNode animatedNode = this.mAnimatedNodes.get(i);
        if (animatedNode == null) {
            throw new JSApplicationIllegalArgumentException("disconnectAnimatedNodeFromView: Animated node with tag [" + i + "] does not exist");
        } else if (!(animatedNode instanceof PropsAnimatedNode)) {
            throw new JSApplicationIllegalArgumentException("disconnectAnimatedNodeFromView: Animated node connected to view [" + i2 + "] should be of type " + PropsAnimatedNode.class.getName());
        } else {
            ((PropsAnimatedNode) animatedNode).disconnectFromView(i2);
        }
    }

    public void getValue(int i, Callback callback) {
        AnimatedNode animatedNode = this.mAnimatedNodes.get(i);
        if (animatedNode == null || !(animatedNode instanceof ValueAnimatedNode)) {
            throw new JSApplicationIllegalArgumentException("getValue: Animated node with tag [" + i + "] does not exist or is not a 'value' node");
        }
        double value = ((ValueAnimatedNode) animatedNode).getValue();
        if (callback != null) {
            callback.invoke(Double.valueOf(value));
        } else if (this.mReactApplicationContext == null) {
        } else {
            WritableMap createMap = Arguments.createMap();
            createMap.putInt("tag", i);
            createMap.putDouble(RNConstants.ARG_VALUE, value);
            ((DeviceEventManagerModule.RCTDeviceEventEmitter) this.mReactApplicationContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)).emit("onNativeAnimatedModuleGetValue", createMap);
        }
    }

    public void restoreDefaultValues(int i) {
        AnimatedNode animatedNode = this.mAnimatedNodes.get(i);
        if (animatedNode == null) {
            return;
        }
        if (!(animatedNode instanceof PropsAnimatedNode)) {
            throw new JSApplicationIllegalArgumentException("Animated node connected to view [?] should be of type " + PropsAnimatedNode.class.getName());
        }
        ((PropsAnimatedNode) animatedNode).restoreDefaultValues();
    }

    public void addAnimatedEventToView(int i, String str, ReadableMap readableMap) {
        int i2 = readableMap.getInt("animatedValueTag");
        AnimatedNode animatedNode = this.mAnimatedNodes.get(i2);
        if (animatedNode == null) {
            throw new JSApplicationIllegalArgumentException("addAnimatedEventToView: Animated node with tag [" + i2 + "] does not exist");
        } else if (!(animatedNode instanceof ValueAnimatedNode)) {
            throw new JSApplicationIllegalArgumentException("addAnimatedEventToView: Animated node on view [" + i + "] connected to event (" + str + ") should be of type " + ValueAnimatedNode.class.getName());
        } else {
            ReadableArray array = readableMap.getArray("nativeEventPath");
            ArrayList arrayList = new ArrayList(array.size());
            for (int i3 = 0; i3 < array.size(); i3++) {
                arrayList.add(array.getString(i3));
            }
            EventAnimationDriver eventAnimationDriver = new EventAnimationDriver(arrayList, (ValueAnimatedNode) animatedNode);
            String str2 = i + str;
            if (this.mEventDrivers.containsKey(str2)) {
                this.mEventDrivers.get(str2).add(eventAnimationDriver);
                return;
            }
            ArrayList arrayList2 = new ArrayList(1);
            arrayList2.add(eventAnimationDriver);
            this.mEventDrivers.put(str2, arrayList2);
        }
    }

    public void removeAnimatedEventFromView(int i, String str, int i2) {
        String str2 = i + str;
        if (this.mEventDrivers.containsKey(str2)) {
            List<EventAnimationDriver> list = this.mEventDrivers.get(str2);
            if (list.size() == 1) {
                this.mEventDrivers.remove(i + str);
                return;
            }
            ListIterator<EventAnimationDriver> listIterator = list.listIterator();
            while (listIterator.hasNext()) {
                if (listIterator.next().mValueNode.mTag == i2) {
                    listIterator.remove();
                    return;
                }
            }
        }
    }

    @Override // com.facebook.react.uimanager.events.EventDispatcherListener
    public void onEventDispatch(final Event event) {
        if (UiThreadUtil.isOnUiThread()) {
            handleEvent(event);
        } else {
            UiThreadUtil.runOnUiThread(new Runnable() { // from class: com.facebook.react.animated.NativeAnimatedNodesManager.1
                @Override // java.lang.Runnable
                public void run() {
                    NativeAnimatedNodesManager.this.handleEvent(event);
                }
            });
        }
    }

    public void handleEvent(Event event) {
        ReactApplicationContext reactApplicationContext;
        UIManager uIManager;
        if (this.mEventDrivers.isEmpty() || (reactApplicationContext = this.mReactApplicationContext) == null || (uIManager = UIManagerHelper.getUIManager(reactApplicationContext, event.getUIManagerType())) == null) {
            return;
        }
        String resolveCustomDirectEventName = uIManager.resolveCustomDirectEventName(event.getEventName());
        if (resolveCustomDirectEventName == null) {
            resolveCustomDirectEventName = "";
        }
        Map<String, List<EventAnimationDriver>> map = this.mEventDrivers;
        List<EventAnimationDriver> list = map.get(event.getViewTag() + resolveCustomDirectEventName);
        if (list != null) {
            for (EventAnimationDriver eventAnimationDriver : list) {
                stopAnimationsForNode(eventAnimationDriver.mValueNode);
                event.dispatch(eventAnimationDriver);
                this.mRunUpdateNodeList.add(eventAnimationDriver.mValueNode);
            }
            updateNodes(this.mRunUpdateNodeList);
            this.mRunUpdateNodeList.clear();
        }
    }

    public void runUpdates(long j) {
        UiThreadUtil.assertOnUiThread();
        for (int i = 0; i < this.mUpdatedNodes.size(); i++) {
            this.mRunUpdateNodeList.add(this.mUpdatedNodes.valueAt(i));
        }
        this.mUpdatedNodes.clear();
        boolean z = false;
        for (int i2 = 0; i2 < this.mActiveAnimations.size(); i2++) {
            AnimationDriver valueAt = this.mActiveAnimations.valueAt(i2);
            valueAt.runAnimationStep(j);
            this.mRunUpdateNodeList.add(valueAt.mAnimatedValue);
            if (valueAt.mHasFinished) {
                z = true;
            }
        }
        updateNodes(this.mRunUpdateNodeList);
        this.mRunUpdateNodeList.clear();
        if (z) {
            for (int size = this.mActiveAnimations.size() - 1; size >= 0; size--) {
                AnimationDriver valueAt2 = this.mActiveAnimations.valueAt(size);
                if (valueAt2.mHasFinished) {
                    if (valueAt2.mEndCallback != null) {
                        WritableMap createMap = Arguments.createMap();
                        createMap.putBoolean("finished", true);
                        valueAt2.mEndCallback.invoke(createMap);
                    } else if (this.mReactApplicationContext != null) {
                        WritableMap createMap2 = Arguments.createMap();
                        createMap2.putInt("animationId", valueAt2.mId);
                        createMap2.putBoolean("finished", true);
                        DeviceEventManagerModule.RCTDeviceEventEmitter rCTDeviceEventEmitter = (DeviceEventManagerModule.RCTDeviceEventEmitter) this.mReactApplicationContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class);
                        if (rCTDeviceEventEmitter != null) {
                            rCTDeviceEventEmitter.emit("onNativeAnimatedModuleAnimationFinished", createMap2);
                        }
                    }
                    this.mActiveAnimations.removeAt(size);
                }
            }
        }
    }

    private void updateNodes(List<AnimatedNode> list) {
        int i = this.mAnimatedGraphBFSColor + 1;
        this.mAnimatedGraphBFSColor = i;
        if (i == 0) {
            this.mAnimatedGraphBFSColor = i + 1;
        }
        ArrayDeque arrayDeque = new ArrayDeque();
        int i2 = 0;
        for (AnimatedNode animatedNode : list) {
            int i3 = animatedNode.mBFSColor;
            int i4 = this.mAnimatedGraphBFSColor;
            if (i3 != i4) {
                animatedNode.mBFSColor = i4;
                i2++;
                arrayDeque.add(animatedNode);
            }
        }
        while (!arrayDeque.isEmpty()) {
            AnimatedNode animatedNode2 = (AnimatedNode) arrayDeque.poll();
            if (animatedNode2.mChildren != null) {
                for (int i5 = 0; i5 < animatedNode2.mChildren.size(); i5++) {
                    AnimatedNode animatedNode3 = animatedNode2.mChildren.get(i5);
                    animatedNode3.mActiveIncomingNodes++;
                    int i6 = animatedNode3.mBFSColor;
                    int i7 = this.mAnimatedGraphBFSColor;
                    if (i6 != i7) {
                        animatedNode3.mBFSColor = i7;
                        i2++;
                        arrayDeque.add(animatedNode3);
                    }
                }
            }
        }
        int i8 = this.mAnimatedGraphBFSColor + 1;
        this.mAnimatedGraphBFSColor = i8;
        if (i8 == 0) {
            this.mAnimatedGraphBFSColor = i8 + 1;
        }
        int i9 = 0;
        for (AnimatedNode animatedNode4 : list) {
            if (animatedNode4.mActiveIncomingNodes == 0) {
                int i10 = animatedNode4.mBFSColor;
                int i11 = this.mAnimatedGraphBFSColor;
                if (i10 != i11) {
                    animatedNode4.mBFSColor = i11;
                    i9++;
                    arrayDeque.add(animatedNode4);
                }
            }
        }
        int i12 = 0;
        while (!arrayDeque.isEmpty()) {
            AnimatedNode animatedNode5 = (AnimatedNode) arrayDeque.poll();
            try {
                animatedNode5.update();
                if (animatedNode5 instanceof PropsAnimatedNode) {
                    ((PropsAnimatedNode) animatedNode5).updateView();
                }
            } catch (JSApplicationCausedNativeException e) {
                FLog.m246e(TAG, "Native animation workaround, frame lost as result of race condition", e);
            }
            if (animatedNode5 instanceof ValueAnimatedNode) {
                ((ValueAnimatedNode) animatedNode5).onValueUpdate();
            }
            if (animatedNode5.mChildren != null) {
                for (int i13 = 0; i13 < animatedNode5.mChildren.size(); i13++) {
                    AnimatedNode animatedNode6 = animatedNode5.mChildren.get(i13);
                    animatedNode6.mActiveIncomingNodes--;
                    if (animatedNode6.mBFSColor != this.mAnimatedGraphBFSColor && animatedNode6.mActiveIncomingNodes == 0) {
                        animatedNode6.mBFSColor = this.mAnimatedGraphBFSColor;
                        i9++;
                        arrayDeque.add(animatedNode6);
                    } else if (animatedNode6.mBFSColor == this.mAnimatedGraphBFSColor) {
                        i12++;
                    }
                }
            }
        }
        if (i2 != i9) {
            if (this.mWarnedAboutGraphTraversal) {
                return;
            }
            this.mWarnedAboutGraphTraversal = true;
            FLog.m247e(TAG, "Detected animation cycle or disconnected graph. ");
            for (AnimatedNode animatedNode7 : list) {
                FLog.m247e(TAG, animatedNode7.prettyPrintWithChildren());
            }
            IllegalStateException illegalStateException = new IllegalStateException("Looks like animated nodes graph has " + (i12 > 0 ? "cycles (" + i12 + ")" : "disconnected regions") + ", there are " + i2 + " but toposort visited only " + i9);
            boolean z = this.mEventListenerInitializedForFabric;
            if (z && i12 == 0) {
                ReactSoftExceptionLogger.logSoftException(TAG, new ReactNoCrashSoftException(illegalStateException));
                return;
            } else if (z) {
                ReactSoftExceptionLogger.logSoftException(TAG, new ReactNoCrashSoftException(illegalStateException));
                return;
            } else {
                throw illegalStateException;
            }
        }
        this.mWarnedAboutGraphTraversal = false;
    }
}
