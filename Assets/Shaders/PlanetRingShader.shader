Shader "Custom/PlanetRingShader"
{
    Properties
    {
        _MainTex("Sprite Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _Transparency("Transparency", Range(0.5, 1)) = 0.75
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
        }

        Stencil
        {
            Ref 10
            Comp NotEqual
        }

        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                float2 originalTexcoord : TEXCOORD2;
            };

            sampler2D _MainTex;
            fixed4 _Color;
            float4 _MainTex_ST;
            float _Transparency;

            float circleDelta(float2 texcoord) 
            {
                float x = (2 * (texcoord.x - 0.5));
                float y = (2 * (texcoord.y - 0.5));
                float value = x * x + y * y;

                return smoothstep(1.0, 0.9999, value);
            }

            v2f vert(appdata_full v)
            {
                v2f result;

                result.worldPosition = v.vertex;
                result.vertex = UnityObjectToClipPos(result.worldPosition);
                result.originalTexcoord = v.texcoord;
                result.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

                result.color = v.color * _Color;
                return result;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                float2 size = float2(1 , 1);
                float2 halfSize = size * 0.5;
                float2 center = float2(0.5, 0.5);
                half4 color = tex2D(_MainTex, IN.texcoord * size + center - halfSize) * IN.color;

                color.a *= circleDelta(IN.texcoord) * _Transparency;

                return color;
            }

        ENDCG
        }
    }
}
