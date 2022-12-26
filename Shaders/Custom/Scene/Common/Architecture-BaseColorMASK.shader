Shader "SLG_Custom/Scene/Common/Architecture-BaseColorMask"
{
    Properties
    {
        //-------------------------------------------------
        //               Render Settings 
        //-------------------------------------------------
        [StyledCategory(Render Settings,true)]_Category_Colapsable_Render("[ Rendering Cat ]", Float) = 1

        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("SrcBlend", Float) = 1.0
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("DstBlend", Float) = 0.0
        [Enum(Off, 0, On, 1)]_ZWrite("ZWrite", Float) = 1.0
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest ("ZTest", Float) = 4
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull", Float) = 2.0

        [Toggle(_ALPHATEST_ON)]_AlphaClip("AlphaClip", Float) = 0.0
        [StyledIndentLevelAdd]
        [StyledIfShow(_AlphaClip)][StyledField]_Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        [StyledIndentLevelSub]

        [StyledPassOff(CommonTransparentPreDepth)]_DisableTransparentPreDepth("Common Transparent PreDepth Off",Float) = 1.0
        //-------------------------------------------------
        //               Surface Settings 
        //------------------------------------------------- 
        [StyledCategory(Surface Settings,true)]_Category_Colapsable_Surface("[ Surface Cat ]", Float) = 1

        [StyledTextureSingleLine(_BaseColor)][MainTexture] _BaseMap("Albedo", 2D) = "white" {}
        [HideInInspector][MainColor]_BaseColor("Color", Color) = (1,1,1,1)

        [StyledTextureSingleLine]_DetailAlbedoMap("_DetailAlbedo" ,2D) ="white"{}
        _DetailAlbedoColor("DetailColor",Color) = (1,1,1,1)

          [StyledTextureSingleLine] _BaseColorMaskMap("BaseColorMaskMap" , 2D ) ="white"{}
          [StyledTexST(_BaseColorMaskMap)]_BaseColorMaskMap_ST("BaseColorMaskMap_ST" , Float )= 0

        [StyleSimpleLit]_SpecGlossMap("Specular Map", 2D) = "white" {}
        [HideInInspector]_SpecColor("Specular Color", Color) = (0.5, 0.5, 0.5, 0.5)
        [HideInInspector]_Smoothness("Smoothness", Range(0,1)) = 0.5
        [HideInInspector]_SmoothnessSource("Source", Float) = 0.0

        [StyledKeywordTextureSingleLine(_NORMALMAP,_BumpScale)]_BumpMap("Normal Map", 2D) = "bump" {}
        [HideInInspector]_BumpScale("Scale", Float) = 1.0

        [StyledKeywordTextureSingleLine(_EMISSION,_EmissionColor)]_EmissionMap("Emission", 2D) = "white" {}
        [HideInInspector][HDR] _EmissionColor("Color", Color) = (0,0,0)
     //   _LightmapStrength("_LightmapStrength" ,Range(0,10))= 1
     //   _EmissionStrength("_EmissionStrength",Range(0,10)) = 1

        [StyledTexST(_BaseMap)] _Temp_ST_1("_Temp_ST_1",Float) = 0

        //-------------------------------------------------
        //               Planar Shadow Settings 
        //-------------------------------------------------
        [StyledCategory(Planar Shadow Settings,true)]_Category_Colapsable_Planar_Shadow("[ Planar Shadow Cat ]", Float) = 1
        [StyledPassOff(PlanarShadowPass)]_DisablePlanarShadowPass("Planar Shadow Off",Float) = 0
        [Toggle]_3DMax("Z-to-Y", Int) = 1
        [StyledAlignedLeft][StyledField]_ShadowColor("ShadowColor", Color) = (0.1294117,0.1999999,0.2392156,0.572549)
        _HeightOffset("HeightOffset", Range(-5,5)) = 0
        _ShadowFalloff("ShadowFalloff", Range(0,10)) = 0
        _ShadowCutoff("ShadowCutoff", Range(0.0, 1.0)) = 0.85

        //-------------------------------------------------
        //               Vertex Settings 
        //-------------------------------------------------
        [StyledCategory(Vertex Settings,true)]_Category_Colapsable_Vertex("[ Vertex Cat ]", Float) = 1
        [Toggle(_VERTEX_MOVE_ON)]_VertexMove("Open Vertex Move",Float) = 0.0
        [StyledIndentLevelAdd]
        _VertexMoveDist ("Dist", float) = 0.04
        _VertexMoveSpeed ("Speed", float) = 0.2
        _VertexMoveSpeedOffset ("SpeedOffset", float) = 0.2
        [StyledIndentLevelSub]

        //-------------------------------------------------
        //               Season Settings 
        //------------------------------------------------- 
        [StyledCategory(Season Settings,true)]_Category_Colapsable_Season("[ Season Cat ]", Float) = 1
        [Toggle]_Season_Color("Season Color", Float) = 0
        [StyledAlignedLeft][StyledField]_Season_Color_Mixer_Index("Mixer Index",Int) = 0

        [Space(18)]
        [KeywordEnum(NORMAL,GLOBAL_MASK,TEXTURE_MASK)] _Season_Snow("Snow Model",int) = 0

        [HDR]_Obj_Snow_Color("Snow Color", Color) = (1,1,1,1)
        _Obj_Snow_Offset("Snow Offset", Range( 0 , 1)) = 0
        _Obj_Snow_Intnesity("Snow Intensity", Range( 0 , 1)) = 1
        [StyledIfShow(_Season_Snow,0)][StyledVector]_Obj_Snow_BaseColor_Offset("Color Offset",vector) = (0,0,0,0)
        [StyledIfShow(_Season_Snow,2)][StyledTextureSingleLine]_Snow_Texture_Mask("Snow Texture Mask",2D) = "white" {}
        [StyledIfShow(_Season_Snow,2)][StyledKeywordEnum(UV_0,UV_1,UV_2)] _Season_Snow_Texture_Mask_UV("Snow Texture Mask UV",int) = 0

        //-------------------------------------------------
        //               Lighting Settings 
        //-------------------------------------------------
        [StyledCategory(Lighting Settings,true)]_Category_Colapsable_Lighting("[ Lighting Cat ]", Float) = 1
        [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 0
        [ToggleOff] _EnvironmentReflections("Environment Reflections", Float) = 1.0
        [ToggleOff(_RECEIVE_SHADOWS_OFF)]_ReceiveShadows("Receive Shadows", Float) = 0.0
        [StyledPassOff(ShadowCaster)]_DisableShadowCaster("Shadow Caster Off",Float) = 1.0
        [StyledIfShow(_SpecularHighlights,0)]_ReflectStrength("Reflect Strength", Range( 0 , 10)) = 1

        //-------------------------------------------------
        //               Advanced Settings 
        //-------------------------------------------------
        [StyledCategory(Advanced Settings,true)]_Category_Colapsable_Advanced("[ Advanced Cat ]", Float) = 1

        //-------------------------------------------------
        //               Obsolete Properties
        //-------------------------------------------------
        [HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
    }

    SubShader{
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "Lit" "IgnoreProjector" = "True"}
        LOD 1100

        // ForwardLit
        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}

            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            ZTest [_ZTest]
            Cull[_Cull]

            HLSLPROGRAM

            // Debug
            // #pragma enable_d3d11_debug_symbols

            #pragma target 3.0

            //--------------------------------------
            // GPU Instancing
           // #pragma multi_compile_instancing
            //自定义--雾效s
            #pragma multi_compile _ _CUSTOM_HEIGHT_FOG _CUSTOM_WORLD_FOG _CUSTOM_BIRTH_FOG
            #pragma multi_compile _ _CUSTOM_CLOUD
            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _ _SPECGLOSSMAP _SPECULAR_COLOR
            #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _EMISSION
            //不接受阴影
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF

            // -------------------------------------
            // Universal Pipeline keywords
            // #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
    
            // -------------------------------------
            // Unity defined keywords
            
            // #pragma multi_compile _ LIGHTMAP_ON
            // #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            // #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
              #pragma multi_compile _ SHADOWS_SHADOWMASK

            #define LIGHTMAP_ON
            // #define DIRLIGHTMAP_COMBINED
            #define LIGHTMAP_SHADOW_MIXING
          //  #define SHADOWS_SHADOWMASK
            
            #include "../../../ShaderLibrary/CustomLightmapDefine.hlsl"

            // -------------------------------------
            //自定义--雾效
            #pragma multi_compile_fog
            // #pragma multi_compile _ _CUSTOM_HEIGHT_FOG _CUSTOM_WORLD_FOG _CUSTOM_BIRTH_FOG
            
            //自定义--四季
            // #pragma multi_compile _ _SEASON_ON
            // #pragma shader_feature_local_fragment _SEASON_SNOW_NORMAL _SEASON_SNOW_GLOBAL_MASK _SEASON_SNOW_TEXTURE_MASK
            // #pragma shader_feature_local_fragment _SEASON_COLOR_ON
            // #pragma shader_feature_local_fragment _SEASON_SNOW_TEXTURE_MASK_UV_UV_0 _SEASON_SNOW_TEXTURE_MASK_UV_UV_1 _SEASON_SNOW_TEXTURE_MASK_UV_UV_2
            
            // -------------------------------------
            
            #pragma vertex LitPassVertex
            #pragma fragment LitPassLambertFragment_ColorLerp

            #include "Architecture-LOD-Input.hlsl"
            #include "Architecture-LOD-VexColorPass.hlsl"
            ENDHLSL
        }

        // PlanarShadow
        Pass
        {
            Name "PlanarShadow"
            Tags { "LightMode" = "PlanarShadowPass" }

            //用使用模板测试以保证alpha显示正确
            Stencil
            {
                Ref 0
                Comp equal
                Pass incrWrap
                Fail keep
                ZFail keep
            }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite off
            //深度稍微偏移防止阴影与地面穿插
            Offset -1 , 0
            
            HLSLPROGRAM

            // Debug
            // #pragma enable_d3d11_debug_symbols

            // Pragmas
            #pragma target 3.0

            // #pragma multi_compile_instancing

            //自定义--雾效
            #pragma multi_compile_fog
            // #pragma multi_compile _ _CUSTOM_HEIGHT_FOG _CUSTOM_WORLD_FOG _CUSTOM_BIRTH_FOG

            #pragma shader_feature_local_vertex _3DMAX_ON

            #pragma shader_feature_local_fragment _ALPHATEST_ON

            #pragma vertex PlanarShadowVertex
            #pragma fragment PlanarShadowFragment

            #include "Architecture-LOD-Input.hlsl" 
            #include "../../../ShaderLibrary/PlanarShadow/PlanarShadow-Pass.hlsl"

            ENDHLSL
        }

        // CommonTransparentPreDepth
        Pass
        {
            Name "CommonTransparentPreDepth"
            Tags{"LightMode" = "CommonTransparentPreDepth"}

            ZWrite On
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 3.0

            //--------------------------------------
            // GPU Instancing
            // #pragma multi_compile_instancing

            #pragma vertex PreDepthVertex
            #pragma fragment PreDepthFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            #include "Architecture-LOD-Input.hlsl"
            #include "../../../ShaderLibrary/CommonTransparentPreDepth/CommonTransparentPreDepthPass.hlsl"
            ENDHLSL
        }
        
        // ShadowCaster
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 3.0

            //--------------------------------------
            // GPU Instancing
            // #pragma multi_compile_instancing

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Architecture-LOD-Input.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        // Meta
        Pass
        {
            Name "Meta"
            Tags{"LightMode" = "Meta"}

            Cull Off

            HLSLPROGRAM
            #pragma only_renderers d3d11
            #pragma target 3.0

            #pragma vertex UniversalVertexMeta
            #pragma fragment UniversalFragmentMeta

            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            #pragma shader_feature_local_fragment _SPECGLOSSMAP

            #include "Architecture-LOD-Input.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitMetaPass.hlsl"

            ENDHLSL
        }

    }

    FallBack "SLG_Custom/CommonShader/MaterialError"
    CustomEditor "YLib.StyledEditor.StyledMaterial.MaterialCoreGUI"
}
