#ifndef CUSTOM_ARCHITEXTURE_LOD_INPUT_G_INCLUDED
    #define CUSTOM_ARCHITEXTURE_LOD_INPUT_G_INCLUDED

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"

    #include "../../../ShaderLibrary/CustomFog.hlsl"
    #include "../../../ShaderLibrary/CustomCloud.hlsl"
    #include "../../../ShaderLibrary/Seasons/CustomSeasons.hlsl"
    #include "../../../ShaderLibrary/Seasons/Seasons-Input-G.hlsl"
    #include "../../../ShaderLibrary/PlanarShadow/PlanarShadow-Input-G.hlsl"

    #if defined(_DETAIL_MULX2) || defined(_DETAIL_SCALED)
        #define _DETAIL
    #endif

    UNITY_INSTANCING_BUFFER_START(GpuInstanceInput)
    UNITY_DEFINE_INSTANCED_PROP(float4, _BaseMap_ST)
    UNITY_DEFINE_INSTANCED_PROP(float4, _DetailAlbedoMap_ST)
    UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)
    UNITY_DEFINE_INSTANCED_PROP(float4, _SpecColor)
    UNITY_DEFINE_INSTANCED_PROP(float4, _EmissionColor)
    //zzw:22.09.20: add mask
    UNITY_DEFINE_INSTANCED_PROP(half4,_MaskColor)
    //zzw:add end
    UNITY_DEFINE_INSTANCED_PROP(float , _Cutoff)
    UNITY_DEFINE_INSTANCED_PROP(float , _Smoothness)
    UNITY_DEFINE_INSTANCED_PROP(float , _Metallic)
    UNITY_DEFINE_INSTANCED_PROP(float , _BumpScale)
    UNITY_DEFINE_INSTANCED_PROP(float , _Parallax)
    UNITY_DEFINE_INSTANCED_PROP(float , _OcclusionStrength)
    UNITY_DEFINE_INSTANCED_PROP(float , _ClearCoatMask)
    UNITY_DEFINE_INSTANCED_PROP(float , _ClearCoatSmoothness)
    UNITY_DEFINE_INSTANCED_PROP(float , _DetailAlbedoMapScale)
    UNITY_DEFINE_INSTANCED_PROP(float , _DetailNormalMapScale)
    UNITY_DEFINE_INSTANCED_PROP(float , _Surface)
    UNITY_DEFINE_INSTANCED_PROP(float , _EmissionStrength)
    UNITY_DEFINE_INSTANCED_PROP(float , _LightmapStrength)
    UNITY_DEFINE_INSTANCED_PROP(float , _ShadowGIStrength)

    UNITY_DEFINE_INSTANCED_PROP(float4 , _SpecularColor)
    UNITY_DEFINE_INSTANCED_PROP(float , _SpecularSmoothness)

    UNITY_DEFINE_INSTANCED_PROP(half  , _ReflectStrength)

    UNITY_DEFINE_INSTANCED_PROP(float , _VertexMoveDist)
    UNITY_DEFINE_INSTANCED_PROP(float , _VertexMoveSpeed)
    UNITY_DEFINE_INSTANCED_PROP(float , _VertexMoveSpeedOffset)


    UNITY_INSTANCING_BUFFER_END(GpuInstanceInput)

    #define _BaseMap_ST             UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput , _BaseMap_ST)
    #define _DetailAlbedoMap_ST     UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput , _DetailAlbedoMap_ST)
    #define _BaseColor              UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput , _BaseColor)
    #define _SpecColor              UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput , _SpecColor)
    #define _EmissionColor          UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput , _EmissionColor)
    //zzw:22.09.20:add mask
    #define _MaskColor              UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput , _MaskColor)
    //zzw:add end
    #define _Cutoff                 UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput  , _Cutoff)
    #define _Smoothness             UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput  , _Smoothness)
    #define _Metallic               UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput  , _Metallic)
    #define _BumpScale              UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput  , _BumpScale)
    #define _Parallax               UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput  , _Parallax)
    #define _OcclusionStrength      UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput  , _OcclusionStrength)
    #define _ClearCoatMask          UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput  , _ClearCoatMask)
    #define _ClearCoatSmoothness    UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput  , _ClearCoatSmoothness)
    #define _DetailAlbedoMapScale   UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput  , _DetailAlbedoMapScale)
    #define _DetailNormalMapScale   UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput  , _DetailNormalMapScale)
    #define _Surface                UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput  , _Surface)
    #define _SpecularColor          UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput  , _SpecularColor)
    #define _SpecularSmoothness     UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput  , _SpecularSmoothness)
    #define _ReflectStrength        UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput  , _ReflectStrength)
    #define _VertexMoveDist         UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput  , _VertexMoveDist)
    #define _VertexMoveSpeed        UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput  , _VertexMoveSpeed)
    #define _VertexMoveSpeedOffset  UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput  , _VertexMoveSpeedOffset)
    #define _EmissionStrength       UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput ,  _EmissionStrength)
    #define _LightmapStrength       UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput ,  _LightmapStrength)
    #define _ShadowGIStrength       UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput ,  _ShadowGIStrength)

    TEXTURE2D(_ParallaxMap);        SAMPLER(sampler_ParallaxMap);
    TEXTURE2D(_OcclusionMap);       SAMPLER(sampler_OcclusionMap);
    TEXTURE2D(_DetailMask);         SAMPLER(sampler_DetailMask);
    TEXTURE2D(_DetailAlbedoMap);    SAMPLER(sampler_DetailAlbedoMap);
    TEXTURE2D(_DetailNormalMap);    SAMPLER(sampler_DetailNormalMap);
    TEXTURE2D(_MetallicGlossMap);   SAMPLER(sampler_MetallicGlossMap);
    TEXTURE2D(_SpecGlossMap);       SAMPLER(sampler_SpecGlossMap);
    TEXTURE2D(_ClearCoatMap);       SAMPLER(sampler_ClearCoatMap);
    //zzw:22.09.20:add mask
    TEXTURE2D(_MaskMap);            SAMPLER(sampler_MaskMap);

    //zzw:add end

    #ifdef _SPECULAR_SETUP
        #define SAMPLE_METALLICSPECULAR(uv) SAMPLE_TEXTURE2D(_SpecGlossMap, sampler_SpecGlossMap, uv)
    #else
        #define SAMPLE_METALLICSPECULAR(uv) SAMPLE_TEXTURE2D(_MetallicGlossMap, sampler_MetallicGlossMap, uv)
    #endif

    half4 SampleMetallicSpecGloss(float2 uv, half albedoAlpha)
    {
        half4 specGloss;

        #ifdef _METALLICSPECGLOSSMAP
            specGloss = SAMPLE_METALLICSPECULAR(uv);
            #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
                specGloss.a = albedoAlpha * _Smoothness;
            #else
                specGloss.a *= _Smoothness;
            #endif
        #else // _METALLICSPECGLOSSMAP
            #if _SPECULAR_SETUP
                specGloss.rgb = _SpecColor.rgb;
            #else
                specGloss.rgb = _Metallic.rrr;
            #endif

            #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
                specGloss.a = albedoAlpha * _Smoothness;
            #else
                specGloss.a = _Smoothness;
            #endif
        #endif

        return specGloss;
    }

    half SampleOcclusion(float2 uv)
    {
        #ifdef _OCCLUSIONMAP
            // TODO: Controls things like these by exposing SHADER_QUALITY levels (low, medium, high)
            #if defined(SHADER_API_GLES)
                return SAMPLE_TEXTURE2D(_OcclusionMap, sampler_OcclusionMap, uv).g;
            #else
                half occ = SAMPLE_TEXTURE2D(_OcclusionMap, sampler_OcclusionMap, uv).g;
                return LerpWhiteTo(occ, _OcclusionStrength);
            #endif
        #else
            return 1.0;
        #endif
    }

    //zzw:22.09.20 add mask
    half SampleMaskMap(float2 uv, TEXTURE2D_PARAM(maskMap, sampler_maskMap))
    {
        #ifndef _MASKMAP
            return 0;
        #else
            return SAMPLE_TEXTURE2D(maskMap, sampler_maskMap, uv).r;
        #endif
    }
    //zzw:add end


    // Returns clear coat parameters
    // .x/.r == mask
    // .y/.g == smoothness
    half2 SampleClearCoat(float2 uv)
    {
        #if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
            half2 clearCoatMaskSmoothness = half2(_ClearCoatMask, _ClearCoatSmoothness);

            #if defined(_CLEARCOATMAP)
                clearCoatMaskSmoothness *= SAMPLE_TEXTURE2D(_ClearCoatMap, sampler_ClearCoatMap, uv).rg;
            #endif

            return clearCoatMaskSmoothness;
        #else
            return half2(0.0, 1.0);
        #endif  // _CLEARCOAT
    }

    void ApplyPerPixelDisplacement(half3 viewDirTS, inout float2 uv)
    {
        #if defined(_PARALLAXMAP)
            uv += ParallaxMapping(TEXTURE2D_ARGS(_ParallaxMap, sampler_ParallaxMap), viewDirTS, _Parallax, uv);
        #endif
    }

    // Used for scaling detail albedo. Main features:
    // - Depending if detailAlbedo brightens or darkens, scale magnifies effect.
    // - No effect is applied if detailAlbedo is 0.5.
    half3 ScaleDetailAlbedo(half3 detailAlbedo, half scale)
    {
        // detailAlbedo = detailAlbedo * 2.0h - 1.0h;
        // detailAlbedo *= _DetailAlbedoMapScale;
        // detailAlbedo = detailAlbedo * 0.5h + 0.5h;
        // return detailAlbedo * 2.0f;

        // A bit more optimized
        return 2.0h * detailAlbedo * scale - scale + 1.0h;
    }

    half3 ApplyDetailAlbedo(float2 detailUv, half3 albedo, half detailMask)
    {
        #if defined(_DETAIL)
            half3 detailAlbedo = SAMPLE_TEXTURE2D(_DetailAlbedoMap, sampler_DetailAlbedoMap, detailUv).rgb;

            // In order to have same performance as builtin, we do scaling only if scale is not 1.0 (Scaled version has 6 additional instructions)
            #if defined(_DETAIL_SCALED)
                detailAlbedo = ScaleDetailAlbedo(detailAlbedo, _DetailAlbedoMapScale);
            #else
                detailAlbedo = 2.0h * detailAlbedo;
            #endif

            return albedo * LerpWhiteTo(detailAlbedo, detailMask);
        #else
            return albedo;
        #endif
    }

    half3 ApplyDetailNormal(float2 detailUv, half3 normalTS, half detailMask)
    {
        #if defined(_DETAIL)
            #if BUMP_SCALE_NOT_SUPPORTED
                half3 detailNormalTS = UnpackNormal(SAMPLE_TEXTURE2D(_DetailNormalMap, sampler_DetailNormalMap, detailUv));
            #else
                half3 detailNormalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_DetailNormalMap, sampler_DetailNormalMap, detailUv), _DetailNormalMapScale);
            #endif

            // With UNITY_NO_DXT5nm unpacked vector is not normalized for BlendNormalRNM
            // For visual consistancy we going to do in all cases
            detailNormalTS = normalize(detailNormalTS);

            return lerp(normalTS, BlendNormalRNM(normalTS, detailNormalTS), detailMask); // todo: detailMask should lerp the angle of the quaternion rotation, not the normals
        #else
            return normalTS;
        #endif
    }

    inline void InitializeStandardLitSurfaceData(float2 uv, out SurfaceData outSurfaceData)
    {
        half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
        outSurfaceData.alpha = Alpha(albedoAlpha.a, _BaseColor, _Cutoff);

        half4 specGloss = SampleMetallicSpecGloss(uv, albedoAlpha.a);
        outSurfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;
        
        #ifndef USING_PBR


        #endif

        #if _SPECULAR_SETUP
            outSurfaceData.metallic = 1.0h;
            outSurfaceData.specular = specGloss.rgb;
        #else
            outSurfaceData.metallic = specGloss.r;
            outSurfaceData.specular = half3(0.0h, 0.0h, 0.0h);
        #endif

        outSurfaceData.smoothness = specGloss.a;
        outSurfaceData.normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
        outSurfaceData.occlusion = SampleOcclusion(uv);
        outSurfaceData.emission = SampleEmission(uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));

        #if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
            half2 clearCoat = SampleClearCoat(uv);
            outSurfaceData.clearCoatMask       = clearCoat.r;
            outSurfaceData.clearCoatSmoothness = clearCoat.g;
        #else
            outSurfaceData.clearCoatMask       = 0.0h;
            outSurfaceData.clearCoatSmoothness = 0.0h;
        #endif

        #if defined(_DETAIL)
            half detailMask = SAMPLE_TEXTURE2D(_DetailMask, sampler_DetailMask, uv).a;
            float2 detailUv = uv * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
            outSurfaceData.albedo = ApplyDetailAlbedo(detailUv, outSurfaceData.albedo, detailMask);
            outSurfaceData.normalTS = ApplyDetailNormal(detailUv, outSurfaceData.normalTS, detailMask);

        #endif
    }

#endif // UNIVERSAL_INPUT_SURFACE_PBR_INCLUDED
