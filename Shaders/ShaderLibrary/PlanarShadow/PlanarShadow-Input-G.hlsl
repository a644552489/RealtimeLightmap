#ifndef PLANAR_SHADOW_INPUT_G_INCLUDED
    #define PLANAR_SHADOW_INPUT_G_INCLUDED

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

    UNITY_INSTANCING_BUFFER_START(PlanarShadowInput)
    UNITY_DEFINE_INSTANCED_PROP(float ,_HeightOffset)
    UNITY_DEFINE_INSTANCED_PROP(float4 ,_ShadowColor)
    UNITY_DEFINE_INSTANCED_PROP(float ,_ShadowFalloff)
    UNITY_DEFINE_INSTANCED_PROP(float ,_ShadowCutoff)
    UNITY_INSTANCING_BUFFER_END(PlanarShadowInput) 
    
    #define _HeightOffset UNITY_ACCESS_INSTANCED_PROP(PlanarShadowInput, _HeightOffset)
    #define _ShadowColor UNITY_ACCESS_INSTANCED_PROP(PlanarShadowInput, _ShadowColor)
    #define _ShadowFalloff UNITY_ACCESS_INSTANCED_PROP(PlanarShadowInput, _ShadowFalloff)
    #define _ShadowCutoff UNITY_ACCESS_INSTANCED_PROP(PlanarShadowInput, _ShadowCutoff)

#endif
