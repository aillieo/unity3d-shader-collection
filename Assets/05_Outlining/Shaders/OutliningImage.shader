// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Collection/05_Outlining/OutliningImage" 
{     
    Properties     
    {     
        _MainTex("Base (RGB)", 2D) = "white" {}
        _OutlineColor("Outline Color", Color) = (1,1,1,1)
        _OutlineWidth("Outline width", Range(0.0, 3.0)) = 0.5
        _Color ("Tint", Color) = (1,1,1,1)  


		// for UI.Mask
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        _ColorMask ("Color Mask", Float) = 15
		
	}     
     
    SubShader     
    {     
        Tags     
        {      
            "Queue"="Transparent"      
            "IgnoreProjector"="True"      
            "RenderType"="Transparent"      
            "PreviewType"="Plane"     
            "CanUseSpriteAtlas"="True"     
        }     

        Blend SrcAlpha OneMinusSrcAlpha  
		ZWrite Off
		
		// for UI.Mask
        Stencil
        {
             Ref [_Stencil]
             Comp [_StencilComp]
             Pass [_StencilOp] 
             ReadMask [_StencilReadMask]
             WriteMask [_StencilWriteMask]
        }
        ColorMask [_ColorMask]

        Pass     
        {     
            CGPROGRAM     
            #pragma vertex vert     
            #pragma fragment frag     
            #include "UnityCG.cginc"     
                 
            struct appdata_t     
            {     
                float4 vertex   : POSITION;     
                float4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
            };     
     
            struct v2f     
            {     
                float4 vertex   : SV_POSITION;     
                fixed4 color    : COLOR;     
                half2 texcoord  : TEXCOORD0;
			};
               
            sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;     
			float _OutlineWidth;
			float4 _OutlineColor;
			float4 _MainTex_TexelSize;

            v2f vert(appdata_t IN)     
            {
                v2f OUT;
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
#ifdef UNITY_HALF_TEXEL_OFFSET
                OUT.vertex.xy -= (_ScreenParams.zw-1.0);
#endif
                OUT.color = IN.color * _Color;
                return OUT;  
            }
     


            fixed4 frag(v2f IN) : SV_Target     
            {     
				fixed4 renderTex = tex2D(_MainTex, IN.texcoord);

				float2 radius = _MainTex_TexelSize.xy * _OutlineWidth;
				float4 accum = float4(0,0,0,0);
    
				accum += tex2D(_MainTex, IN.texcoord + radius * float2(-1,-1));
				accum += tex2D(_MainTex, IN.texcoord + radius * float2( 1,-1));
				accum += tex2D(_MainTex, IN.texcoord + radius * float2(-1, 1));
				accum += tex2D(_MainTex, IN.texcoord + radius * float2( 1, 1));
				
				accum += tex2D(_MainTex, IN.texcoord + radius * float2(0,1.414));
				accum += tex2D(_MainTex, IN.texcoord + radius * float2(0,-1.414));
				accum += tex2D(_MainTex, IN.texcoord + radius * float2(1.414,0));
				accum += tex2D(_MainTex, IN.texcoord + radius * float2(-1.414,0));

				accum = _OutlineColor * step(1.0, accum.a);
    
				return fixed4(renderTex.a * renderTex.rgb + (1-renderTex.a) * accum.rgb,accum.a);
            }     
            ENDCG     
        }     
    }     
}
