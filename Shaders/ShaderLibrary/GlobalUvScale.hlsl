#ifndef GLOBAL_UV_SCALE
    #define GLOBAL_UV_SCALE 

    float _Global_Uv_Scale_X;
    float _Global_Uv_Scale_Y;
    
    float2 GetGlobalUvScale(float2 curUv)
    {
        #if _GLOBAL_UV_SCALE_ON
            return curUv * float2(_Global_Uv_Scale_X,_Global_Uv_Scale_Y);
        #endif

        return curUv;
    }

    float2 GetGlobalUvScale_UnKeyword(float2 curUv)
    {
        return curUv * float2(_Global_Uv_Scale_X,_Global_Uv_Scale_Y);
    }

#endif
