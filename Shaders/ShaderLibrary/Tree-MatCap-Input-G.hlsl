#ifndef TREE_MATCAP_INPUT_G_INCLUDED
    #define TREE_MATCAP_INPUT_G_INCLUDED

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
    #include "./MyLibrary.hlsl"
    #include "./PlanarShadow/PlanarShadow-Input-G.hlsl"

    UNITY_INSTANCING_BUFFER_START(GpuInstanceInput)
    UNITY_DEFINE_INSTANCED_PROP(float4 ,_BaseMap_ST)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_BaseColor)
    UNITY_DEFINE_INSTANCED_PROP(half ,_Surface)
    UNITY_DEFINE_INSTANCED_PROP(half ,_AoStrength)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_AoColor)
    UNITY_DEFINE_INSTANCED_PROP(half ,_MatCapPow)
    UNITY_DEFINE_INSTANCED_PROP(half ,_MatCapStrength)
    UNITY_DEFINE_INSTANCED_PROP(half ,_Cutout)
    UNITY_DEFINE_INSTANCED_PROP(half ,_VertexSpeed)
    UNITY_DEFINE_INSTANCED_PROP(half ,_VertexScale)
    UNITY_DEFINE_INSTANCED_PROP(float2 ,_OffsetUV)
    UNITY_DEFINE_INSTANCED_PROP(float4 ,_HeightLit)
    UNITY_DEFINE_INSTANCED_PROP(float4 ,_HeightLitColor)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_BBSizePos)
    UNITY_DEFINE_INSTANCED_PROP(half ,_Culloff)
    UNITY_INSTANCING_BUFFER_END(GpuInstanceInput) 

    #define _BaseMap_ST UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _BaseMap_ST)
    #define _BaseColor UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _BaseColor)
    #define _Surface UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _Surface)
    #define _AoStrength UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _AoStrength)
    #define _AoColor UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _AoColor)
    #define _MatCapPow UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _MatCapPow)
    #define _MatCapStrength UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _MatCapStrength)
    #define _Cutout UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _Cutout)
    #define _VertexSpeed UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _VertexSpeed)
    #define _VertexScale UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _VertexScale)
    #define _OffsetUV UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _OffsetUV)
    #define _HeightLit UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _HeightLit)
    #define _HeightLitColor UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _HeightLitColor)
    #define _BBSizePos UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _BBSizePos)
    #define _Culloff UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _Culloff)


    TEXTURE2D(_AoMap);       SAMPLER(sampler_AoMap);
    TEXTURE2D(_MatCap);       SAMPLER(sampler_MatCap);

#endif
