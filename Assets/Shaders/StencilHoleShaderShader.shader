Shader "Custom/StencilHoleShaderShader"
{
    SubShader
    {
        Tags
        {
            "Queue" = "Geometry-1"
            "RenderType" = "Transparent"
        }

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        Stencil
        {
            Ref 10
            Comp Always
            Pass Replace
        }

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

        
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                return o;
            }
 
            fixed4 frag(v2f i) : SV_Target
            {
                return fixed4(1, 1, 1, 0);
            }

            ENDCG
        }
    }
}
