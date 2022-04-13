Shader "Custom/PlanetShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Height("Height", Range(-1,1)) = 0
        _Mountains("Mountains", Range(0, 0.45)) = 0.25
        _Oceans("Oceans", Range(0, 0.45)) = 0.25
        _Seed("Seed", Range(0,10000)) = 10
        _MountCol("Mountains Color", Color) = (1,1,1,1)
        _PlainCol("Plains Color", Color) = (1,1,1,1)
        _OceanCol("Oceans Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags {"RenderType" = "Opaque" }
        LOD 200
    
        Pass
        {
            Tags { "LightMode" = "UniversalForward" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"


            #define MAX_VISIBLE_LIGHTS 16

            CBUFFER_START(_LightBuffer)
                float4 _VisibleLightColors[MAX_VISIBLE_LIGHTS];
                float4 _VisibleLightDirectionsOrPositions[MAX_VISIBLE_LIGHTS];
                float4 _VisibleLightAttenuations[MAX_VISIBLE_LIGHTS];
                float4 _VisibleLightSpotDirections[MAX_VISIBLE_LIGHTS];
            CBUFFER_END


            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _Height;
            float _Seed;
            float _Mountains;
            float _Oceans;
            fixed4 _MountCol;
            fixed4 _PlainCol;
            fixed4 _OceanCol;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                float4 normal: NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCPPDR0;
                float4 vertex : SV_POSITION;
                float2 height : TEXCPPDR1;
                float3 normal : TEXCOORD2;
                float3 worldPos : TEXCOORD3;
            };

            float hash(float2 st)
            {
                return frac(sin(dot(st.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float noise(float2 p, float size)
            {
                float result = 0;
                p *= size;
                float2 i = floor(p + _Seed);
                float2 f = frac(p + _Seed / 739);
                float2 e = float2(0, 1);
                float z0 = hash((i + e.xx) % size);
                float z1 = hash((i + e.yx) % size);
                float z2 = hash((i + e.xy) % size);
                float z3 = hash((i + e.yy) % size);
                float2 u = smoothstep(0, 1, f);
                result = lerp(z0, z1, u.x) + (z2 - z0) * u.y * (1.0 - u.x) + (z3 - z1) *
                u.x * u.y;
                return result;
            }

            float3 DiffuseLight(int index, float3 normal, float3 worldPos)
            {
                float3 lightColor = _VisibleLightColors[index].rgb;
                float4 lightPositionOrDirection = _VisibleLightDirectionsOrPositions[index];
                float4 lightAttenuation = _VisibleLightAttenuations[index];
                float3 spotDirection = _VisibleLightSpotDirections[index].xyz;

                float3 lightVector = lightPositionOrDirection.xyz - worldPos * lightPositionOrDirection.w;
                float3 lightDirection = normalize(lightVector);
                float diffuse = saturate(dot(normal, lightDirection));

                float rangeFade = dot(lightVector, lightVector) * lightAttenuation.x;
                rangeFade = saturate(1.0 - rangeFade * rangeFade);
                rangeFade *= rangeFade;

                float spotFade = dot(spotDirection, lightDirection);
                spotFade = saturate(spotFade * lightAttenuation.z + lightAttenuation.w);
                spotFade *= spotFade;

                float distanceSqr = max(dot(lightVector, lightVector), 0.00001);
                //diffuse *= spotFade;// *rangeFade / distanceSqr;

                return diffuse * lightColor;
            }

            v2f vert(appdata v)
            {
                v2f o;

                UNITY_INITIALIZE_OUTPUT(v2f, o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                float height = noise(v.uv, 5) * 0.75 + noise(v.uv, 30) * 0.125 + noise(v.uv, 50) * 0.125;
                o.height.x = height + _Height;


                o.normal = mul((float3x3)UNITY_MATRIX_M, v.normal);
                float4 worldPos = mul(UNITY_MATRIX_M, float4(v.vertex.xyz, 1.0));
                o.worldPos = worldPos.xyz;


                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                i.normal = normalize(i.normal);


                fixed4 color = tex2D(_MainTex, i.uv) * _Color;
                float height = i.height.x;

                if (height < _Oceans)
                {
                    color *= _OceanCol;
                }
                else if (height < 1 - _Mountains)
                {
                    color *= _PlainCol;
                }
                else
                {
                    color *= _MountCol;
                }

                //return color * i.diff;

                float3 diffuseLight = 0;
                for (int j = 0; j < MAX_VISIBLE_LIGHTS; j++) 
                {
                    diffuseLight += DiffuseLight(j, i.normal, i.worldPos);
                }

                return color * float4(diffuseLight, 1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
