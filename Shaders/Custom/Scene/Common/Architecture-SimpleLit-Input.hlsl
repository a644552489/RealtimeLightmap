#ifndef ARCHITECTURE_SIMPLELIT_INPUT_INCLUDED
    #define ARCHITECTURE_SIMPLELIT_INPUT_INCLUDED

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
    #include "../../../ShaderLibrary/MyLibrary.hlsl"
    #include "../../../ShaderLibrary/CustomFog.hlsl"
    #include "../../../ShaderLibrary/Seasons/CustomSeasons.hlsl"
    #include "../../../ShaderLibrary/Seasons/Seasons-Input.hlsl"
    #include "../../../ShaderLibrary/PlanarShadow/PlanarShadow-Input.hlsl"

    CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_ST;
        half4 _BaseColor;
        half4 _SpecColor;
        half4 _EmissionColor;
        half _Cutoff;
        half _Surface;
        float _LightmapStrength;
        float _EmissionStrength;
        float _ShadowGIStrength;

        UNITY_PER_MATERIAL_PLANAR_SHADOW

        UNITY_PER_MATERIAL_SEASON_COLOR
        UNITY_PER_MATERIAL_SEASON_SNOW
    CBUFFER_END
    
    UNITY_INSTANCING_BUFFER_START(Custom_Lightmap_Props)
    UNITY_DEFINE_INSTANCED_PROP(float4 , _Custom_LightmapST_Morning)
    UNITY_DEFINE_INSTANCED_PROP(float4 , _Custom_LightmapST_Evening)
  //  UNITY_DEFINE_INSTANCED_PROP(float , _LightmapStrength)
    UNITY_INSTANCING_BUFFER_END(Custom_Lightmap_Props)



    
    #ifdef UNITY_DOTS_INSTANCING_ENABLED
        UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
        UNITY_DOTS_INSTANCED_PROP(float4, _BaseColor)
        UNITY_DOTS_INSTANCED_PROP(float4, _SpecColor)
        UNITY_DOTS_INSTANCED_PROP(float4, _EmissionColor)
        UNITY_DOTS_INSTANCED_PROP(float , _Cutoff)
        UNITY_DOTS_INSTANCED_PROP(float , _Surface)
        UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

        #define _BaseColor          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__BaseColor)
        #define _SpecColor          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__SpecColor)
        #define _EmissionColor      UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__EmissionColor)
        #define _Cutoff             UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Cutoff)
        #define _Surface            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Surface)
    #endif
    #define _Custom_LightmapST_Morning  UNITY_ACCESS_INSTANCED_PROP(Custom_Lightmap_Props , _Custom_LightmapST_Morning);
    #define _Custom_LightmapST_Evening  UNITY_ACCESS_INSTANCED_PROP(Custom_Lightmap_Props , _Custom_LightmapST_Evening);
  //  #define _LightmapStrength           UNITY_ACCESS_INSTANCED_PROP(Custom_Lightmap_Props , _LightmapStrength);



    TEXTURE2D(_SpecGlossMap);       SAMPLER(sampler_SpecGlossMap);


    TEXTURE2D(Lightmap_Morning);    SAMPLER(sampler_Lightmap_Morning);
    TEXTURE2D(LightmapInd_Morning);  SAMPLER(sampler_LightmapInd_Morning);
    TEXTURE2D(ShadowMask_Morning);    SAMPLER(sampler_ShadowMask_Morning);
    

    TEXTURE2D(Lightmap_Evening);    SAMPLER(sampler_Lightmap_Evening);
    TEXTURE2D(LightmapInd_Evening); SAMPLER(sampler_LightmapInd_Evening);
    TEXTURE2D(ShadowMask_Evening);  SAMPLER(sampler_ShadowMask_Evening);


    half4 SampleSpecularSmoothness(half2 uv, half alpha, half4 specColor, TEXTURE2D_PARAM(specMap, sampler_specMap))
    {
        half4 specularSmoothness = half4(0.0h, 0.0h, 0.0h, 1.0h);
        #ifdef _SPECGLOSSMAP
            specularSmoothness = SAMPLE_TEXTURE2D(specMap, sampler_specMap, uv) * specColor;
        #elif defined(_SPECULAR_COLOR)
            specularSmoothness = specColor;
        #endif

        #ifdef _GLOSSINESS_FROM_BASE_ALPHA
            specularSmoothness.a = exp2(10 * alpha + 1);
        #else
            specularSmoothness.a = exp2(10 * specularSmoothness.a + 1);
        #endif

        return specularSmoothness;
    }

    inline void InitializeSimpleLitSurfaceData(float2 uv, out SurfaceData outSurfaceData)
    {
        outSurfaceData = (SurfaceData)0;

        half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
        outSurfaceData.alpha = albedoAlpha.a * _BaseColor.a;
        AlphaDiscard(outSurfaceData.alpha, _Cutoff);

        outSurfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;
        #ifdef _ALPHAPREMULTIPLY_ON
            outSurfaceData.albedo *= outSurfaceData.alpha;
        #endif

        half4 specularSmoothness = SampleSpecularSmoothness(uv, outSurfaceData.alpha, _SpecColor, TEXTURE2D_ARGS(_SpecGlossMap, sampler_SpecGlossMap));
        outSurfaceData.metallic = 0.0; // unused
        outSurfaceData.specular = specularSmoothness.rgb;
        outSurfaceData.smoothness = specularSmoothness.a;
        outSurfaceData.normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap));
        outSurfaceData.occlusion = 1.0; // unused
        outSurfaceData.emission = SampleEmission(uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
    }

#endif
