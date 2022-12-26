#ifndef WORLD_MINIMAP_NEW_INPUT_INCLUDED
    #define WORLD_MINIMAP_NEW_INPUT_INCLUDED

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

    CBUFFER_START(UnityPerMaterial)
    half _IsHide;
    float _CellCount;
    half _IsCross;
    float _ShapeColorStrength;
    float4 _DataMap_Color_ST;
    CBUFFER_END


    TEXTURE2D(_DataMap_Color);       SAMPLER(sampler_DataMap_Color);
    TEXTURE2D(_DataMap_Color2);       SAMPLER(sampler_DataMap_Color2);
    TEXTURE2D(_DataMap_Edge);       SAMPLER(sampler_DataMap_Edge);
    TEXTURE2D(_DataMap_Angle);       SAMPLER(sampler_DataMap_Angle);
    TEXTURE2D(_ShapeMap_Edge);       SAMPLER(sampler_ShapeMap_Edge);
    TEXTURE2D(_ShapeMap_Angle);       SAMPLER(sampler_ShapeMap_Angle);
   
#endif
