package expo.modules.lineargradient;

import android.content.Context;
import expo.modules.kotlin.modules.Module;
import expo.modules.kotlin.modules.ModuleDefinitionBuilder;
import expo.modules.kotlin.modules.ModuleDefinitionData;
import expo.modules.kotlin.types.AnyTypeKt;
import expo.modules.kotlin.views.ConcreteViewProp;
import expo.modules.kotlin.views.ViewManagerDefinitionBuilder;
import kotlin.Metadata;
import kotlin.Tuples;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;
import kotlin.jvm.functions.Function2;
import kotlin.jvm.internal.Intrinsics;
import kotlin.jvm.internal.Reflection;
import kotlin.reflect.KTypeProjection;

/* compiled from: LinearGradientModule.kt */
@Metadata(m41d1 = {"\u0000\u0012\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0000\u0018\u00002\u00020\u0001B\u0005¢\u0006\u0002\u0010\u0002J\b\u0010\u0003\u001a\u00020\u0004H\u0016¨\u0006\u0005"}, m40d2 = {"Lexpo/modules/lineargradient/LinearGradientModule;", "Lexpo/modules/kotlin/modules/Module;", "()V", "definition", "Lexpo/modules/kotlin/modules/ModuleDefinitionData;", "expo-linear-gradient_release"}, m39k = 1, m38mv = {1, 6, 0}, m36xi = 48)
/* loaded from: classes2.dex */
public final class LinearGradientModule extends Module {
    @Override // expo.modules.kotlin.modules.Module
    public ModuleDefinitionData definition() {
        ModuleDefinitionBuilder moduleDefinitionBuilder = new ModuleDefinitionBuilder(this);
        moduleDefinitionBuilder.Name("ExpoLinearGradient");
        if (!(moduleDefinitionBuilder.getViewManagerDefinition() == null)) {
            throw new IllegalArgumentException("The module definition may have exported only one view manager.".toString());
        }
        ViewManagerDefinitionBuilder viewManagerDefinitionBuilder = new ViewManagerDefinitionBuilder();
        viewManagerDefinitionBuilder.setViewType(LinearGradientView.class);
        viewManagerDefinitionBuilder.setViewFactory(new Function1<Context, LinearGradientView>() { // from class: expo.modules.lineargradient.LinearGradientModule$definition$1$1$1
            @Override // kotlin.jvm.functions.Function1
            public final LinearGradientView invoke(Context context) {
                Intrinsics.checkNotNullParameter(context, "context");
                return new LinearGradientView(context);
            }
        });
        viewManagerDefinitionBuilder.getProps().put("colors", new ConcreteViewProp("colors", AnyTypeKt.toAnyType(Reflection.typeOf(int[].class)), new Function2<LinearGradientView, int[], Unit>() { // from class: expo.modules.lineargradient.LinearGradientModule$definition$1$1$2
            @Override // kotlin.jvm.functions.Function2
            public /* bridge */ /* synthetic */ Unit invoke(LinearGradientView linearGradientView, int[] iArr) {
                invoke2(linearGradientView, iArr);
                return Unit.INSTANCE;
            }

            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2(LinearGradientView view, int[] colors) {
                Intrinsics.checkNotNullParameter(view, "view");
                Intrinsics.checkNotNullParameter(colors, "colors");
                view.setColors(colors);
            }
        }));
        viewManagerDefinitionBuilder.getProps().put("locations", new ConcreteViewProp("locations", AnyTypeKt.toAnyType(Reflection.nullableTypeOf(float[].class)), new Function2<LinearGradientView, float[], Unit>() { // from class: expo.modules.lineargradient.LinearGradientModule$definition$1$1$3
            @Override // kotlin.jvm.functions.Function2
            public /* bridge */ /* synthetic */ Unit invoke(LinearGradientView linearGradientView, float[] fArr) {
                invoke2(linearGradientView, fArr);
                return Unit.INSTANCE;
            }

            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2(LinearGradientView view, float[] fArr) {
                Intrinsics.checkNotNullParameter(view, "view");
                if (fArr == null) {
                    return;
                }
                view.setLocations(fArr);
            }
        }));
        viewManagerDefinitionBuilder.getProps().put("startPoint", new ConcreteViewProp("startPoint", AnyTypeKt.toAnyType(Reflection.nullableTypeOf(Tuples.class, KTypeProjection.Companion.invariant(Reflection.typeOf(Float.TYPE)), KTypeProjection.Companion.invariant(Reflection.typeOf(Float.TYPE)))), new Function2<LinearGradientView, Tuples<? extends Float, ? extends Float>, Unit>() { // from class: expo.modules.lineargradient.LinearGradientModule$definition$1$1$4
            @Override // kotlin.jvm.functions.Function2
            public /* bridge */ /* synthetic */ Unit invoke(LinearGradientView linearGradientView, Tuples<? extends Float, ? extends Float> tuples) {
                invoke2(linearGradientView, (Tuples<Float, Float>) tuples);
                return Unit.INSTANCE;
            }

            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2(LinearGradientView view, Tuples<Float, Float> tuples) {
                Float second;
                Float first;
                Intrinsics.checkNotNullParameter(view, "view");
                float f = 0.5f;
                if (tuples != null && (first = tuples.getFirst()) != null) {
                    f = first.floatValue();
                }
                float f2 = 0.0f;
                if (tuples != null && (second = tuples.getSecond()) != null) {
                    f2 = second.floatValue();
                }
                view.setStartPosition(f, f2);
            }
        }));
        viewManagerDefinitionBuilder.getProps().put("endPoint", new ConcreteViewProp("endPoint", AnyTypeKt.toAnyType(Reflection.nullableTypeOf(Tuples.class, KTypeProjection.Companion.invariant(Reflection.typeOf(Float.TYPE)), KTypeProjection.Companion.invariant(Reflection.typeOf(Float.TYPE)))), new Function2<LinearGradientView, Tuples<? extends Float, ? extends Float>, Unit>() { // from class: expo.modules.lineargradient.LinearGradientModule$definition$1$1$5
            @Override // kotlin.jvm.functions.Function2
            public /* bridge */ /* synthetic */ Unit invoke(LinearGradientView linearGradientView, Tuples<? extends Float, ? extends Float> tuples) {
                invoke2(linearGradientView, (Tuples<Float, Float>) tuples);
                return Unit.INSTANCE;
            }

            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2(LinearGradientView view, Tuples<Float, Float> tuples) {
                Float second;
                Float first;
                Intrinsics.checkNotNullParameter(view, "view");
                float f = 0.5f;
                if (tuples != null && (first = tuples.getFirst()) != null) {
                    f = first.floatValue();
                }
                float f2 = 1.0f;
                if (tuples != null && (second = tuples.getSecond()) != null) {
                    f2 = second.floatValue();
                }
                view.setEndPosition(f, f2);
            }
        }));
        viewManagerDefinitionBuilder.getProps().put("borderRadii", new ConcreteViewProp("borderRadii", AnyTypeKt.toAnyType(Reflection.nullableTypeOf(float[].class)), new Function2<LinearGradientView, float[], Unit>() { // from class: expo.modules.lineargradient.LinearGradientModule$definition$1$1$6
            @Override // kotlin.jvm.functions.Function2
            public /* bridge */ /* synthetic */ Unit invoke(LinearGradientView linearGradientView, float[] fArr) {
                invoke2(linearGradientView, fArr);
                return Unit.INSTANCE;
            }

            /* renamed from: invoke  reason: avoid collision after fix types in other method */
            public final void invoke2(LinearGradientView view, float[] fArr) {
                Intrinsics.checkNotNullParameter(view, "view");
                if (fArr == null) {
                    float[] fArr2 = new float[8];
                    for (int i = 0; i < 8; i++) {
                        fArr2[i] = 0.0f;
                    }
                    fArr = fArr2;
                }
                view.setBorderRadii(fArr);
            }
        }));
        moduleDefinitionBuilder.setViewManagerDefinition(viewManagerDefinitionBuilder.build());
        return moduleDefinitionBuilder.buildModule();
    }
}
