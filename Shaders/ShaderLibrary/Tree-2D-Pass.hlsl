#ifndef TREE_MATCAP_PASS_INCLUDED
    #define TREE_MATCAP_PASS_INCLUDED

    struct Attributes
    {
        float4 positionOS       : POSITION;
        float2 uv               : TEXCOORD0;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f {
        float4 vertex : SV_POSITION;
        float2 uv : TEXCOORD0;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    v2f Vertex(Attributes input)
    {
        v2f output = (v2f)0;

        UNITY_SETUP_INSTANCE_ID(input); 
        UNITY_TRANSFER_INSTANCE_ID(input, output);

        #ifdef _3DMAX_ON
            float height =  input.positionOS.z;
        #else
            float height =  input.positionOS.y;
        #endif

        float4 worldPos = mul(unity_ObjectToWorld, float4(0,0,0,1));
        float3 R = UNITY_MATRIX_IT_MV[0].xyz;
        float3 U = UNITY_MATRIX_IT_MV[1].xyz;
        worldPos.xyz += R * input.positionOS.x * _BBSizePos.x + U * height * _BBSizePos.y;
        worldPos.xy += _BBSizePos.zw;
        output.vertex = mul(UNITY_MATRIX_VP, worldPos);
        
        output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
        return output;
    }

    half4 Fragment(v2f i) : SV_Target {
        half4 col = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv );
        clip(col.a - _Culloff);
        return col;
    }
    
#endif

