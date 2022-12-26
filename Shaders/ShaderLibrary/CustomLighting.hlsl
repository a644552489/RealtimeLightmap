#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


///////////////////////////////////////////////////////////////////////////////
//                      Fragment Functions                                   //
//       Used by ShaderGraph and others builtin renderers                    //
///////////////////////////////////////////////////////////////////////////////


#if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
    #define SAMPLE_SHADOWMASK_CUSTOM( SHADOWMASK , SHADOWMASK_SAMPLER,uv) SAMPLE_TEXTURE2D_LIGHTMAP(SHADOWMASK, SHADOWMASK_SAMPLER, uv SHADOWMASK_SAMPLE_EXTRA_ARGS);
#elif !defined (LIGHTMAP_ON)
    #define SAMPLE_SHADOWMASK_CUSTOM( SHADOWMASK , SHADOWMASK_SAMPLER,uv) unity_ProbesOcclusion;
#else
    #define SAMPLE_SHADOWMASK_CUSTOM( SHADOWMASK , SHADOWMASK_SAMPLER,uv) half4(1, 1, 1, 1);
#endif

#if defined(LIGHTMAP_ON)
#define SAMPLE_GI_CUSTOM(lmName, shName, normalWSName ,LIGHTMAP , LIGHTMAP_SAMPLER ,LIGHTMAP_INDIRECTION) SampleLightmap_Custom(lmName, normalWSName  ,LIGHTMAP , LIGHTMAP_SAMPLER ,LIGHTMAP_INDIRECTION)
#else
#define SAMPLE_GI_CUSTOM(lmName, shName, normalWSName  ,LIGHTMAP , LIGHTMAP_SAMPLER ,LIGHTMAP_INDIRECTION) SampleSHPixel(shName, normalWSName)
#endif


half3 SampleLightmap_Custom(float2 lightmapUV, half3 normalWS ,
    Texture2D LIGHTMAP ,sampler LIGHTMAP_SAMPLER ,
    Texture2D LIGHTMAP_INDIRECTION )
{
#ifdef UNITY_LIGHTMAP_FULL_HDR
    bool encodedLightmap = false;
#else
    bool encodedLightmap = true;
#endif

    half4 decodeInstructions = half4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0.0h, 0.0h);

    // The shader library sample lightmap functions transform the lightmap uv coords to apply bias and scale.
    // However, universal pipeline already transformed those coords in vertex. We pass half4(1, 1, 0, 0) and
    // the compiler will optimize the transform away.
    half4 transformCoords = half4(1, 1, 0, 0);

#if defined(LIGHTMAP_ON) && defined(DIRLIGHTMAP_COMBINED)
    return SampleDirectionalLightmap(TEXTURE2D_LIGHTMAP_ARGS(LIGHTMAP, LIGHTMAP_SAMPLER),
        TEXTURE2D_LIGHTMAP_ARGS(LIGHTMAP_INDIRECTION, LIGHTMAP_SAMPLER),
        LIGHTMAP_SAMPLE_EXTRA_ARGS, transformCoords, normalWS, encodedLightmap, decodeInstructions);
#elif defined(LIGHTMAP_ON)
    return SampleSingleLightmap(TEXTURE2D_LIGHTMAP_ARGS(LIGHTMAP, LIGHTMAP_SAMPLER), LIGHTMAP_SAMPLE_EXTRA_ARGS, transformCoords, encodedLightmap, decodeInstructions);
#else
    return half3(0.0, 0.0, 0.0);
#endif
}



half3 GlossyEnvironmentReflection(half3 reflectVector, half perceptualRoughness, half occlusion, half customIndirectSpecularStrength)
{
    #if !defined(_ENVIRONMENTREFLECTIONS_OFF)
        half mip = PerceptualRoughnessToMipmapLevel(perceptualRoughness);
        half4 encodedIrradiance = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVector, mip);

        //TODO:DOTS - we need to port probes to live in c# so we can manage this manually.
        #if defined(UNITY_USE_NATIVE_HDR) || defined(UNITY_DOTS_INSTANCING_ENABLED)
            half3 irradiance = encodedIrradiance.rgb;
        #else
            half3 irradiance = DecodeHDREnvironment(encodedIrradiance, unity_SpecCube0_HDR);
        #endif

        return irradiance * occlusion * customIndirectSpecularStrength;
    #endif // GLOSSY_REFLECTIONS

    return _GlossyEnvironmentColor.rgb * occlusion;
}


half3 GlobalIllumination_Custom(BRDFData brdfData, BRDFData brdfDataClearCoat, float clearCoatMask,
half3 bakedGI, half occlusion,
half3 normalWS, half3 viewDirectionWS, half customIndirectSpecularStrength)
{
    half3 reflectVector = reflect(-viewDirectionWS, normalWS);
    half NoV = saturate(dot(normalWS, viewDirectionWS));
    half fresnelTerm = Pow4(1.0 - NoV);

    half3 indirectDiffuse = bakedGI * occlusion;
    half3 indirectSpecular = GlossyEnvironmentReflection(reflectVector, brdfData.perceptualRoughness, occlusion,customIndirectSpecularStrength);

    half3 color = EnvironmentBRDF(brdfData, indirectDiffuse, indirectSpecular, fresnelTerm);

    #if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
        half3 coatIndirectSpecular = GlossyEnvironmentReflection(reflectVector, brdfDataClearCoat.perceptualRoughness, occlusion);
        // TODO: "grazing term" causes problems on full roughness
        half3 coatColor = EnvironmentBRDFClearCoat(brdfDataClearCoat, clearCoatMask, coatIndirectSpecular, fresnelTerm);

        // Blend with base layer using khronos glTF recommended way using NoV
        // Smooth surface & "ambiguous" lighting
        // NOTE: fresnelTerm (above) is pow4 instead of pow5, but should be ok as blend weight.
        half coatFresnel = kDielectricSpec.x + kDielectricSpec.a * fresnelTerm;
        return color * (1.0 - coatFresnel * clearCoatMask) + coatColor;
    #else
        return color;
    #endif
}

half3 LightingPhysically_Custom(BRDFData brdfData, half3 lightColor, half3 lightDirectionWS, half lightAttenuation, half3 normalWS, half3 viewDirectionWS)
{
    half NdotL = saturate(dot(normalWS, lightDirectionWS));
    half3 radiance = lightColor * (lightAttenuation * NdotL);

    half3 brdf = brdfData.diffuse ;

    #if !defined(_SPECULARHIGHLIGHTS_OFF)
        brdf += brdfData.specular * DirectBRDFSpecular(brdfData, normalWS, lightDirectionWS, viewDirectionWS);
    #endif
    
    return brdf * radiance;
}

half3 LightingPhysically_Custom(BRDFData brdfData, Light light, half3 normalWS, half3 viewDirectionWS)
{
    return LightingPhysically_Custom(brdfData, light.color, light.direction, light.distanceAttenuation * light.shadowAttenuation, normalWS, viewDirectionWS);
}

half4 BakedFragmentPBR(InputData inputData, SurfaceData surfaceData, BRDFData brdfData)
{
    half3 color = GlobalIllumination(brdfData, inputData.bakedGI, surfaceData.occlusion, inputData.normalWS, inputData.viewDirectionWS);
    
    color += surfaceData.emission;

    return half4(color, surfaceData.alpha);
}


half MainLightShadow_Custom(float4 shadowCoord, float3 positionWS, half4 shadowMask, half4 occlusionProbeChannels)
{
    half realtimeShadow = MainLightRealtimeShadow(shadowCoord);

    #ifdef CALCULATE_BAKED_SHADOWS
        #ifdef SHADOWS_SHADOWMASK
            half bakedShadow = BakedShadow(shadowMask, half4(1, 0, 0, 0));
        #else
            half bakedShadow = BakedShadow(shadowMask, occlusionProbeChannels);
        #endif
    #else
        half bakedShadow = 1.0h;
    #endif

   return (realtimeShadow * bakedShadow);
}

half4 BakedFragmentPBR(InputData inputData, SurfaceData surfaceData, half customIndirectSpecularStrength)
{
    BRDFData brdfData;

    // NOTE: can modify alpha
    InitializeBRDFData(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.alpha, brdfData);

    BRDFData brdfDataClearCoat = (BRDFData)0;
    #if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
        // base brdfData is modified here, rely on the compiler to eliminate dead computation by InitializeBRDFData()
        InitializeBRDFDataClearCoat(surfaceData.clearCoatMask, surfaceData.clearCoatSmoothness, brdfData, brdfDataClearCoat);
    #endif


    half3 color = GlobalIllumination_Custom(brdfData, brdfDataClearCoat, surfaceData.clearCoatMask,
    inputData.bakedGI, surfaceData.occlusion,
    inputData.normalWS, inputData.viewDirectionWS, customIndirectSpecularStrength);
    
    #if !defined(_SPECULARHIGHLIGHTS_OFF) || !defined(_RECEIVE_SHADOWS_OFF) || defined(SHADOWS_SHADOWMASK)
        
        Light mainLight = GetMainLight();
        #if !defined(_RECEIVE_SHADOWS_OFF)
            mainLight.shadowAttenuation = MainLightShadow_Custom(inputData.shadowCoord, inputData.positionWS, inputData.shadowMask, _MainLightOcclusionProbes);
        #else
            mainLight.shadowAttenuation = 1;
        #endif

        half3 speColor = LightingPhysically_Custom(brdfData, mainLight, inputData.normalWS, inputData.viewDirectionWS);

        color.rgb += speColor;

        #if defined(_QUALITY_4) || defined(_QUALITY_5)
            #if defined(_ADDITIONAL_LIGHTS) && !defined(_SPECULARHIGHLIGHTS_OFF)
                uint pixelLightCount = min(GetAdditionalLightsCount(), 2);
                for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
                {
                    Light light = GetAdditionalLight(lightIndex, inputData.positionWS, half4(1, 1, 1, 1));
                    half3 speColor = LightingPhysically_Custom(brdfData, light, inputData.normalWS, inputData.viewDirectionWS);

                    color.rgb += speColor;
                }
            #endif
        #endif
    #endif
    
    color += surfaceData.emission;

    return half4(color, surfaceData.alpha);
}

half4 BakedFragmentPBR(InputData inputData, SurfaceData surfaceData)
{
    return BakedFragmentPBR(inputData, surfaceData, 1);
}



half3 SubtractDirectMainLightFromLightmap_Origin(Light mainLight, half3 normalWS, half3 bakedGI ,half shadowGIPow)
{
    // Let's try to make realtime shadows work on a surface, which already contains
    // baked lighting and shadowing from the main sun light.
    // Summary:
    // 1) Calculate possible value in the shadow by subtracting estimated light contribution from the places occluded by realtime shadow:
    //      a) preserves other baked lights and light bounces
    //      b) eliminates shadows on the geometry facing away from the light
    // 2) Clamp against user defined ShadowColor.
    // 3) Pick original lightmap value, if it is the darkest one.


    // 1) Gives good estimate of illumination as if light would've been shadowed during the bake.
    // We only subtract the main direction light. This is accounted in the contribution term below.
    half shadowStrength = GetMainLightShadowStrength();
    half contributionTerm = saturate(dot(mainLight.direction, normalWS));
    half3 lambert = mainLight.color * contributionTerm;
    half3 estimatedLightContributionMaskedByInverseOfShadow =  lambert * (1.0 - mainLight.shadowAttenuation) ;


    
    half3 shadowGI = lerp(0 ,bakedGI ,estimatedLightContributionMaskedByInverseOfShadow ) *  shadowGIPow;

    half3 subtractedLightmap =  bakedGI - estimatedLightContributionMaskedByInverseOfShadow + shadowGI ; 

   // 2) Allows user to define overall ambient of the scene and control situation when realtime shadow becomes too dark.
    half3 realtimeShadow = max(subtractedLightmap, _SubtractiveShadowColor.xyz);

    realtimeShadow = lerp(bakedGI, realtimeShadow, shadowStrength);

    // 3) Pick darkest color
    return min(bakedGI, realtimeShadow);
}


 void MixRealtimeAndBakedGI_Origin(inout Light light, half3 normalWS, inout half3 bakedGI , half shadowGIPow)
{
#if defined(LIGHTMAP_ON) && defined(_MIXED_LIGHTING_SUBTRACTIVE)
    bakedGI = SubtractDirectMainLightFromLightmap_Origin(light, normalWS, bakedGI , shadowGIPow);
#endif
}


#endif
