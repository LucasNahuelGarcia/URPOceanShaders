Shader "LucasShaders/Clouds"
{
    Properties
    {
        [Header(Surface options)]
        _WaveC ("Wave C (dir, steepness, wavelength)", Vector) = (1,0,0.5,10)
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Transparent"
            "RenderType"="Transparent"
        }

        Pass
        {
            Name "ForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
            } 
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment
            #define _SPECULAR_COLOR

            #include "CloudsForwardLitPass.hlsl"
            ENDHLSL
        }
    }
}