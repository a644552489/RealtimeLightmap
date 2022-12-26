#ifndef CUSTOM_HEIGHT_FOG
    #define CUSTOM_HEIGHT_FOG
    
    float2 _CutomFog_MapSize;
    half _CutomFog_FogHeightMax;
    half _CutomFog_FogHeightMin;
    half _CutomFog_FogHeightStrength;
    half4 _CutomFog_FogColor;

    float2 _CutomFog_CloudDirection;
    half _CutomFog_CloudScale;
    half4 _CutomFog_CloudColor;

    half4 _CutomFog_SelectColor;
    half _CutomFog_SelectSpeed;
    half _CutomFog_SelectStrengthMin;
    half _CutomFog_SelectStrengthMax;

    float4 _CustomFog_BeginEnd;



    TEXTURE2D(_CutomFog_FogAreaMaskMap);       SAMPLER(sampler_CutomFog_FogAreaMaskMap);
    TEXTURE2D(_CutomFog_CloudMap);       SAMPLER(sampler_CutomFog_CloudMap);


    half3 GetHeightFogColor(half3 baseColor,float3 worldPos)
    {
        float2 areaMaskUV = worldPos.xz/_CutomFog_MapSize;
        float2 areaMask = SAMPLE_TEXTURE2D(_CutomFog_FogAreaMaskMap, sampler_CutomFog_FogAreaMaskMap, areaMaskUV).rg;

        float heightMask = smoothstep(_CutomFog_FogHeightMin,_CutomFog_FogHeightMax,worldPos.y) * _CutomFog_FogHeightStrength;
        heightMask = lerp(heightMask,1,areaMask.r);

        float2 cloudUV = (worldPos.xz + _Time.y * _CutomFog_CloudDirection) * _CutomFog_CloudScale;
        half cloudMask = SAMPLE_TEXTURE2D(_CutomFog_CloudMap,sampler_CutomFog_CloudMap,cloudUV).r;

        float a = _CutomFog_SelectStrengthMin;
        float b = _CutomFog_SelectStrengthMax;
        float c = (b - a) * 2;
        float t = abs(frac(_Time.y*_CutomFog_SelectSpeed)-0.5)*c+a;
        
        float3 color1 =  lerp(_CutomFog_FogColor.rgb * _CutomFog_FogColor.a,baseColor,heightMask);
        float3 color2 = lerp(color1,_CutomFog_CloudColor.rgb,cloudMask);
        float3 color3 = lerp(color2,_CutomFog_SelectColor.rgb,areaMask.g * t);

        return color3;
     
    }


    //----------------------------------------------------------------------
    //样式
    half3 _WorldFog_Color;
    half _WorldFog_Strength;

    float4 _WorldFog_AOI_Rect;
    //xy大格子数量，zw小格子数量
    float4 _WorldFog_GirdSize = float4(1.,1.,1.,1.);

    //队伍遮罩图
    TEXTURE2D(_WorldFogBlurTex);       SAMPLER(sampler_WorldFogBlurTex);


    half GetWorldFogMask_Team(float3 worldPos)
    {
        half2 uv = ((float2(worldPos.x,worldPos.z) - _WorldFog_AOI_Rect.xy) / _WorldFog_AOI_Rect.zw);
        half data = SAMPLE_TEXTURE2D(_WorldFogBlurTex, sampler_WorldFogBlurTex,uv).r;

        return data;
    }

    half3 GetWorldFogColor(float3 baseColor, float3 worldPos)
    {
        half mask =  GetWorldFogMask_Team(worldPos);
        mask = 1 - clamp(mask,0,1);
        

        return  lerp(baseColor,_WorldFog_Color, mask * _WorldFog_Strength);
    }

    //----------------------------------------------------------------------
    half2 GetBirthFogMask_Team(float3 worldPos)
    {
        half2 uv = ((float2(worldPos.x,worldPos.z) - _WorldFog_AOI_Rect.xy) / _WorldFog_AOI_Rect.zw);
        half2 data = SAMPLE_TEXTURE2D(_WorldFogBlurTex, sampler_WorldFogBlurTex,uv).rg;

        return data;
    }
    
    half3 GetBirthFogColor(float3 baseColor, float3 worldPos)
    {
        //没经过的地方-------------------------
        float heightMask = smoothstep(_CutomFog_FogHeightMin,_CutomFog_FogHeightMax,worldPos.y) ;//* _CutomFog_FogHeightStrength;



        //经过的视野-------------------------
        half2 data = GetBirthFogMask_Team(worldPos);

        half recordGirdMask = 1 - data.g;


   
        //烟雾缭绕-------------------------
        float2 cloudUV = (worldPos.xz + _Time.y * _CutomFog_CloudDirection) * _CutomFog_CloudScale;
        half cloudMask = SAMPLE_TEXTURE2D(_CutomFog_CloudMap,sampler_CutomFog_CloudMap,cloudUV).r;

        half fogDensity = saturate((_CustomFog_BeginEnd.x - worldPos.y - cloudMask.r * 10) / (_CustomFog_BeginEnd.x  -_CustomFog_BeginEnd.y ));
       fogDensity = saturate(fogDensity  * fogDensity);


       //float Area = saturate(cloudMask.r * _CutomFog_FogHeightStrength );
       //float visual = lerp(heightMask , Area , _CustomFog_BeginEnd.z);
   
   
       // float control = saturate( heightMask + fogDensity  );
   
    
        float3 color1 =  lerp(_CutomFog_FogColor.rgb * _CutomFog_FogColor.a ,baseColor  , heightMask);
       
        
        float3 color2 =  lerp(color1,baseColor*_WorldFog_Color,recordGirdMask);
        float3 color3 = lerp(color2,_CutomFog_CloudColor.rgb,fogDensity );

        //当前视野-------------------------

        float3 color4 = lerp(color3,baseColor,data.r);

        return color4;
        
       
    }

    //----------------------------------------------------------------------

    half3 GetFogColor(half3 baseColor,float3 worldPos)
    {
        #ifdef _CUSTOM_HEIGHT_FOG
            return GetHeightFogColor(baseColor,worldPos);
        #endif

        #ifdef _CUSTOM_WORLD_FOG
            return GetWorldFogColor(baseColor,worldPos);
        #endif

        #ifdef _CUSTOM_BIRTH_FOG
            return GetBirthFogColor(baseColor,worldPos);
        #endif
        
        return baseColor;
    }


    

#endif
