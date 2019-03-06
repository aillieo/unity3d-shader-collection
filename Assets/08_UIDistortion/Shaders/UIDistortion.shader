Shader "Collection/08_UIDistortion/UIDistortion"
{
    Properties
    {
        [PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
        _Color("Tint", Color) = (1,1,1,1)
        _Magnitude("Distortion Magnitude", Float) = 2
        _TimeFrequency("Distortion Frequency Time", Float) = 5
        _WaveFrequency("Distortion Frequency Wave", Float) = 10


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
                    fixed4 color : COLOR;
                    half2 texcoord  : TEXCOORD0;
                };

                sampler2D _MainTex;
                float4 _MainTex_ST;
                fixed4 _Color;
                fixed4 _TextureSampleAdd;
                float _Magnitude;
                float _TimeFrequency;
                float _WaveFrequency;
                float4 _MainTex_TexelSize;

                v2f vert(appdata_t IN)
                {
                    v2f OUT;
                    OUT.vertex = UnityObjectToClipPos(IN.vertex);
                    OUT.texcoord = IN.texcoord;
    #ifdef UNITY_HALF_TEXEL_OFFSET
                    OUT.vertex.xy -= (_ScreenParams.zw - 1.0);
    #endif
                    OUT.color = IN.color * _Color;
                    return OUT;
                }



                fixed4 frag(v2f IN) : SV_Target
                {
                    float timeOffset = _TimeFrequency * _Time.y;

                    fixed2 offset = fixed2(
                        sin(timeOffset + IN.texcoord.y * _WaveFrequency) * _MainTex_TexelSize.x,
                        sin(timeOffset + IN.texcoord.x * _WaveFrequency) * _MainTex_TexelSize.y
                    ) * _Magnitude;

                    fixed4 renderTex = (tex2D(_MainTex, IN.texcoord + offset) + _TextureSampleAdd) * IN.color;;

                    return renderTex;
                }
                ENDCG
            }
        }
        FallBack "UI/Default"
}

