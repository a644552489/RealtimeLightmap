#ifndef CUSTOM_ARCHITEXTURE_LOD_PASS_INCLUDED
    #define CUSTOM_ARCHITEXTURE_LOD_PASS_INCLUDED 

    
    #include "../../../ShaderLibrary/CustomLighting.hlsl"

    // GLES2 has limited amount of interpolators
    #if defined(_PARALLAXMAP) && !defined(SHADER_API_GLES)
        #define REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR
    #endif

    #if (defined(_NORMALMAP) || (defined(_PARALLAXMAP) && !defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR))) || defined(_DETAIL)
        #define REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
    #endif

    // keep this file in sync with LitGBufferPass.hlsl

    struct Attributes
    {
        float4 positionOS   : POSITION;
        float3 normalOS     : NORMAL;
        float4 tangentOS    : TANGENT;
        float2 texcoord     : TEXCOORD0;
        float2 lightmapUV   : TEXCOORD1;
        float4 color   : COLOR;
        float2 uv2           : TEXCOORD2;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct Varyings
    {
        float2 uv                       : TEXCOORD0;
        DECLARE_LIGHTMAP_OR_SH(lightmapUV_Morning, vertexSH, 1);
        float2 lightmapUV_Evening       :TEXCOORD10;

        #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
            float3 positionWS               : TEXCOORD2;
        #endif

        float3 normalWS                 : TEXCOORD3;
        #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
            float4 tangentWS                : TEXCOORD4;    // xyz: tangent, w: sign
        #endif
        float3 viewDirWS                : TEXCOORD5;

        half4 fogFactorAndVertexLight   : TEXCOORD6; // x: fogFactor, yzw: vertex light

        #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            float4 shadowCoord              : TEXCOORD7;
        #endif

        #if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
            float3 viewDirTS                : TEXCOORD8;
        #endif

        float4 positionCS               : SV_POSITION;

        float4 exUV                 :TEXCOORD9;
        float4 color                :TEXCOORD11;
        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    };

    void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
    {
        inputData = (InputData)0;

        #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
            inputData.positionWS = input.positionWS;
        #endif

        half3 viewDirWS = SafeNormalize(input.viewDirWS);
        #if defined(_NORMALMAP) || defined(_DETAIL)
            float sgn = input.tangentWS.w;      // should be either +1 or -1
            float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
            inputData.normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz));
        #else
            inputData.normalWS = input.normalWS;
        #endif

        inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
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

        inputData.bakedGI = lerp(bakeGI_Morning , bakeGI_Evening , _LightmapStrength);
        //SAMPLE_GI(input.lightmapUV_Morning, input.vertexSH, inputData.normalWS) * _LightmapStrength;

        inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
        half4 shadowmask_Morning = SAMPLE_SHADOWMASK_CUSTOM(ShadowMask_Morning ,sampler_ShadowMask_Morning , input.lightmapUV_Morning);
        half4 shadowmask_Evening = SAMPLE_SHADOWMASK_CUSTOM(ShadowMask_Evening ,sampler_ShadowMask_Evening , input.lightmapUV_Evening);
        inputData.shadowMask = lerp(shadowmask_Morning , shadowmask_Evening , _LightmapStrength);
    }

    ///////////////////////////////////////////////////////////////////////////////
    //                  Vertex and Fragment functions                            //
    ///////////////////////////////////////////////////////////////////////////////

    // Used in Standard (Physically Based) shader
    Varyings LitPassVertex(Attributes input)
    {
        Varyings output = (Varyings)0;

        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_TRANSFER_INSTANCE_ID(input, output);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

        #if defined(_VERTEX_MOVE_ON)
            float3 vertex =  TransformObjectToWorld(input.positionOS.xyz);
            float a = vertex.x * vertex.z;
            float fa = fmod(a, 2);
            input.positionOS.xyz += float3(sin(a),0,cos(a)) * _VertexMoveDist * sin(_Time.w * (_VertexMoveSpeed + _VertexMoveSpeedOffset*(1-fa))+a) * input.color.a;
        #endif

        VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

        // normalWS and tangentWS already normalize.
        // this is required to avoid skewing the direction during interpolation
        // also required for per-vertex lighting and SH evaluation
        VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

        half3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
        half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
        half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

        output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
        output.color = input.color;
        // already normalized from normal transform to WS.
        output.normalWS = normalInput.normalWS;
        output.viewDirWS = viewDirWS;
        #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR) || defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
            real sign = input.tangentOS.w * GetOddNegativeScale();
            half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
        #endif
        #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
            output.tangentWS = tangentWS;
        #endif

        #if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
            half3 viewDirTS = GetViewDirectionTangentSpace(tangentWS, output.normalWS, viewDirWS);
            output.viewDirTS = viewDirTS;
        #endif

        OUTPUT_LIGHTMAP_UV(input.lightmapUV, LightmapST_Morning, output.lightmapUV_Morning);
        OUTPUT_LIGHTMAP_UV(input.lightmapUV ,LightmapST_Evening , output.lightmapUV_Evening );
        OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

        output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

        #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
            output.positionWS = vertexInput.positionWS;
        #endif

        #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = GetShadowCoord(vertexInput);
        #endif

        output.positionCS = vertexInput.positionCS;

        output.exUV = float4(input.lightmapUV.x,input.lightmapUV.y,input.uv2.x,input.uv2.y);

        return output;
    }


    ///////////////////////////////////////////////////////////////////////////////
    //                  Vertex and Fragment functions                            //
    ///////////////////////////////////////////////////////////////////////////////


    half4 CustomUniversalFragmentLambert(InputData inputData, half3 diffuse, half3 emission, half alpha)
    {
        Light mainLight = GetMainLight();
        #if !defined(_RECEIVE_SHADOWS_OFF)
            mainLight.shadowAttenuation = MainLightShadow_Custom(inputData.shadowCoord, inputData.positionWS,inputData.shadowMask, _MainLightOcclusionProbes);
        #else
            mainLight.shadowAttenuation = 1;
        #endif

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
   

        #ifdef _ADDITIONAL_LIGHTS
            uint pixelLightCount = GetAdditionalLightsCount();
            for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
            {
                Light light = GetAdditionalLight(lightIndex, inputData.positionWS, half4(1, 1, 1, 1));
                #if defined(_SCREEN_SPACE_OCCLUSION)
                    light.color *= aoFactor.directAmbientOcclusion;
                #endif
                half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
                #ifndef LIGHTMAP_ON
                    diffuseColor += LightingLambert(attenuatedLightColor, light.direction, inputData.normalWS);
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
    // Used in Standard (Physically Based) shader
    half4 LitPassPBRFragment(Varyings input) : SV_Target
    {
        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

        SurfaceData surfaceData;
        InitializeStandardLitSurfaceData(input.uv, surfaceData);

        #ifdef _ALPHAPREMULTIPLY_ON
            surfaceData.albedo *= surfaceData.alpha;
        #endif

        InputData inputData;
        InitializeInputData(input, surfaceData.normalTS, inputData);
        
        

        //-----------------------------------
        //Season
        #ifdef _SEASON_ON
            SeasonsData seasonsData;
            seasonsData.baseColor = GetSeasonsBaseColor(surfaceData.albedo,_Season_Color_Mixer_Index);
            seasonsData.normalWS = input.normalWS;
            seasonsData.positionWS = input.positionWS;
            seasonsData.obj_snow_baseColor_offset = _Obj_Snow_BaseColor_Offset;
            seasonsData.obj_snow_color = _Obj_Snow_Color;
            seasonsData.obj_snow_offset = _Obj_Snow_Offset;
            seasonsData.obj_snow_intnesity = _Obj_Snow_Intnesity;
            seasonsData.obj_textureMask = GetSnowMask(GET_SNOW_TEXTURE_UV(input.uv,input.exUV.xy,input.exUV.zw));
            surfaceData.albedo = GetWinterColor(seasonsData);
        #endif
        //-----------------------------------

        half4 color = BakedFragmentPBR(inputData, surfaceData,_ReflectStrength*surfaceData.smoothness.x);
        color.rgb = GetGroudCloud(color.rgb , input.positionWS);

        color.rgb = GetFogColor(color.rgb ,input.positionWS);

        color.rgb = GetGrayColor(color.rgb);

        return color;    
    }

    //lambert
    half4 LitPassLambertFragment(Varyings input) : SV_Target
    {
        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

        float2 uv = input.uv;
        half4 diffuseAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
        half4 DetailAlpha = SampleAlbedoAlpha(uv , TEXTURE2D_ARGS(_DetailAlbedoMap , sampler_DetailAlbedoMap))*_DetailAlbedoColor;



        //zzw:22.09.20 add mask
        half mask_var = SampleMaskMap(uv,TEXTURE2D_ARGS(_MaskMap,sampler_MaskMap));
        half3 diffuse = lerp(diffuseAlpha.rgb * _BaseColor.rgb, _MaskColor.rgb , mask_var);
        //half3 diffuse = diffuseAlpha.rgb * _BaseColor.rgb;
        //zzw:add end
        diffuse = lerp(DetailAlpha.rgb , diffuse , input.color.a);

        half alpha = diffuseAlpha.a * _BaseColor.a;
        AlphaDiscard(alpha, _Cutoff);

        #ifdef _ALPHAPREMULTIPLY_ON
            diffuse *= alpha;
        #endif

        half3 normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap));
        half3 emission = SampleEmission(uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap)) * _EmissionStrength;

        InputData inputData;
        InitializeInputData(input, normalTS, inputData);

        //-----------------------------------
        //Season
        #ifdef _SEASON_ON
            SeasonsData seasonsData;
            seasonsData.baseColor = GetSeasonsBaseColor(diffuse.rgb,_Season_Color_Mixer_Index);
            seasonsData.normalWS = input.normalWS;
            seasonsData.positionWS = input.positionWS;
            seasonsData.obj_snow_baseColor_offset = _Obj_Snow_BaseColor_Offset;
            seasonsData.obj_snow_color = _Obj_Snow_Color;
            seasonsData.obj_snow_offset = _Obj_Snow_Offset;
            seasonsData.obj_snow_intnesity = _Obj_Snow_Intnesity;
            seasonsData.obj_textureMask = GetSnowMask(GET_SNOW_TEXTURE_UV(uv,input.exUV.xy,input.exUV.zw));
            diffuse.rgb = GetWinterColor(seasonsData);
        #endif
        //-----------------------------------

        half4 color =  CustomUniversalFragmentLambert(inputData, diffuse, emission, alpha);

                color.rgb = GetGroudCloud(color.rgb , input.positionWS);

        color.rgb = GetFogColor(color.rgb ,input.positionWS);

        color.rgb = GetGrayColor(color.rgb);

        return color;


    }

    
   

        //lambert
    half4 LitPassLambertFragment_ColorLerp(Varyings input) : SV_Target
    {
        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

        float2 uv = input.uv;
        half4 diffuseAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
        half4 DetailAlpha = SampleAlbedoAlpha(uv , TEXTURE2D_ARGS(_DetailAlbedoMap , sampler_DetailAlbedoMap))*_DetailAlbedoColor;


        half BaseColorMask = SAMPLE_TEXTURE2D(_BaseColorMaskMap , sampler_BaseColorMaskMap, TRANSFORM_TEX(uv, _BaseColorMaskMap)).r;



        //zzw:22.09.20 add mask
        half mask_var = SampleMaskMap(uv,TEXTURE2D_ARGS(_MaskMap,sampler_MaskMap));
        half3 diffuse = lerp(diffuseAlpha.rgb * _BaseColor.rgb, _MaskColor.rgb , mask_var);
        //half3 diffuse = diffuseAlpha.rgb * _BaseColor.rgb;
        //zzw:add end

         diffuse = lerp(DetailAlpha.rgb , diffuse , BaseColorMask);

        half alpha = diffuseAlpha.a * _BaseColor.a ;
        AlphaDiscard(alpha, _Cutoff);

        #ifdef _ALPHAPREMULTIPLY_ON
            diffuse *= alpha;
        #endif

        half3 normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap));
        half3 emission = SampleEmission(uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap)) * _EmissionStrength;

        InputData inputData;
        InitializeInputData(input, normalTS, inputData);

        //-----------------------------------
        //Season
        #ifdef _SEASON_ON
            SeasonsData seasonsData;
            seasonsData.baseColor = GetSeasonsBaseColor(diffuse.rgb,_Season_Color_Mixer_Index);
            seasonsData.normalWS = input.normalWS;
            seasonsData.positionWS = input.positionWS;
            seasonsData.obj_snow_baseColor_offset = _Obj_Snow_BaseColor_Offset;
            seasonsData.obj_snow_color = _Obj_Snow_Color;
            seasonsData.obj_snow_offset = _Obj_Snow_Offset;
            seasonsData.obj_snow_intnesity = _Obj_Snow_Intnesity;
            seasonsData.obj_textureMask = GetSnowMask(GET_SNOW_TEXTURE_UV(uv,input.exUV.xy,input.exUV.zw));
            diffuse.rgb = GetWinterColor(seasonsData);
        #endif
        //-----------------------------------

        half4 color =  CustomUniversalFragmentLambert(inputData, diffuse, emission, alpha);

                color.rgb = GetGroudCloud(color.rgb , input.positionWS);

        color.rgb = GetFogColor(color.rgb ,input.positionWS);

        color.rgb = GetGrayColor(color.rgb);

        return color;


    }



#endif

