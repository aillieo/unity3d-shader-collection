Shader "Collection/04_ModelAlphaBlend/AlphaBlendFresnel" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_Power ("Fresnel Power", Range(1, 3)) = 1
	}
	SubShader {
		Tags {"Queue"="Transparent" 
		"IgnoreProjector"="True" 
		"RenderType"="Transparent"}
		
		Pass { 
			Tags { "LightMode"="Always" }
		
		
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _Power;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
  				fixed3 worldNormal : TEXCOORD1;
  				fixed3 worldViewDir : TEXCOORD2;
			};
			
			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.worldViewDir = UnityWorldSpaceViewDir(worldPos);
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				fixed4 texColor = tex2D(_MainTex, i.uv);
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldViewDir = normalize(i.worldViewDir);
				fixed fresnel = pow(1 - dot(worldViewDir, worldNormal), _Power);
				return fixed4(_Color.rgb * texColor.rgb,saturate(fresnel) * _Color.a);
			}
			
			ENDCG
		}
	} 
	FallBack "Reflective/VertexLit"
}
