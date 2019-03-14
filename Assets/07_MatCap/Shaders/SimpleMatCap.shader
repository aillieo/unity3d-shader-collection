Shader "Collection/07_MatCap/SimpleMatCap" {
	Properties{
		_MatCapImage("MatCapImage", 2D) = "white" {}
	}

	Subshader{
		Tags {
			"RenderType" = "Opaque" 
		}

		Pass {
				
			Tags { "LightMode" = "Always" }

			CGPROGRAM

			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag

			struct v2f {
				float4 pos : SV_POSITION;
				float2 normalInView : TEXCOORD1;
			};

			v2f vert(appdata_tan v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				// normal in view space
				// o.normalInView.x = mul(UNITY_MATRIX_IT_MV[0], v.normal);
				// o.normalInView.y = mul(UNITY_MATRIX_IT_MV[1], v.normal);
				o.normalInView.x = dot(normalize(UNITY_MATRIX_IT_MV[0]), normalize(v.normal));
				o.normalInView.y = dot(normalize(UNITY_MATRIX_IT_MV[1]), normalize(v.normal));
				
				// [-1,1]  to  [0,1]
				o.normalInView = o.normalInView * 0.5 + 0.5;
				return o;
			}

			uniform sampler2D _MatCapImage;

			float4 frag(v2f i) : COLOR
			{
				return tex2D(_MatCapImage, i.normalInView);
			}

			ENDCG
		}
	}
}
