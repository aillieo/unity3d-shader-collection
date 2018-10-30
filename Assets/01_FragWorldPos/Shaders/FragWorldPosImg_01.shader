// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
Shader "Collection/01_FragWorldPos/FragWorldPosImg_01" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader {
		CGINCLUDE
		
		#include "UnityCG.cginc"
		
		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		sampler2D _CameraDepthTexture;
		
		float4x4 _VP_Inverse;

		struct v2f {
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
			half2 uv_depth : TEXCOORD1;
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
			
			return o;
		}
		
		fixed4 frag(v2f i) : SV_Target {
			
			// Get the depth buffer value at this pixel.
			float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
			#if UNITY_REVERSED_Z
				d = 1.0f - d;
			#endif

			// H is the viewport position at this pixel in the range -1 to 1.
			float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1);
			// 这里的H是NDC坐标系下的坐标 x y z都是 [-1,1]的范围

			// Transform by the view-projection inverse.
			float4 D = mul(_VP_Inverse, H);
			// MVP的逆变换 左乘VP的逆矩阵 变回到世界坐标

			// Divide by w to get the world position. 
			float4 worldPos = D / D.w;
			
			//fixed hasObj = d > 0.999f ? 0 : 1.0f;
			fixed hasObj = step(d,0.999f);

			return fixed4(worldPos.rgb, 1.0) * hasObj;
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
