#ifndef CUSTOM_SEASONS_INPUT
    #define CUSTOM_SEASONS_INPUT

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

    #define UNITY_PER_MATERIAL_SEASON_COLOR \
    int _Season_Color_Mixer_Index;

    #define UNITY_PER_MATERIAL_SEASON_SNOW \
    half4 _Obj_Snow_BaseColor_Offset;\
    half4 _Obj_Snow_Color;\
    half _Obj_Snow_Offset;\
    half _Obj_Snow_Intnesity;

#endif
