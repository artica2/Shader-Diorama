Shader"Snow/SnowShader"
{
	Properties
	{
		_Tess("Tessellation", Range(1, 32)) = 20 // max tesselation
		_MaxTessDistance("Max Tess Distance", Range(1, 100)) = 20 // distance at which tesselation takes place
		_Splat("SplatMap", 2D) = "gray" {} // the snow trails
		_BaseMap("BaseMap", 2D) = "gray" {} // this is the base shape of the land
		_SnowColor ("Snow Color", Color) = (1,1,1,1) // snow color
        _GroundColor ("Ground Color", Color) = (1,1,1,1) // depressed snow color
		_Weight("Displacement Amount", Range(0, 1)) = 0 // max displacement
	}
 
	// The SubShader block containing the Shader code. 
	SubShader
	{
		// SubShader Tags define when and under which conditions a SubShader block or
		// a pass is executed.
		Tags{ "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline" }
 
		Pass
		{
			Tags{ "LightMode" = "UniversalForward" }
 
			HLSLPROGRAM

            // lighting and shadow includes. As this shader is an unlit shader
            // (URP doesn't support lit shaders outside of shadergraph), shadow
            // calculations have to be done manually
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #include "CustomTessellation.hlsl" // minion's tesselation file. The only 
            // thing added to the tesselation file was the introduction of worldPos coordinates
            // for shadow mapping
 
			// This line defines the name of the hull shader. 
			#pragma hull hull
			// This line defines the name of the domain shader. 
			#pragma domain domain
			// This line defines the name of the vertex shader. 
			#pragma vertex TessellationVertexProgram
			// This line defines the name of the fragment shader. 
			#pragma fragment frag

// definition of variables 
float _Weight;
float4 _SnowColor;
float4 _GroundColor;
sampler2D _Splat;
sampler2D _BaseMap;


ControlPoint TessellationVertexProgram(Attributes v)
{
    ControlPoint p;
 
    p.vertex = v.vertex;
    p.uv = v.uv;
    p.normal = v.normal;
    p.color = v.color;
    p.worldPos = v.worldPos;
 
    return p;
}
 
	// after tesselation
Varyings vert(Attributes input)
{
    Varyings output;
 
    float4 NoiseSplat = tex2Dlod(_Splat, float4(input.uv, 0, 0)); // displacement from splatmap
    float4 NoiseBase = tex2Dlod(_BaseMap, float4(input.uv, 0, 0)); // displacement from baseMap
    float displacement = (NoiseSplat.r + NoiseBase.r) * _Weight; // total displacement
	
    input.vertex.xyz -= normalize(input.normal) * displacement; 
    output.vertex = TransformObjectToHClip(input.vertex.xyz); // new vertex data
    output.color = input.color; // new vertex color
    output.normal = input.normal; // new vertex normal
    output.uv = input.uv; // new vertex UV
    output.worldPos = mul(unity_ObjectToWorld, input.vertex); // worldPos of the object
    return output;
}
 
[UNITY_domain("tri")]
			Varyings domain(TessellationFactors factors, OutputPatch<ControlPoint, 3> patch, float3 barycentricCoordinates : SV_DomainLocation)
{
    Attributes v;
		// interpolate the new positions of the tessellated mesh
    Interpolate(vertex)

    Interpolate(uv)

    Interpolate(color)

    Interpolate(normal)
 
    return vert(v);
}
 
	// The fragment shader definition.            
half4 frag(Varyings IN) : SV_Target
{
    // work out how 'depressed' the snow is
    float amount = tex2Dlod(_Splat, float4(IN.uv, 0, 0)).r + tex2Dlod(_BaseMap, float4(IN.uv, 0, 0)).r;
    float4 c = lerp(_SnowColor, _GroundColor, amount); // work out the color based on this depression

    // work out 'how much shadow' from the scenes main light is at the vertex's world position
    float4 shadowCoord = TransformWorldToShadowCoord(IN.worldPos);
#if _MAIN_LIGHT_SHADOWS_CASCADE || _MAIN_LIGHT_SHADOWS
    Light mainLight = GetMainLight(shadowCoord);
#else
    Light mainLight = GetMainLight();
#endif
    float shadow = mainLight.shadowAttenuation; 
    
    // extra point lights support
    float3 extraLights;
    int pixelLightCount = GetAdditionalLightsCount();
    for (int j = 0; j < pixelLightCount; ++j)
    {
        Light light = GetAdditionalLight(j, IN.worldPos, half4(1, 1, 1, 1));
        float3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
        extraLights += attenuatedLightColor;
    }
    c *= shadow; // apply the shadow from the main directional light
    c += float4(extraLights, 1); // add in the lighting from extra lights in the scene
    c += (unity_AmbientSky * 1); // ambient lighting    
	
    return c;
}
			ENDHLSL
		}
	}
}