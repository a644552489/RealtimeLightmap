#ifndef TREE_MATCAP_PLANARSHADOWPASS_INCLUDED
    #define TREE_MATCAP_PLANARSHADOWPASS_INCLUDED 
    
    #include "./PlanarShadow/PlanarShadow-Pass.hlsl"
    struct tree_appdata
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
        float2 uv3               : TEXCOORD2;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    v2f TreePlanarShadowVertex(tree_appdata v)
    {
        v2f o  = (v2f)0;
        
        UNITY_SETUP_INSTANCE_ID(v); 
        UNITY_TRANSFER_INSTANCE_ID(v, o);

        #ifdef _3DMAX_ON
            float height =  v.vertex.z;
        #else
            float height =  v.vertex.y;
        #endif

        // v.vertex.x += sin(PI * _Time.y * _VertexSpeed  * clamp(height, 0, 1)) * _VertexScale;
        
        #ifndef _VERTEXOFFSETCLOSE_ON
            float offset =  sin(PI * _Time.y * _VertexSpeed  * clamp(height, 0, 1)) * _VertexScale;

            #ifdef _COMBINEVERTEXOFFSET_ON
                v.vertex.x += offset * v.uv3.y;
                #ifdef _3DMAX_ON
                    v.vertex.y -= offset * v.uv3.x;
                #else
                    v.vertex.z -= offset * v.uv3.x;
                #endif
            #else
                v.vertex.x += offset;
            #endif

        #endif

        //得到阴影的世界空间坐标
        float3 shadowPos = ShadowProjectPos(v.vertex);

        o.worldPos = shadowPos;
        //转换到裁切空间
        o.vertex = TransformWorldToHClip(shadowPos);

        o.uv = TRANSFORM_TEX(v.uv, _BaseMap);

        return o;
    }
#endif