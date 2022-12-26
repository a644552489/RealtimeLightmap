#ifndef CUSTOM_LIGHTMAP_DEFINE_INCLUDED
    #define CUSTOM_LIGHTMAP_DEFINE_INCLUDED

    #pragma shader_feature   CUSTOM_LIGHTMAP_ON
    #pragma shader_feature   CUSTOM_DIRLIGHTMAP_COMBINED
    #pragma shader_feature   CUSTOM_SHADOWS_SHADOWMASK
    #pragma shader_feature   CUSTOM_LIGHTMAP_SHADOW_MIXING

    #ifdef CUSTOM_LIGHTMAP_ON
        #define LIGHTMAP_ON
    #endif

    #ifdef CUSTOM_DIRLIGHTMAP_COMBINED
        #define DIRLIGHTMAP_COMBINED
    #endif

    #ifdef CUSTOM_SHADOWS_SHADOWMASK
        #define SHADOWS_SHADOWMASK
    #endif

    #ifdef CUSTOM_LIGHTMAP_SHADOW_MIXING
        #define LIGHTMAP_SHADOW_MIXING
    #endif
    
#endif
