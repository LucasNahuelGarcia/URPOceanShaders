Shader "LucasShaders/Ocean"
{
    // Properties are options set per material, exposed by the material inspector
    // A material is just a Shader with its own custom Properties
    Properties
    {
        [Header(Surface options)] // Creates a text header
        // [MainColor] allows Material.color to use the correct property
        _ReflectionBloom("ReflectionBloom", float) = 2
        [MainColor] _ColorTintShallow("Tint Shallow", Color) = (1, 1, 1, 1)
        [MainColor] _ColorTintDeep("Tint Deep", Color) = (1, 1, 1, 1)
        _AngleThreshold("Angle Threshold", float) = 180
        _FogColor("Fog Color", Color) = (1, 1, 1, 1)
        _WaveA ("Wave A (dir, steepness, wavelength)", Vector) = (1,0,0.5,10)
        _WaveB ("Wave B (dir, steepness, wavelength)", Vector) = (1,0,0.5,10)
        _WaveC ("Wave C (dir, steepness, wavelength)", Vector) = (1,0,0.5,10)
        _WaveD ("Wave D (dir, steepness, wavelength)", Vector) = (1,0,0.5,10)
        _WaveE ("Wave E (dir, steepness, wavelength)", Vector) = (1,0,0.5,10)
    }
    // Subshaders allow for different behaviour and options for different pipelines and platforms
    SubShader
    {
        // These tags are shared by all passes in this sub shader
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"

            //Render the object in the Transparent queue
            "Queue" = "Transparent"
            "RenderType"="Transparent"
        }

        // Shaders can have several passes which are used to render different data about the material
        // Each pass has it's own vertex and fragment function and shader variant keywords
        Pass
        {
            Name "ForwardLit" // For debugging
            Tags
            {
                "LightMode" = "UniversalForward"
            } // Pass specific tags. 
            // "UniversalForward" tells Unity this is the main lighting pass of this shader
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM
            // Begin HLSL code
            // Register our programmable stage functions

            #pragma vertex Vertex
            #pragma fragment Fragment
            #define _SPECULAR_COLOR

            #include "WaterForwardLitPass.hlsl"
            ENDHLSL
        }
    }
}