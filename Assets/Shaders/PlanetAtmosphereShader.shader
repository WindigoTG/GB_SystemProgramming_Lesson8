Shader "Custom/PlanetAtmosphereShader"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _Thickness("AtmoThickness", Range(0,10)) = 0.1
    }

    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Thickness;

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 atmo : TEXCOORD1;
            };

            v2f vert(appdata_full v)
            {
                v2f result;

                float3 forward = normalize(mul((float3x3)unity_CameraToWorld, float3(0, 0, 1)));

                float3 qwer = ObjSpaceViewDir(v.vertex);

                v.vertex.xyz += v.normal * _Thickness;

                float scalar = dot(qwer, v.normal);
                

                result.vertex = UnityObjectToClipPos(v.vertex);
                result.atmo = float2(scalar,scalar);
                result.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return result;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 color;

                color = _Color;

                float value = 1 - i.atmo.x;
                if (value < 0)
                    value = 0;
                color.a = value;

                return color;
            }
                
            ENDCG
        }
    }
}
