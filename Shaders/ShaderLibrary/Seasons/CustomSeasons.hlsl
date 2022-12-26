#ifndef CUSTOM_SEASONS
    #define CUSTOM_SEASONS

    #include "../MyLibrary.hlsl"
    #include "../GlobalUvScale.hlsl"
    


    //-----------------------------------------------------------------------------------------------

    struct SeasonsData {
        float2 uv;
        half3 baseColor;
        float3 normalWS;
        float3 positionWS;
        half4 obj_snow_baseColor_offset;
        half4 obj_snow_color;
        half obj_snow_offset;
        half obj_snow_intnesity;
        half2 obj_textureMask;
    };

    half _Global_Season_Progress;
    half _Global_Season_Vegetation_SizeScale;
    half _Global_Season_Vegetation_AlphaTest;


    //颜色管理器
    int _Global_Color_Mixer_Cur_Index;
    int _Global_Color_Mixer_Next_Index;
    //季节节点数量
    int _Global_Color_Mixer_Step;
    //材质分类数量
    int _Global_Color_Mixer_Count;
    TEXTURE2D(_Global_Color_Mixer_Map);       SAMPLER(sampler_Global_Color_Mixer_Map);
    

    //雪
    float _Global_Snow_Progress;
    half3 _Global_Snow_Color;
    half _Global_Snow_Offset;
    half _Global_Snow_Intnesity;

    //结冰
    half _Global_Water_Freeze_Rate;

    float4 _Global_SnowMaskMap_ST;
    float4 _Global_SnowColorMap_ST;
    float4 _Global_SnowColorMap_Tree_ST;
    TEXTURE2D(_Global_SnowMaskMap);       SAMPLER(sampler_Global_SnowMaskMap);
    TEXTURE2D(_Global_SnowColorMap);       SAMPLER(sampler_Global_SnowColorMap);
    TEXTURE2D(_Global_SnowColorMap_Tree);       SAMPLER(sampler_Global_SnowColorMap_Tree);

    //-----------------------------------------------------------------------------------------------
    #if defined(_SEASON_SNOW_TEXTURE_MASK_UV_UV_1) 
        #define GET_SNOW_TEXTURE_UV(uv0,uv1,uv2) uv1
    #elif defined(_SEASON_SNOW_TEXTURE_MASK_UV_UV_2) 
        #define GET_SNOW_TEXTURE_UV(uv0,uv1,uv2) uv2
    #else
        #define GET_SNOW_TEXTURE_UV(uv0,uv1,uv2) uv0
    #endif

    #ifdef _SEASON_SNOW_TEXTURE_MASK 
        TEXTURE2D (_Snow_Texture_Mask); SAMPLER(sampler_Snow_Texture_Mask);
    #elif _SEASON_SNOW_ICE_MASK
        TEXTURE2D (_Snow_Texture_Mask); SAMPLER(sampler_Snow_Texture_Mask);
    #endif

    half2 GetSnowMask(half2 uv)
    {
        #ifdef _SEASON_SNOW_TEXTURE_MASK
            return SAMPLE_TEXTURE2D( _Snow_Texture_Mask, sampler_Snow_Texture_Mask, uv).rg;
        #elif _SEASON_SNOW_ICE_MASK
            return SAMPLE_TEXTURE2D( _Snow_Texture_Mask, sampler_Snow_Texture_Mask, uv).rg;
        #else
            return 1;
        #endif
    }

    //-----------------------------------------------------------------------------------------------
    half3 GetSnowColor(SeasonsData seasonsData)
    {
        half2 colorUV = GetGlobalUvScale_UnKeyword(TRANSFORM_TEX(seasonsData.positionWS.xz, _Global_SnowColorMap));
        half3 snowColor =  SAMPLE_TEXTURE2D(_Global_SnowColorMap, sampler_Global_SnowColorMap, colorUV).rgb * seasonsData.obj_snow_color.rgb * _Global_Snow_Color.rgb;
        return snowColor;
    }


    half3 GetWinterGlobalMask(SeasonsData seasonsData)
    {
        half3 snowColor = GetSnowColor(seasonsData);

        half2 maskUV = TRANSFORM_TEX(seasonsData.positionWS.xz, _Global_SnowMaskMap);
        half snowMask =  SAMPLE_TEXTURE2D(_Global_SnowMaskMap, sampler_Global_SnowMaskMap, maskUV).r;

        snowMask = abs(saturate(snowMask) + seasonsData.obj_snow_offset + _Global_Snow_Offset);
        snowMask = saturate(snowMask * seasonsData.obj_snow_intnesity * _Global_Snow_Intnesity) ;

        float progress = _Global_Snow_Progress; 
        progress = saturate(snowMask - 1 + progress);

        return lerp(seasonsData.baseColor,snowColor, progress);
    }

    half3 GetWinterNormal(SeasonsData seasonsData)
    {
        half3 snowColor = GetSnowColor(seasonsData);

        half snowMask =  seasonsData.normalWS.y;

        snowMask = abs(saturate(snowMask) + seasonsData.obj_snow_offset + _Global_Snow_Offset);
        snowMask = saturate(snowMask * seasonsData.obj_snow_intnesity);

        if(seasonsData.obj_snow_baseColor_offset.w > 0.5)
        {
            half temp = dot(seasonsData.baseColor,seasonsData.obj_snow_baseColor_offset.rgb);
            snowMask = saturate(remap(temp + snowMask,0.45,0.55,0,1));
        }

        snowMask = saturate(snowMask  * _Global_Snow_Intnesity);

        float progress = _Global_Snow_Progress; 
        progress = saturate(snowMask - 1 + progress);

        return lerp(seasonsData.baseColor,snowColor, progress);
    }

    half3 GetWinterTextureMask(SeasonsData seasonsData)
    {
        half3 snowColor = GetSnowColor(seasonsData);
        
        #if _SEASON_SNOW_TEXTURE_GLOBAL_MIXER_ON
            half2 maskUV = TRANSFORM_TEX(seasonsData.positionWS.xz, _Global_SnowMaskMap);
            half globalMask =  SAMPLE_TEXTURE2D(_Global_SnowMaskMap, sampler_Global_SnowMaskMap, maskUV).r;
            half snowMask =  lerp(seasonsData.obj_textureMask.r,globalMask,seasonsData.obj_textureMask.g);
        #else
            half snowMask =  seasonsData.obj_textureMask.r;
        #endif
        snowMask = abs(saturate(snowMask) + seasonsData.obj_snow_offset + _Global_Snow_Offset);
        snowMask = saturate(snowMask * seasonsData.obj_snow_intnesity);

        snowMask = saturate(snowMask  * _Global_Snow_Intnesity);

        float progress = _Global_Snow_Progress; 
        progress = saturate(snowMask - 1 + progress);

        return lerp(seasonsData.baseColor,snowColor, progress);
    }
    
    half3 GetIceTextureMask(SeasonsData seasonsData)
    {
        half3 snowColor = GetSnowColor(seasonsData);
        
        #if _SEASON_SNOW_TEXTURE_GLOBAL_MIXER_ON
            half2 maskUV = TRANSFORM_TEX(seasonsData.positionWS.xz, _Global_SnowMaskMap);
            half globalMask =  SAMPLE_TEXTURE2D(_Global_SnowMaskMap, sampler_Global_SnowMaskMap, maskUV).r;
            half snowMask =  lerp(seasonsData.obj_textureMask.r,globalMask,seasonsData.obj_textureMask.g);
        #else
            half snowMask =  seasonsData.obj_textureMask.r;
        #endif

        snowMask = saturate(snowMask * seasonsData.obj_snow_intnesity);

        snowMask = saturate(snowMask  * _Global_Snow_Intnesity);


        return lerp(seasonsData.baseColor,snowColor, snowMask);
    }

    half3 GetWinterTree(SeasonsData seasonsData)
    {
        half2 colorUV = TRANSFORM_TEX(seasonsData.uv, _Global_SnowColorMap_Tree);
        half3 snowColor =  SAMPLE_TEXTURE2D(_Global_SnowColorMap_Tree, sampler_Global_SnowColorMap_Tree, colorUV).rgb * seasonsData.obj_snow_color.rgb * _Global_Snow_Color.rgb;

        half snowMask =  seasonsData.normalWS.y * snowColor.r;

        snowMask = abs(saturate(snowMask) + seasonsData.obj_snow_offset + _Global_Snow_Offset);
        snowMask = saturate(snowMask * seasonsData.obj_snow_intnesity * _Global_Snow_Intnesity) ;

        float progress = _Global_Snow_Progress; 
        progress = saturate(snowMask - 1 + progress);

        return lerp(seasonsData.baseColor,snowColor, progress);
    }

    half3 GetWinterColor(SeasonsData seasonsData)
    {
        //  return GetWinterTextureMask(seasonsData);
        if(_Global_Snow_Progress > 0)
        {
            #ifdef _SNOW_TREE
                return GetWinterTree(seasonsData);
            #else
                #if defined(_SEASON_SNOW_GLOBAL_MASK) 
                    return GetWinterGlobalMask(seasonsData);
                #elif defined(_SEASON_SNOW_NORMAL) 
                    return GetWinterNormal(seasonsData);
                #elif defined(_SEASON_SNOW_TEXTURE_MASK) 
                    return GetWinterTextureMask(seasonsData);
                #elif defined(_SEASON_SNOW_ICE_MASK)
                    return GetIceTextureMask(seasonsData);
                #else
                    return seasonsData.baseColor;
                #endif
            #endif
        }
        else
        {
            return seasonsData.baseColor;
        }
    }
    //----------------------------------------------------------------------
    half3 GetSeasonsBaseColor(half3 color,int index)
    {
        #ifndef _SEASON_COLOR_ON
            return color;
        #else
            float materialValue = index;

            float cellWidth = rcp(_Global_Color_Mixer_Step);
            float cellHeight = rcp((_Global_Color_Mixer_Count * 3.0));
            float cur_x = cellWidth * 0.5 + _Global_Color_Mixer_Cur_Index * cellWidth;
            float next_x = cellWidth * 0.5 + _Global_Color_Mixer_Next_Index * cellWidth;
            float y = cellHeight * 0.5 + materialValue * 3.0 * cellHeight;
            
            half3 cur_color_r = SAMPLE_TEXTURE2D(_Global_Color_Mixer_Map,sampler_Global_Color_Mixer_Map,float2(cur_x,y)).rgb;
            half3 cur_color_g = SAMPLE_TEXTURE2D(_Global_Color_Mixer_Map,sampler_Global_Color_Mixer_Map,float2(cur_x, y + cellHeight )).rgb;
            half3 cur_color_b = SAMPLE_TEXTURE2D(_Global_Color_Mixer_Map,sampler_Global_Color_Mixer_Map,float2(cur_x,y + cellHeight + cellHeight)).rgb;

            half3 next_color_r = SAMPLE_TEXTURE2D(_Global_Color_Mixer_Map,sampler_Global_Color_Mixer_Map,float2(next_x,y)).rgb;
            half3 next_color_g = SAMPLE_TEXTURE2D(_Global_Color_Mixer_Map,sampler_Global_Color_Mixer_Map,float2(next_x,y + cellHeight)).rgb;
            half3 next_color_b = SAMPLE_TEXTURE2D(_Global_Color_Mixer_Map,sampler_Global_Color_Mixer_Map,float2(next_x,y + cellHeight + cellHeight)).rgb;

            cur_color_r = cur_color_r * 4 - 2;
            cur_color_g =  cur_color_g * 4 - 2;
            cur_color_b =  cur_color_b * 4 - 2;

            next_color_r =  next_color_r * 4 - 2;
            next_color_g =  next_color_g * 4 - 2;
            next_color_b =  next_color_b * 4 - 2;

            half3 colorA = half3(
            dot(color,cur_color_r),
            dot(color,cur_color_g),
            dot(color,cur_color_b)
            );

            half3 colorB = half3(
            dot(color,next_color_r),
            dot(color,next_color_g),
            dot(color,next_color_b)
            );

            return  lerp(colorA,colorB,_Global_Season_Progress);
        #endif
    }

    #ifdef _SEASON_COLOR_MASK_MAP_ON
        TEXTURE2D (_SeasonColorMaskMap); SAMPLER(sampler_SeasonColorMaskMap);
    #endif
    half3 GetSeasonsBaseColor(half3 color,int index,half2 uv)
    {
        #ifdef _SEASON_COLOR_MASK_MAP_ON
            float tmp_w = SAMPLE_TEXTURE2D(_SeasonColorMaskMap, sampler_SeasonColorMaskMap, uv).r;
            color.rgb =  lerp(color.rgb,  GetSeasonsBaseColor(color.rgb,index),tmp_w);
        #else
            color.rgb = GetSeasonsBaseColor(color,index);
        #endif

        return color;
    }



#endif
