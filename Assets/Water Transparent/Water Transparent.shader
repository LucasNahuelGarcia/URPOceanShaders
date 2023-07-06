Shader "LucasShaders/Water Transparent"
{
    // Properties are options set per material, exposed by the material inspector
    // A material is just a Shader with its own custom Properties
    Properties
    {
        [Header(Surface options)] // Creates a text header
        // [MainColor] allows Material.color to use the correct property
        [MainColor] _ColorTint("Tint", Color) = (1, 1, 1, 1)

        //By convention, properties have an underscore prefix.
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
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            // Include our code file
            #include "WaterForwardLitPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
            ColorMask 0
            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "WaterShadowCasterPass.hlsl"
            ENDHLSL
        }
    }
}