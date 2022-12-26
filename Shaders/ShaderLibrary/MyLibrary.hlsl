#ifndef MY_LIBRARY_INCLUDED
    #define MY_LIBRARY_INCLUDED

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"

    half remap(half x, half t1, half t2, half s1, half s2)
    {
        return (x - t1) / (t2 - t1) * (s2 - s1) + s1;
    }
    
    float4 ComputeClipSpacePosition1(float2 positionNDC, float deviceDepth)
    {
        float4 positionCS = float4(positionNDC * 2.0 - 1.0, deviceDepth, 1.0);

        // // 视角旋转就有问题 鬼知道为什么这样
        // #if UNITY_UV_STARTS_AT_TOP
        //     // Our world space, view space, screen space and NDC space are Y-up.
        //     // Our clip space is flipped upside-down due to poor legacy Unity design.
        //     // The flip is baked into the projection matrix, so we only have to flip
        //     // manually when going from CS to NDC and back.
        //     positionCS.y = -positionCS.y;
        // #endif

        return positionCS;
    }

    float3 ComputeViewSpacePosition1(float2 positionNDC, float deviceDepth, float4x4 invProjMatrix)
    {
        float4 positionCS = ComputeClipSpacePosition1(positionNDC, deviceDepth);
        float4 positionVS = mul(invProjMatrix, positionCS);
        // The view space uses a right-handed coordinate system.
        positionVS.z = -positionVS.z;
        return positionVS.xyz / positionVS.w;
    }

    float4 ReconstructWorldPositionFromScreenPos(float4 screenPos)
    {
        float2 uv = screenPos.xy / screenPos.w;
        float depth = SampleSceneDepth(uv);

        #if UNITY_REVERSED_Z
            depth = 1.0 - depth;
        #endif

        depth = 2.0 * depth - 1.0;

        float3 viewPos = ComputeViewSpacePosition1(uv, depth, unity_CameraInvProjection);
        float4 worldPos = float4(mul(unity_CameraToWorld, float4(viewPos, 1.0)).xyz, 1.0);

        return worldPos;
    }

    float GetFresnel(float3 normalWS,float3 viewDirectionWS)
    {
        half NoV = saturate(dot(normalWS, viewDirectionWS));
        return Pow4(1.0 - NoV);
    }

    float GetFresnel(float3 normalWS,float3 viewDirectionWS,float power)
    {
        half NoV = saturate(dot(normalWS, viewDirectionWS));
        return pow(1.0 - NoV,power);
    }

    inline float4 ComputeGrabScreenPos( float4 pos )
    {
        #if UNITY_UV_STARTS_AT_TOP
            float scale = -1.0;
        #else
            float scale = 1.0;
        #endif
        float4 o = pos;
        o.y = pos.w * 0.5f;
        o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
        return o;
    }

    //https://www.shadertoy.com/view/XdXGW8
    float2 GradientNoiseDir (float2 x)
    {
        const float2 k = float2(0.3183099, 0.3678794);
        x = x * k + k.yx;
        return -1.0 + 2.0 * frac (16.0 * k * frac (x.x * x.y * (x.x + x.y)));
    }

    float GradientNoise (float2 UV, float Scale)
    {
        float2 p = UV * Scale;
        float2 i = floor (p);
        float2 f = frac (p);
        float2 u = f * f * (3.0 - 2.0 * f);
        return lerp (lerp (dot (GradientNoiseDir (i + float2(0.0, 0.0)), f - float2(0.0, 0.0)),
        dot (GradientNoiseDir (i + float2(1.0, 0.0)), f - float2(1.0, 0.0)), u.x),
        lerp (dot (GradientNoiseDir (i + float2(0.0, 1.0)), f - float2(0.0, 1.0)),
        dot (GradientNoiseDir (i + float2(1.0, 1.0)), f - float2(1.0, 1.0)), u.x), u.y);
    }

    half3 GetGrayColor(half3 color)
    {
        #ifdef GRAY_COLOR_ON
            return dot(color.rgb, half3(.222,.707,.071));
        #else
            return color;
        #endif
    }
    
    half3 OverlayBlend(half3 a,half3 b,half c)
    {
        return lerp(a,lerp(1 - 2 * (1 - a) * (1 - b), 2 * a * b, step(a, 0.5)),c);
    }
    
#endif
