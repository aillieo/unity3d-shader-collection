// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Collection/02_ShowVerts/ShowVerts"
{
	Properties
	{
	}

	SubShader
	{
		Pass
		{
		
			Tags{ "RenderType" = "Opaque" }

			CGPROGRAM
			#pragma target 5.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
			#include "UnityCG.cginc" 

			struct v2g
			{
				float4 pos     : POSITION;
				float3 normal  : NORMAL;
				float2 tex0    : TEXCOORD0;
			};

			struct g2f
			{
				float4 pos     : POSITION;
				float2 tex0    : TEXCOORD0;
			};


			v2g vert(appdata_base v)
			{
				v2g output = (v2g)0;

				output.pos = v.vertex;
				output.normal = v.normal;
				output.tex0 = float2(0, 0);
				return output;
			}

			[maxvertexcount(11)]
			void geom(triangle v2g p[3], inout PointStream<g2f> triStream)
			{
				for (int i = 0; i < 3; i++)
				{
					float4 v = float4(p[i].pos.x,p[i].pos.y,p[i].pos.z,1.0f);
					g2f pIn;
					pIn.pos = UnityObjectToClipPos(v);
					pIn.tex0 = float2(0.0f, 0.0f);
					triStream.Append(pIn);
				}
			}

			float4 frag(g2f input) : SV_Target
			{
				return float4(1,1,1,1);
			}
			
			ENDCG
		}
	}
}