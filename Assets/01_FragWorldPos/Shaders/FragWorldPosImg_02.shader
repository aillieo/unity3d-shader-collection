// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Collection/01_FragWorldPos/FragWorldPosImg_02" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader {
		CGINCLUDE
		
		#include "UnityCG.cginc"

		#pragma multi_compile __ _CAM_ORTHO
		
		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		sampler2D _CameraDepthTexture;

		float4x4 _FrustumCornersRay;
		
		struct v2f {
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
			half2 uv_depth : TEXCOORD1;
			float4 interpolatedRay : TEXCOORD2;

			#ifdef _CAM_ORTHO
			float3 camForward: TEXCOORD3;
			#endif

		};
		
		v2f vert(appdata_img v) {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			
			o.uv = v.texcoord;
			o.uv_depth = v.texcoord;
			
			#if UNITY_UV_STARTS_AT_TOP
			if (_MainTex_TexelSize.y < 0)
				o.uv_depth.y = 1 - o.uv_depth.y;
			#endif
			
			int index = 0;
			if (v.texcoord.x < 0.5 && v.texcoord.y < 0.5) {
				index = 0;
			} else if (v.texcoord.x > 0.5 && v.texcoord.y < 0.5) {
				index = 1;
			} else if (v.texcoord.x > 0.5 && v.texcoord.y > 0.5) {
				index = 2;
			} else {
				index = 3;
			}

			#if UNITY_UV_STARTS_AT_TOP
			if (_MainTex_TexelSize.y < 0)
				index = 3 - index;
			#endif
			
			o.interpolatedRay = _FrustumCornersRay[index];

			#ifdef _CAM_ORTHO
			o.camForward = float3(_FrustumCornersRay[0][3],_FrustumCornersRay[1][3],_FrustumCornersRay[2][3]); 
			#endif

			return o;
		}
		
		fixed4 frag(v2f i) : SV_Target {

			float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
			#if UNITY_REVERSED_Z
				d = 1.0f - d;
			#endif

			float linearDepth = LinearEyeDepth(d);
#ifdef _CAM_ORTHO
			float3 worldPos = _WorldSpaceCameraPos + i.camForward * linearDepth + i.interpolatedRay.xyz;
#else
			float3 worldPos = _WorldSpaceCameraPos + linearDepth * i.interpolatedRay.xyz;
#endif
									
			//fixed hasObj = d > 0.999f ? 0 : 1.0f;
			fixed hasObj = step(d,0.999f);

			return fixed4(worldPos.xyz,1.0) * hasObj;
		}
		
		ENDCG
		
		Pass {
			ZTest Always Cull Off ZWrite Off
			     	
			CGPROGRAM  
			
			#pragma vertex vert  
			#pragma fragment frag  
			  
			ENDCG  
		}
	} 
	FallBack Off
}
