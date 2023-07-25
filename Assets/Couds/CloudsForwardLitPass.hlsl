#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
#include "noise.hlsl"

struct Attributes
{
    float3 positionOS : POSITION; // Position in object space
    float3 normalOS : NORMAL;
    float2 uv : TEXCOORD0; // Material texture UVs (texture coordinate set number zero)
};

struct Interpolators
{
    float4 positionCS : SV_POSITION;
    float3 positionWS : TEXCOORD1;
    float3 normalWS : TEXCOORD2;
};

Interpolators Vertex(Attributes input)
{
    Interpolators output;

    VertexPositionInputs posnInputs = GetVertexPositionInputs(input.positionOS);

    output.positionCS = posnInputs.positionCS;
    output.positionWS = posnInputs.positionWS;

    return output;
}

float4 Fragment(Interpolators input) : SV_TARGET
{
    float cloudSize = 50;

    float v = 1 - (voronoi(input.positionWS.xz / cloudSize) + 1) / 2;
    return float4(v, v, v, 1);
}
