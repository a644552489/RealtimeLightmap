#ifndef PLANAR_SHADOW_INPUT_INCLUDED
    #define PLANAR_SHADOW_INPUT_INCLUDED

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

    #define UNITY_PER_MATERIAL_PLANAR_SHADOW \
    float _HeightOffset;\
    float4 _ShadowColor;\
    float _ShadowFalloff;\
    float _ShadowCutoff;
    
#endif
