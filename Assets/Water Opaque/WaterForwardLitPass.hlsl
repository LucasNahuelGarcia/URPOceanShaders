// This file contains the vertex and fragment functions for the forward lit pass
// This is the shader pass that computes visible colors for a material
// by reading material, light, shadow, etc. data

// Pull in URP library functions and our own common functions
#define UNITY_PI 3.14

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Noise.hlsl"

// This attributes struct receives data about the mesh we're currently rendering
// Data is automatically placed in fields according to their semantic
struct Attributes
{
    float3 positionOS : POSITION; // Position in object space
    float3 normalOS : NORMAL;
    float2 uv : TEXCOORD0; // Material texture UVs (texture coordinate set number zero)
};

// This struct is output by the vertex function and input to the fragment function.
// Note that fields will be transformed by the intermediary rasterization stage
struct Interpolators
{
    // This value should contain the position in clip space (which is similar to a position on screen)
    // when output from the vertex function. It will be transformed into pixel position of the current
    // fragment on the screen when read from the fragment function
    float4 positionCS : SV_POSITION;
    float3 positionWS : TEXCOORD1;
    float3 normalWS : TEXCOORD2;
};


float4 _ColorTint;
float4 _WaveA;
float4 _WaveB;
float4 _WaveC;
float3 GerstnerWave (
            float4 wave, float3 p, inout float3 tangent, inout float3 binormal
        ) {
    int added = 0;
    float3 pWS = TransformObjectToWorld(p);
    float steepness = wave.z;
    float wavelength = wave.w;
    float k = 2 * UNITY_PI / wavelength;
    float c = sqrt(9.8 / k);
    float2 d = (wave.xy);
    float f = k * (dot(d, pWS.xz) - c * _Time.y);
    float a = steepness / k;
			
    //p.x += d.x * (a * cos(f));
    //p.y = a * sin(f);
    //p.z += d.y * (a * cos(f));

    tangent += float3(
        -d.x * d.x * (steepness * sin(f)-1),
        d.x * (steepness * cos(f)),
        -d.x * d.y * (steepness * sin(f)-1)
    );
    binormal += float3(
        -d.x * d.y * (steepness * sin(f)-1),
        d.y * (steepness * cos(f)),
        -d.y * d.y * (steepness * sin(f)-1)
    );
    return float3(
        d.x * (a * cos(f)),
        a * sin(f)-1,
        d.y * (a * cos(f))
    );
}

// The vertex function. This runs for each vertex on the mesh.
// It must output the position on the screen each vertex should appear at,
// as well as any data the fragment function will need
Interpolators Vertex(Attributes input)
{
    Interpolators output;

    float3 tangent = float3(1, 0, 0);
    float3 binormal = float3(0, 0, 1);
    
    float3 p = input.positionOS.xyz;
    p += GerstnerWave(_WaveA, p, tangent, binormal);
    p += GerstnerWave(_WaveB, p, tangent, binormal);
    p += GerstnerWave(_WaveC, p, tangent, binormal);
    float3 normal = normalize(cross(binormal, tangent));
    VertexPositionInputs posnInputs = GetVertexPositionInputs(p);

    // These helper functions, found in URP/ShaderLib/ShaderVariablesFunctions.hlsl
    // transform object space values into world and clip space

    // float3 normal = float3(0,1,0);

    //const VertexNormalInputs normInputs = GetVertexNormalInputs(normal);

    // Pass position and orientation data to the fragment function
    output.positionCS = posnInputs.positionCS;
    output.positionWS = posnInputs.positionWS;
    output.normalWS = normal;

    return output;
}

// The fragment function. This runs once per fragment, which you can think of as a pixel on the screen
// It must output the final color of this pixel
float4 Fragment(Interpolators input) : SV_TARGET
{
    // Use the SAMPLE_TEXTURE2D macro to get the color out of a texture at a specific location. 
    // It takes three arguments: the texture, the sampler, and the UV coordinate to sample.
    InputData lightingInput = (InputData)0;
    SurfaceData surfaceInput = (SurfaceData)0;

    lightingInput.positionWS = input.positionWS;
    lightingInput.positionCS = input.positionCS;
    lightingInput.viewDirectionWS = GetWorldSpaceViewDir(input.positionWS);
    lightingInput.normalWS = normalize(input.normalWS);
    lightingInput.shadowCoord = TransformWorldToShadowCoord(input.positionWS);

    surfaceInput.smoothness = .00;
    surfaceInput.specular = .25;

    surfaceInput.albedo = _ColorTint;
    surfaceInput.alpha = _ColorTint.a;

    float4 phong = UniversalFragmentBlinnPhong(lightingInput, surfaceInput);

    return phong;
}
