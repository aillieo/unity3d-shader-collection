Shader "Collection/12_UIHoles/UIHoles"
{
    Properties
    {
        [PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
        _Radius1("Radius1", Float) = 0.1
        _Radius2("Radius2", Float) = 0.2
        
        // for UI.Mask
        _StencilComp("Stencil Comparison", Float) = 8
        _Stencil("Stencil ID", Float) = 0
        _StencilOp("Stencil Operation", Float) = 0
        _StencilWriteMask("Stencil Write Mask", Float) = 255
        _StencilReadMask("Stencil Read Mask", Float) = 255
        _ColorMask("Color Mask", Float) = 15

    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "PreviewType" = "Plane"
            "CanUseSpriteAtlas" = "True"
        }

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        // for UI.Mask
        Stencil
        {
             Ref[_Stencil]
             Comp[_StencilComp]
             Pass[_StencilOp]
             ReadMask[_StencilReadMask]
             WriteMask[_StencilWriteMask]
        }
        ColorMask[_ColorMask]

        Pass
        {
            CGPROGRAM
            
            #define HOLE_COUNT_MAX 9

            #pragma vertex vert     
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest     

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
                fixed4 color : COLOR;
                half2 texcoord  : TEXCOORD0;
                float2 vertexLocal : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Radius1;
            float _Radius2;
            float4 _Holes[HOLE_COUNT_MAX];
            fixed _HoleCount;
            fixed getHoleValue(float2 vt, float2 holePos);
            
            v2f vert(appdata_t IN)
            {
                v2f OUT;
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.texcoord = IN.texcoord;
#ifdef UNITY_HALF_TEXEL_OFFSET
                OUT.vertex.xy -= (_ScreenParams.zw - 1.0);
#endif
                OUT.color = IN.color;
                OUT.vertexLocal = IN.vertex;
                return OUT;
            }
            
            fixed4 frag(v2f IN) : SV_Target
            {
                fixed holeValue = 1;
                
                for(fixed i = 0; i < _HoleCount; ++ i)
                {
                    holeValue = holeValue * getHoleValue(IN.vertexLocal, _Holes[i].xy);
                }
                
                fixed4 renderTex = tex2D(_MainTex, IN.texcoord) * IN.color;
                renderTex.a *= holeValue;
                
                return renderTex;
            }
            
            fixed getHoleValue(float2 vt, float2 holePos)
            {
                float distSqr = (vt.x - holePos.x)*(vt.x - holePos.x) + (vt.y - holePos.y)*(vt.y - holePos.y);
                float dist = sqrt(distSqr);
                return smoothstep(_Radius1, _Radius2, dist);
            }
            
            ENDCG
        }
    }
    FallBack "UI/Default"
}
