#ifndef TREE_MATCAP_PASS_INCLUDED
    #define TREE_MATCAP_PASS_INCLUDED

    struct Attributes
    {
        float4 positionOS       : POSITION;
        float2 uv               : TEXCOORD0;
        float2 uv2               : TEXCOORD1;
        float2 uv3               : TEXCOORD2;
        float3 normalOS     : NORMAL;
        float4 color             : COLOR;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct Varyings
    {
        float4 uv        : TEXCOORD0;
        float4 vertex : SV_POSITION;
        float2 MatCapCoords : TEXCOORD1;
        float3 worldPos : TEXCOORD2;
        float height : TEXCOORD3;
        float3 normalWS:TEXCOORD4;

        UNITY_VERTEX_INPUT_INSTANCE_ID
    };


    Varyings Vertex(Attributes input)
    {
        Varyings output = (Varyings)0;

        UNITY_SETUP_INSTANCE_ID(input); 
        UNITY_TRANSFER_INSTANCE_ID(input, output);

        #ifdef _3DMAX_ON
            float height =  input.positionOS.z;
        #else
            float height =  input.positionOS.y;
        #endif

        #ifndef _VERTEXOFFSETCLOSE_ON
            float offset =  sin(PI * _Time.y * _VertexSpeed  * clamp(height, 0, 1)) * _VertexScale;

            #ifdef _COMBINEVERTEXOFFSET_ON
                input.positionOS.x += offset * input.uv3.y;
                #ifdef _3DMAX_ON
                    input.positionOS.y -= offset * input.uv3.x;
                #else
                    input.positionOS.z -= offset * input.uv3.x;
                #endif
            #else
                input.positionOS.x += offset;
            #endif
        #endif

        VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
        output.vertex = vertexInput.positionCS;
        output.worldPos = vertexInput.positionWS;

        output.uv.xy = TRANSFORM_TEX(input.uv, _BaseMap);
        output.uv.zw = TRANSFORM_TEX(input.uv2, _BaseMap);
        
        output.normalWS = TransformObjectToWorldNormal(input.normalOS);
        // MatCap坐标准备：将法线从模型空间转换到观察空间，存储于TEXCOORD1的后两个纹理坐标zw
        output.MatCapCoords.x = dot(normalize(UNITY_MATRIX_IT_MV[0].xyz), normalize(input.normalOS));
        output.MatCapCoords.y = dot(normalize(UNITY_MATRIX_IT_MV[1].xyz), normalize(input.normalOS));
        // 归一化的法线值区间[-1,1]转换到适用于纹理的区间[0,1]
        output.MatCapCoords.xy = output.MatCapCoords.xy * 0.5 + 0.5;
        
        output.height = height;

        return output;
    }

    half4 Fragment(Varyings input) : SV_Target 
    {
        UNITY_SETUP_INSTANCE_ID(input);

        half4 uv = input.uv;
        uv.xy += _OffsetUV.xy;
        half4 texColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv.xy );
        half3 color = texColor.rgb * _BaseColor.rgb;
        half alpha = texColor.a *  _BaseColor.a;

        AlphaDiscard(alpha, _Cutout);

        #ifdef _AO_MAP_ON
            half ao = (1- SAMPLE_TEXTURE2D(_AoMap, sampler_AoMap, uv.zw).r) * _AoStrength;
            color = OverlayBlend(color,_AoColor.rgb,ao);
        #endif

        #ifdef _MAT_CAP_ON
            //从提供的MatCap纹理中，提取出对应光照信息
            float3 matCapColor = SAMPLE_TEXTURE2D(_MatCap, sampler_MatCap,input.MatCapCoords.xy).rgb;
            color = saturate(color * pow(matCapColor,_MatCapPow) * _MatCapStrength) ;
        #endif

        float height = smoothstep(_HeightLit.x,_HeightLit.x+_HeightLit.y,input.height);

        color = lerp(clamp(_HeightLitColor.rgb * color,0,1),color,height);

        return half4(color, alpha);
    }
    
#endif

