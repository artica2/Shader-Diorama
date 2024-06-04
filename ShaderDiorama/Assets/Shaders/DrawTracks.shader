Shader "Unlit/DrawTracks"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} 
        _Coordinate("Coordinate", Vector) = (0,0,0,0) // coord in UV space to draw tracks
        _Color("Draw Color", Color) = (1,0,0,0) // color of the tracks (not the actual color, but the color for the splatmap: red
        _Size("Size", Range(1, 500)) = 1 // size of tracks
        _Strength("Strength", Range(0,1)) = 1 // strength of tracks (depth)
        _RegenSpeed("RegenSpeed", Range(0,1)) = 0.1 // speed at which the tracks will fill back up
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            // property declerations
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Coordinate, _Color;
            half _Size, _Strength;
            float _RegenSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                // transform vertex and UV data
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {                
                fixed4 col = tex2D(_MainTex, i.uv); // sample the texture
                float distanceToCoordinate = distance(i.uv, _Coordinate.xy) * 500/_Size; // work out distance from the coord
                float draw = 1 - smoothstep(0.5 - _Strength / 2, 0.5 + _Strength / 2, distanceToCoordinate); // draw based on distance from coord
                fixed4 drawCol = _Color * (draw * _Strength); // multiply by the strength
    
                // Regenerate snow over time
                drawCol -= _RegenSpeed/10 * unity_DeltaTime;
                
                return saturate(col + drawCol); // saturate between 0 and 1
                return col;
            }
            ENDCG
        }
    }
}
