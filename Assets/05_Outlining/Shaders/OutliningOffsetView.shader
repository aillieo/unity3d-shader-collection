Shader "Collection/05_Outlining/OutliningOffsetView" {
    Properties{
        _MainTex("Base (RGB)", 2D) = "white" {}
        _OutlineColor("Outline Color", Color) = (1,1,1,1)
        _OutlineWidth("Outline width", Range(0.0, 1.0)) = 0.5
    }
    CGINCLUDE
    #include "UnityCG.cginc"
    struct appdata_t {
        float4 vertex : POSITION;
        float2 texcoord : TEXCOORD0;
        float3 normal : NORMAL;
    };
    struct v2f {
        float4 vertex : SV_POSITION;
        half2 texcoord : TEXCOORD0;
    };
    sampler2D _MainTex;
    float4 _MainTex_ST;
    float _OutlineWidth;
    float4 _OutlineColor;


    ENDCG
    SubShader{

        Tags{
        	"Queue" = "Geometry" 
         	"RenderType" = "Opaque" 
         }

        Pass{
            Stencil
            {
                Ref 1
                Comp Always
                Pass Replace
                ZFail Replace
            }
            ZTest LEqual
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            v2f vert(appdata_t v)
		    {
		        v2f o = (v2f)0;
		        o.vertex = UnityObjectToClipPos(v.vertex);
		        o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
		        return o;
		    }
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.texcoord);
                return col;
            }
            ENDCG
        }
        Pass{
            ZTest Always //Greater
            ZWrite Off
            Stencil{
                Ref 1
                Comp NotEqual
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            v2f vert(appdata_t v)
		    {
		        v2f o = (v2f)0;
				float4 viewPos = mul(UNITY_MATRIX_MV, v.vertex);
				float3 viewNorm = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);  
				float3 offset = normalize(viewNorm) * _OutlineWidth;
				viewPos.xyz += offset;
				o.vertex = mul(UNITY_MATRIX_P, viewPos);
		        return o;
		    }
            fixed4 frag(v2f i) :SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }
    }
}