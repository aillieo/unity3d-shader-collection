Shader "Collection/03_RaderImage/RaderImage"   
{     
    Properties     
    {     
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		[PerRendererData] _AlphaTex("Sprite Alpha Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)  

		// for UI.Mask
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        _ColorMask ("Color Mask", Float) = 15
		


		//左右两个值
		_ValueStart("ValueStart", Range(0,1)) = 1.0
		_ValueEnd("ValueEnd", Range(0,1)) = 1.0

		//起始角度和持续的角度
		_AngleStart("AngleStart",Float) = 0
		_AngleRange("AngleRange", Range(1,179)) = 60


		//内侧透明度
		_InnerAlpha("InnerAlpha",Range(0,1)) = 0.5
		//外线框厚度
		_EdgeThickness("EdgeThickness",Range(0,0.5)) = 0.1
		
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
                float2 texcoord : TEXCOORD0;     
                float2 position : TEXCOORD1;     // 配合 PositionAsUV1
            };     
     
            struct v2f     
            {     
                float4 vertex   : SV_POSITION;     
                fixed4 color    : COLOR;     
                half2 texcoord  : TEXCOORD0;
				half  edge      : TEXCOORD1;	// 存储到edge的距离
            };
               
            sampler2D _MainTex;
			sampler2D _AlphaTex;
            fixed4 _Color;     



			half _ValueStart;
			half _ValueEnd;
			float _AngleRange;
			float _AngleStart;

            v2f vert(appdata_t IN)     
            {

				float AngleEnd = _AngleStart + _AngleRange;
				half edge = 0.0;
				
				if(IN.texcoord.x > 0.5f && IN.texcoord.y < 0.5f)
				{
					// 右下角
					IN.vertex.x -= IN.position.x;
					IN.vertex.x += (IN.position.x * cos(radians(_AngleStart)))*_ValueStart;
					IN.vertex.y += sin(radians(_AngleStart)) * IN.position.x * _ValueStart;
				}
				else if(IN.texcoord.x < 0.5f && IN.texcoord.y > 0.5f)
				{
					// 左上角
					IN.vertex.y -= IN.position.y;
					IN.vertex.x += (IN.position.y * cos(radians(AngleEnd)))*_ValueEnd;
					IN.vertex.y += sin(radians(AngleEnd)) * IN.position.y * _ValueEnd;
					
				}
				else if(IN.texcoord.x > 0.5f && IN.texcoord.y > 0.5f)
				{
					// 左下 作为基准
					float2 lb = IN.vertex - IN.position;

					// 左上
					float2 lt = lb;
					lt.x += (IN.position.y * cos(radians(AngleEnd)))*_ValueEnd;
					lt.y += sin(radians(AngleEnd)) * IN.position.y * _ValueEnd;
					
					// 右下
					float2 rb = lb;
					rb.x += (IN.position.x * cos(radians(_AngleStart)))*_ValueStart;
					rb.y += sin(radians(_AngleStart)) * IN.position.x * _ValueStart;

					// 右上是中点
					IN.vertex.xy = 0.5f * (lt + rb);
				}
				else
				{
					// 只剩左下角了
					// 求点到对边距离的话 计算量略大 就近似处理了
					edge = _ValueStart * _ValueEnd;
				}


                v2f OUT;     
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.texcoord = IN.texcoord;     
#ifdef UNITY_HALF_TEXEL_OFFSET     
                OUT.vertex.xy -= (_ScreenParams.zw-1.0);     
#endif     

                OUT.color = IN.color * _Color;     
				OUT.edge = edge;
                return OUT;  
            }  
     



			float _InnerAlpha;
			float _EdgeThickness;

            fixed4 frag(v2f IN) : SV_Target     
            {     

				fixed4 alphaTex = tex2D(_AlphaTex, IN.texcoord);
                
				fixed4 renderTex = tex2D(_MainTex, IN.texcoord);
						
				fixed3 finalColor = renderTex * IN.color;

				// float smoothstep(float start, float end, float parameter)
				half alpha = _InnerAlpha + (1 - _InnerAlpha) * smoothstep( 1.0 - _EdgeThickness, 1.0, 1.0 - IN.edge);

				return fixed4(finalColor, alpha * alphaTex.r * renderTex.a);

            }     
            ENDCG     
        }     
    }     
}