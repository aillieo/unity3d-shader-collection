// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/01_FragWorldPos/FragWorldPos" {
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
			float3 worldPos : TEXCOORD0;
		};
		
		v2f vert(appdata_img v) {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.worldPos = mul(unity_ObjectToWorld ,v.vertex);
			return o;
		}
		
		fixed4 frag(v2f i) : SV_Target {
		
			//return fixed4(worldPos.rgb, 1.0);
			return fixed4(i.worldPos.xyz,1.0);
		}
		
		ENDCG
		
		Pass {      
			//ZTest Always 
			Cull Back 
			//ZWrite On
			    	
			CGPROGRAM  
			
			#pragma vertex vert  
			#pragma fragment frag  
			  
			ENDCG  
		}
	} 
	FallBack Off
}
