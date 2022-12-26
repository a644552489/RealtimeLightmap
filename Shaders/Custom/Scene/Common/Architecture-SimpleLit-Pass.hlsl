#ifndef ARCHITECTURE_SIMPLELIT_PASS_INCLUDED
    #define ARCHITECTURE_SIMPLELIT_PASS_INCLUDED
    
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

    
    #include "../../../ShaderLibrary/CustomLighting.hlsl"

    struct Attributes
    {
        float4 positionOS    : POSITION;
        float3 normalOS      : NORMAL;
        float4 tangentOS     : TANGENT;
        float2 texcoord      : TEXCOORD0;
        float2 lightmapUV    : TEXCOORD1;
        float2 uv2           : TEXCOORD2;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct Varyings
    {
        float2 uv                       : TEXCOORD0;
        DECLARE_LIGHTMAP_OR_SH(lightmapUV_Morning, vertexSH, 1);
        float4 lightmapUV_Evening       :TEXCOORD10;
        float3 posWS                    : TEXCOORD2;    // xyz: posWS

        #ifdef _NORMALMAP
            float4 normal                   : TEXCOORD3;    // xyz: normal, w: viewDir.x
            float4 tangent                  : TEXCOORD4;    // xyz: tangent, w: viewDir.y
            float4 bitangent                : TEXCOORD5;    // xyz: bitangent, w: viewDir.z
        #else
            float3  normal                  : TEXCOORD3;
            float3 viewDir                  : TEXCOORD4;
        #endif

        half4 fogFactorAndVertexLight   : TEXCOORD6; // x: fogFactor, yzw: vertex light

        #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            float4 shadowCoord              : TEXCOORD7;
        #endif

        float4 exUV           : TEXCOORD8;

        float4 positionCS               : SV_POSITION;
        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    };

    void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
    {
        inputData.positionWS = input.posWS;

        #ifdef _NORMALMAP
            half3 viewDirWS = half3(input.normal.w, input.tangent.w, input.bitangent.w);
            inputData.normalWS = TransformTangentToWorld(normalTS,
            half3x3(input.tangent.xyz, input.bitangent.xyz, input.normal.xyz));
        #else
            half3 viewDirWS = input.viewDir;
            inputData.normalWS = input.normal;
        #endif

        inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
        viewDirWS = SafeNormalize(viewDirWS);

        inputData.viewDirectionWS = viewDirWS;

        #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            inputData.shadowCoord = input.shadowCoord;
        #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
            inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
        #else
            inputData.shadowCoord = float4(0, 0, 0, 0);
        #endif

        inputData.fogCoord = input.fogFactorAndVertexLight.x;
        inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
   
        half3 bakeGI_Morning = SAMPLE_GI_CUSTOM(input.lightmapUV_Morning, input.vertexSH, inputData.normalWS ,
           Lightmap_Morning , sampler_Lightmap_Morning ,LightmapInd_Morning );

        half3 bakeGI_Evening = SAMPLE_GI_CUSTOM(input.lightmapUV_Evening, input.vertexSH, inputData.normalWS ,
           Lightmap_Evening , sampler_Lightmap_Evening ,LightmapInd_Evening );

        inputData.bakedGI = lerp(bakeGI_Morning , bakeGI_Evening  , _LightmapStrength);
        //SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);
        inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);

          half4 shadowmask_Morning = SAMPLE_SHADOWMASK_CUSTOM(ShadowMask_Morning ,sampler_ShadowMask_Morning , input.lightmapUV_Morning);
        half4 shadowmask_Evening = SAMPLE_SHADOWMASK_CUSTOM(ShadowMask_Evening ,sampler_ShadowMask_Evening , input.lightmapUV_Evening);
    

        inputData.shadowMask = lerp(shadowmask_Morning , shadowmask_Evening , _LightmapStrength);
        // SAMPLE_SHADOWMASK(input.lightmapUV);
    }

    ///////////////////////////////////////////////////////////////////////////////
    //                  Vertex and Fragment functions                            //
    ///////////////////////////////////////////////////////////////////////////////


    half4 CustomUniversalFragmentBlinnPhong(InputData inputData, half3 diffuse, half4 specularGloss, half smoothness, half3 emission, half alpha)
    {
        // To ensure backward compatibility we have to avoid using shadowMask input, as it is not present in older shaders
        #if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
            half4 shadowMask = inputData.shadowMask;
        #elif !defined (LIGHTMAP_ON)
            half4 shadowMask = unity_ProbesOcclusion;
        #else
            half4 shadowMask = half4(1, 1, 1, 1);
        #endif

        Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, shadowMask);
         
        mainLight.shadowAttenuation = MainLightShadow_Custom(inputData.shadowCoord, inputData.positionWS,inputData.shadowMask, _MainLightOcclusionProbes);

        #if defined(_SCREEN_SPACE_OCCLUSION)
            AmbientOcclusionFactor aoFactor = GetScreenSpaceAmbientOcclusion(inputData.normalizedScreenSpaceUV);
            mainLight.color *= aoFactor.directAmbientOcclusion;
            inputData.bakedGI *= aoFactor.indirectAmbientOcclusion;
        #endif

        MixRealtimeAndBakedGI_Origin(mainLight, inputData.normalWS, inputData.bakedGI , _ShadowGIStrength);

        half3 attenuatedLightColor = mainLight.color * (mainLight.distanceAttenuation * mainLight.shadowAttenuation);
        half3 diffuseColor = inputData.bakedGI;
        half3 specularColor = 0;

           diffuseColor += LightingLambert(attenuatedLightColor, mainLight.direction, inputData.normalWS);
        #ifndef LIGHTMAP_ON
         
            specularColor = LightingSpecular(attenuatedLightColor, mainLight.direction, inputData.normalWS, inputData.viewDirectionWS, specularGloss, smoothness);
        #endif

        #ifdef _ADDITIONAL_LIGHTS
            uint pixelLightCount = GetAdditionalLightsCount();
            for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
            {
                Light light = GetAdditionalLight(lightIndex, inputData.positionWS, shadowMask);
                #if defined(_SCREEN_SPACE_OCCLUSION)
                    light.color *= aoFactor.directAmbientOcclusion;
                #endif
                half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
                #ifndef LIGHTMAP_ON
                    diffuseColor += LightingLambert(attenuatedLightColor, light.direction, inputData.normalWS);
                    specularColor += LightingSpecular(attenuatedLightColor, light.direction, inputData.normalWS, inputData.viewDirectionWS, specularGloss, smoothness);
                #endif
            }
        #endif

        #ifdef _ADDITIONAL_LIGHTS_VERTEX
            diffuseColor += inputData.vertexLighting;
        #endif

        half3 finalColor = diffuseColor * diffuse + emission;

        #if defined(_SPECGLOSSMAP) || defined(_SPECULAR_COLOR)
            finalColor += specularColor;
        #endif

        return half4(finalColor, alpha);
    }

    // Used in Standard (Simple Lighting) shader
    Varyings LitPassVertexSimple(Attributes input)
    {
        Varyings output = (Varyings)0;

        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_TRANSFER_INSTANCE_ID(input, output);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

        VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
        VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
        half3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
        half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
        half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

        output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
        output.posWS.xyz = vertexInput.positionWS;
        output.positionCS = vertexInput.positionCS;

        #ifdef _NORMALMAP
            output.normal = half4(normalInput.normalWS, viewDirWS.x);
            output.tangent = half4(normalInput.tangentWS, viewDirWS.y);
            output.bitangent = half4(normalInput.bitangentWS, viewDirWS.z);
        #else
            output.normal = NormalizeNormalPerVertex(normalInput.normalWS);
            output.viewDir = viewDirWS;
        #endif

        #ifdef _CUSTOM_LIGHT_MAP_BATCH_ON
            float4 LightmapST_Morning = _Custom_LightmapST_Morning;
            float4 LightmapST_Evening = _Custom_LightmapST_Evening;
        #else
            float4 LightmapST_Morning = unity_LightmapST;
            float4 LightmapST_Evening = unity_LightmapST;
        #endif

        OUTPUT_LIGHTMAP_UV(input.lightmapUV, LightmapST_Morning, output.lightmapUV_Morning);
        OUTPUT_LIGHTMAP_UV(input.lightmapUV ,LightmapST_Evening , output.lightmapUV_Evening);
        
        OUTPUT_SH(output.normal.xyz, output.vertexSH);

        output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

        #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = GetShadowCoord(vertexInput);
        #endif

        output.exUV = float4(input.lightmapUV.x,input.lightmapUV.y,input.uv2.x,input.uv2.y);

        return output;
    }

    // Used for StandardSimpleLighting shader
    half4 LitPassFragmentSimple(Varyings input) : SV_Target
    {
        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

        float2 uv = input.uv;
        half4 diffuseAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
        half3 diffuse = diffuseAlpha.rgb * _BaseColor.rgb;

        half alpha = diffuseAlpha.a * _BaseColor.a;
        AlphaDiscard(alpha, _Cutoff);

        #ifdef _ALPHAPREMULTIPLY_ON
            diffuse *= alpha;
        #endif

        half3 normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap));
        half3 emission = SampleEmission(uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
        half4 specular = SampleSpecularSmoothness(uv, alpha, _SpecColor, TEXTURE2D_ARGS(_SpecGlossMap, sampler_SpecGlossMap));
        half smoothness = specular.a;

        InputData inputData;
        InitializeInputData(input, normalTS, inputData);

        //-----------------------------------
        //Season
        #ifdef _SEASON_ON
            SeasonsData seasonsData;
            seasonsData.baseColor = GetSeasonsBaseColor(diffuse.rgb,_Season_Color_Mixer_Index);
            seasonsData.normalWS = input.normal;
            seasonsData.positionWS = input.posWS;
            seasonsData.obj_snow_baseColor_offset = _Obj_Snow_BaseColor_Offset;
            seasonsData.obj_snow_color = _Obj_Snow_Color;
            seasonsData.obj_snow_offset = _Obj_Snow_Offset;
            seasonsData.obj_snow_intnesity = _Obj_Snow_Intnesity;
            seasonsData.obj_textureMask = GetSnowMask(GET_SNOW_TEXTURE_UV(uv,input.exUV.xy,input.exUV.zw));
            diffuse.rgb = GetWinterColor(seasonsData);

            //inputData.bakedGI *= _Snow_City_Lightmap_Color;
        #endif
        //-----------------------------------

        half4 color =  CustomUniversalFragmentBlinnPhong(inputData, diffuse, specular, smoothness, emission, alpha);

        color.rgb = GetFogColor(color.rgb ,input.posWS);

        color.rgb = GetGrayColor(color.rgb);

        return color;


    }

#endif
