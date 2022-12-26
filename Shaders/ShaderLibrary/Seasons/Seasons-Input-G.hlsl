#ifndef CUSTOM_SEASONS_INPUT_G
    #define CUSTOM_SEASONS_INPUT_G

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    
    UNITY_INSTANCING_BUFFER_START(SeasonsInput)
    UNITY_DEFINE_INSTANCED_PROP(int ,_Season_Color_Mixer_Index)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_Obj_Snow_BaseColor_Offset)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_Obj_Snow_Color)
    UNITY_DEFINE_INSTANCED_PROP(half ,_Obj_Snow_Offset)
    UNITY_DEFINE_INSTANCED_PROP(half ,_Obj_Snow_Intnesity)
    UNITY_INSTANCING_BUFFER_END(SeasonsInput) 

    
    #define _Season_Color_Mixer_Index UNITY_ACCESS_INSTANCED_PROP(SeasonsInput, _Season_Color_Mixer_Index)
    #define _Obj_Snow_BaseColor_Offset UNITY_ACCESS_INSTANCED_PROP(SeasonsInput, _Obj_Snow_BaseColor_Offset)
    #define _Obj_Snow_Color UNITY_ACCESS_INSTANCED_PROP(SeasonsInput, _Obj_Snow_Color)
    #define _Obj_Snow_Offset UNITY_ACCESS_INSTANCED_PROP(SeasonsInput, _Obj_Snow_Offset)
    #define _Obj_Snow_Intnesity UNITY_ACCESS_INSTANCED_PROP(SeasonsInput, _Obj_Snow_Intnesity)

#endif
