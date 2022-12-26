#ifndef MAPBLOCK_INSERT
	#define MAPBLOCK_INSERT

	
            CBUFFER_START(UnityPerMateial)
    
             float4 _BlockData_Scale;
            CBUFFER_END

         TEXTURE2D(_BlockData_Map) ; SAMPLER(sampler_BlockData_Map);

         half3 SetBlockMap(half3 posWS)
         {
             float2 SetUV = posWS.xz * (1.0 /_BlockData_Scale.xy) + _BlockData_Scale.zw;
             float3 block = SAMPLE_TEXTURE2D(_BlockData_Map , sampler_BlockData_Map ,SetUV).rgb;
     
             return block;
         }








#endif