Shader "Collection/09_SimpleLighting/SimpleLighting"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}

        [Header(Ambient)]
        _Ambient("Ambient", Range(0., 1.)) = 0.1
        _AmbientColor("Ambient color", color) = (1., 1., 1., 1.)

        [Header(Diffuse)]
        _Diffuse("Diffuse", Range(0., 1.)) = 1.
        _DiffuseColor("Color", color) = (1., 1., 1., 1.)

        [Header(Specular)]
        [Toggle] _Specular("Enabled?", Float) = 0.
        _Gloss("Gloss", Range(0.1, 100)) = 1.
        _SpecularColor("Specular color", color) = (1., 1., 1., 1.)

        [Header(Emission)]
        _EmissionTex("Emission texture", 2D) = "gray" {}
        _EmissionIntensity("Intensity", float) = 0.
        [HDR]_EmissionColor("Color", color) = (1., 1., 1., 1.)

        [Header(Lighting per frag)]
        [Toggle] _Lighting_Per_Frag("Enabled?", Float) = 1.
    }

    SubShader
    {
        Pass
        {
            Tags { "RenderType" = "Opaque" "Queue" = "Geometry" "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature __ _SPECULAR_ON _LIGHTING_PER_FRAG_ON

            #include "UnityCG.cginc"

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
#if _LIGHTING_PER_FRAG_ON
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
#else
                fixed4 light : COLOR0;
#endif
            };
            
            // Ambient
            fixed _Ambient;
            fixed4 _AmbientColor;

            // Diffuse
            sampler2D _MainTex;
            fixed _Diffuse;
            fixed4 _DiffuseColor;

            // Specular
            fixed _Gloss;
            fixed4 _SpecularColor;

            // Emission
            sampler2D _EmissionTex;
            fixed4 _EmissionColor;
            fixed _EmissionIntensity;

            fixed4 _LightColor0;

            fixed4 ambient()
            {
                // return UNITY_LIGHTMODEL_AMBIENT
                return _Ambient * _AmbientColor;
            }

            fixed4 diffuse(float3 worldNormal, float3 lightDir)
            {
                fixed4 NdotL = saturate(dot(worldNormal, lightDir) * _LightColor0);
                fixed4 dif = NdotL * _Diffuse * _LightColor0 * _DiffuseColor;
                return dif;
            }

#if _SPECULAR_ON
            fixed4 specular(float3 lightDir, float3 viewDir, float3 worldNormal)
            {
                // Blinn-phong
                float3 HalfVector = normalize(lightDir + viewDir);
                float NdotH = saturate(dot(worldNormal, HalfVector));
                fixed4 spec = pow(NdotH, _Gloss) * _LightColor0 * _SpecularColor;
                return spec;
            }
#endif

            fixed4 emission(float2 uv)
            {
                return tex2D(_EmissionTex, uv).r * _EmissionColor * _EmissionIntensity;
            }

            v2f vert(appdata_base v)
            {
                v2f o;

                // World position
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);

                // Normal in WorldSpace
                float3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

                // Clip position
                o.pos = mul(UNITY_MATRIX_VP, worldPos);

                // Texcoord
                o.uv = v.texcoord;

#if _LIGHTING_PER_FRAG_ON
                o.worldPos = worldPos.xyz;
                o.worldNormal = worldNormal;
#else
                // Light direction
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                // Camera direction
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos.xyz);

                // Ambient
                fixed4 amb = ambient();

                // Diffuse
                fixed4 dif = diffuse(worldNormal, lightDir);

                o.light = dif + amb;

                // Specular
#if _SPECULAR_ON
                fixed4 spec = specular(lightDir, viewDir, worldNormal);
                o.light += spec; 
#endif

#endif
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 c = tex2D(_MainTex, i.uv);
#if _LIGHTING_PER_FRAG_ON
                // Light direction
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                // Camera direction
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

                float3 worldNormal = normalize(i.worldNormal);

                // Ambient
                fixed4 amb = ambient();

                // Diffuse
                fixed4 dif = diffuse(worldNormal, lightDir);

                fixed4 light = dif + amb;

                // Specular
#if _SPECULAR_ON
                fixed4 spec = specular(lightDir, viewDir, worldNormal);
                light += spec;
#endif

                c.rgb *= light.rgb;
#else
                c.rgb *= i.light;
#endif

                // Emission
                fixed4 emi = emission(i.uv);

                c.rgb += emi.rgb;
                return c;
            }
            ENDCG
        }
    }
}
