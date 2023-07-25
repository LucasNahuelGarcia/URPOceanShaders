// This file contains the vertex and fragment functions for the forward lit pass
// This is the shader pass that computes visible colors for a material
// by reading material, light, shadow, etc. data

// Pull in URP library functions and our own common functions
#define UNITY_PI 3.14


#include <HLSLSupport.cginc>

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
#include "noise.hlsl"
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


float _ReflectionBloom;
float4 _ColorTintDeep;
float4 _ColorTintShallow;
float _AngleThreshold;
float _FoamThreshold;
float3 _FogColor;
float4 _WaveA;
float4 _WaveB;
float4 _WaveC;
float4 _WaveD;
float4 _WaveE;

float3 GerstnerWave(
    float4 wave, float3 p, inout float3 tangent, inout float3 binormal
)
{
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
        -d.x * d.x * (steepness * sin(f) - 1),
        d.x * (steepness * cos(f)),
        -d.x * d.y * (steepness * sin(f) - 1)
    );
    binormal += float3(
        -d.x * d.y * (steepness * sin(f) - 1),
        d.y * (steepness * cos(f)),
        -d.y * d.y * (steepness * sin(f) - 1)
    );
    return float3(
        d.x * (a * cos(f)),
        a * sin(f) - 1,
        d.y * (a * cos(f))
    );
}

Interpolators Vertex(Attributes input)
{
    Interpolators output;

    float3 tangent = float3(1, 0, 0);
    float3 binormal = float3(0, 0, 1);

    float3 p = input.positionOS.xyz;
    p += GerstnerWave(_WaveA, p, tangent, binormal);
    p += GerstnerWave(_WaveB, p, tangent, binormal);
    p += GerstnerWave(_WaveC, p, tangent, binormal);
    p += GerstnerWave(_WaveD, p, tangent, binormal);
    p += GerstnerWave(_WaveE, p, tangent, binormal);
    float3 normal = normalize(cross(binormal, tangent));
    VertexPositionInputs posnInputs = GetVertexPositionInputs(p);


    output.positionCS = posnInputs.positionCS;
    output.positionWS = posnInputs.positionWS;
    output.normalWS = normal;

    return output;
}

float3 getReflectionAngle(Interpolators input, InputData lightingInput)
{
    return -lightingInput.viewDirectionWS + 2 * dot(lightingInput.viewDirectionWS, input.normalWS) * input.normalWS;
}

float4 Fragment(Interpolators input) : SV_TARGET
{
    InputData lightingInput = (InputData)0;
    SurfaceData surfaceInput = (SurfaceData)0;

    lightingInput.positionWS = input.positionWS;
    lightingInput.positionCS = input.positionCS;
    lightingInput.viewDirectionWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
    lightingInput.normalWS = input.normalWS;
    lightingInput.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
    surfaceInput.smoothness = .3;
    surfaceInput.specular = .25;

    float3 lightDirection = GetMainLight().direction;
    float angleWithUpVector = abs(acos(dot(float3(0, 1, 0), input.normalWS)));
    float shallowness = angleWithUpVector * 100;
    float subsurfaceScattering = (acos(dot(lightDirection, lightingInput.viewDirectionWS))) / _AngleThreshold;
    subsurfaceScattering *= shallowness;
    float fresnel = abs(acos(dot(input.normalWS, lightingInput.viewDirectionWS))) / 90;
    if (fresnel > 1) fresnel = 1;

    subsurfaceScattering = clamp(subsurfaceScattering, 0, 1);

    float depth = SampleSceneDepth(input.positionCS.xy / _ScaledScreenParams);

    float3 deepColor = lerp(_ColorTintDeep, _ColorTintShallow, subsurfaceScattering);
    float3 notDeepColor = float3(1, 1, 1);
    float foamSize = .3;

    float perlinFoamPatch = angleWithUpVector;

    perlinFoamPatch *= (snoise(lightingInput.positionWS.xz / 50) + 1) / 3;
    float3 foam = clamp(voronoi(lightingInput.positionWS.xz / foamSize) * perlinFoamPatch, 0, 1);

    float3 color = lerp(deepColor, notDeepColor, log(depth + 1) * 3.321);
    color += foam;

    float3 reflectionAngle = getReflectionAngle(input, lightingInput) + (float3(1, 1, 1) * (snoise(input.positionWS.xz)
        * 0.051 * surfaceInput.smoothness));
    half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflectionAngle) * _ReflectionBloom;
    float reflectiveness = fresnel * (1 - foam);
    color = lerp(color, skyData.xyz, (reflectiveness));

    surfaceInput.albedo = color;
    surfaceInput.alpha = 1;
    float4 phong = UniversalFragmentBlinnPhong(lightingInput, surfaceInput);

    return phong;
}
