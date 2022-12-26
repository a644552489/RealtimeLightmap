#ifndef WORLD_MINIMAP_NEW_PASS_INCLUDED
    #define WORLD_MINIMAP_NEW_PASS_INCLUDED
    
     half remap(half x, half t1, half t2, half s1, half s2)
    {
        return (x - t1) / (t2 - t1) * (s2 - s1) + s1;
    }

    struct Attributes
    {
        float4 vertex    : POSITION;
        float2 texcoord      : TEXCOORD0;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct Varyings
    {
        float4 vertex   : SV_POSITION;
        float2 texcoord  : TEXCOORD0;
        
        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    };


    // Used in Standard (Simple Lighting) shader
    Varyings Vertex(Attributes input)
    {
        Varyings output = (Varyings)0;

        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_TRANSFER_INSTANCE_ID(input, output);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

        VertexPositionInputs vertexInput = GetVertexPositionInputs(input.vertex.xyz);

        output.texcoord = input.texcoord;
        output.vertex = vertexInput.positionCS;

        return output;
    }

    // Used for StandardSimpleLighting shader
    half4 Fragment(Varyings input) : SV_Target
    {
        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

        if(_IsHide)
            return half4(0, 0, 0, 0);  

        half2 _uv = input.texcoord ;
        //区块数 
        //float cellCount = 33.125; //+(35 / 280);

        half2 dataUv;
        half alpha;

        if(_IsCross)
        {
            //区块删除大小
            float cellSize = 1 / _CellCount;
            float cellSize_half = cellSize * 0.5;
            float uvy = floor(_uv.x  * (_CellCount) ) % 2;
            //区块奇偶
            float sub = uvy == 0 ? 0 : cellSize_half;
            float RevSub = uvy == 0 ? cellSize : cellSize_half;
            //y轴 uv递进
            half NewUVy = saturate(_uv.y - sub);
            float RevUVy = saturate((1 - _uv.y) - RevSub);
            //生成alpha
            half Revalpha = step(0.00001, RevUVy);
            alpha = step(0.00001, NewUVy);
            //删除x轴最后一格
            half alphaY = _uv.x > 1 - cellSize ? 0 : 1;
            alpha = alpha  * alphaY  *  Revalpha;

            _uv.y = NewUVy ;
            //重映射
            float2 ___uv = _uv;
            ___uv.x = remap(_uv.x, 0, 1 - cellSize, 0, 1);
            ___uv.y = remap(_uv.y, 0, 1  -cellSize, 0, 1);
            dataUv = TRANSFORM_TEX(___uv, _DataMap_Color);
        }
        else
        {
            dataUv = TRANSFORM_TEX(input.texcoord, _DataMap_Color);
            alpha = 1;
        }
           

        half4 data_edge = SAMPLE_TEXTURE2D(_DataMap_Edge, sampler_DataMap_Edge, dataUv);
        half4 data_angle = SAMPLE_TEXTURE2D(_DataMap_Angle, sampler_DataMap_Angle, dataUv);
        half4 data_color = SAMPLE_TEXTURE2D(_DataMap_Color, sampler_DataMap_Color, dataUv);
        half4 data_color2 = SAMPLE_TEXTURE2D(_DataMap_Color2, sampler_DataMap_Color2, dataUv);

        uint index = dot(data_edge, uint4(1, 2, 4, 8));
        uint x = index % 4;   
        uint y = floor(index* 0.25);   

        uint index2 = dot(data_angle, uint4(1, 2, 4, 8));
        uint x2 = index2 % 4;
        uint y2 = floor(index2 * 0.25);
        //frac 返回小数部分
        half2 uv = frac(_uv.xy * _CellCount);
        half2 uv_1 = (uv + half2(x , y)) * 0.25;
        half2 uv_2 = (uv + half2(x2 , y2)) * 0.25;

        half shape_edge = SAMPLE_TEXTURE2D(_ShapeMap_Edge, sampler_ShapeMap_Edge, uv_1).r ;
        half shape_angle = SAMPLE_TEXTURE2D(_ShapeMap_Angle, sampler_ShapeMap_Angle, uv_2).r;

        half4 col = lerp(0.1 , data_color2 , (shape_edge + shape_angle) * _ShapeColorStrength) * (1 - step(data_color.a, 0));
        col.a *= alpha;
        return col;


    }

#endif
