#ifndef CUSTOM_CLOUD
#define CUSTOM_CLOUD

	half4 _CloudOffset;
	half2 _CloudSmooth;
	half4 _CloudColor;
	TEXTURE2D(_Custom_Cloud_MaskMap); SAMPLER(sampler_Custom_Cloud_MaskMap);

	float3 SetCloudMask( float3 baseColor, float3 positionWS )
	{
		half2 offset = positionWS.xz * _CloudOffset.z*0.1 + (_Time.yy * _CloudOffset.xy*0.1);
	
	     float mask = SAMPLE_TEXTURE2D(_Custom_Cloud_MaskMap , sampler_Custom_Cloud_MaskMap , offset );
		 mask = smoothstep(_CloudSmooth.x , _CloudSmooth.y , mask);
		half3 col = lerp(baseColor , baseColor * _CloudColor.rgb , mask);
		 return col;
	}

	float3 GetGroudCloud( float3 baseColor , float3 positionWS)
	{
		#ifdef _CUSTOM_CLOUD
			return SetCloudMask( baseColor,positionWS);
		#endif
		return baseColor;
	}
















#endif