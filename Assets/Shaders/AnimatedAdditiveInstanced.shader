Shader "Unlit/AnimatedAdditiveInstanced"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Main Color", Color) = (1,1,1,1)
        _LightIntensity ("Light Intensity", float) = 1

        [ShowAsVector2] _Splits ("Splits", Vector) = (5,5,3,5)
        _Frame ("Frame", Float) = 0
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType" = "Plane"}
        ColorMask RGB
        Lighting Off ZWrite Off
        
        Pass
        {
            Blend SrcAlpha One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID 
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID  
            };

            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            fixed _LightIntensity;

            uint4 _Splits;

            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
                UNITY_DEFINE_INSTANCED_PROP(fixed, _Frame)
            UNITY_INSTANCING_BUFFER_END(Props)

            fixed4 shot (sampler2D tex, float2 uv, float dx, float dy, int Stage) {
                return tex2D(tex, float2(
                    (uv.x * dx) + fmod(Stage, _Splits.x) * dx,
                    1.0 - ((uv.y * dy) + (Stage / _Splits.y) * dy)
                ));
            }

            

            v2f vert (appdata v)
            {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v); 
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);

                int Stages = _Splits.x * _Splits.y;
                float Stage = fmod(UNITY_ACCESS_INSTANCED_PROP(Props,_Frame), Stages);
                int current = floor(Stage);
                half dx = 1.0 / _Splits.x;
                half dy = 1.0 / _Splits.y;
 
                int next = floor(fmod(Stage + 1, Stages));
                fixed4 finalColor = lerp(shot(_MainTex, i.uv, dx, dy, current), shot(_MainTex, i.uv, dx, dy, next), Stage - current) * UNITY_ACCESS_INSTANCED_PROP(Props,_Color) * _LightIntensity;
                finalColor.a = saturate(finalColor.a);
                return finalColor;
            }
            ENDCG
        }
    }
}