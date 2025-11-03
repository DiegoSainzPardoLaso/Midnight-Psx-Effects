Shader "Custom PSX Shaders/Midnight PSX Polygons"
{
    Properties
    {
	
        _MainTex ("Texture", 2D) = "white" {}																													 
		_ColorTint("Color Tint", Color) = (1,1,1,1)


        [NoScaleOffset]_BumpMap("Normal Map", 2D) = "bump" {}																									 
        [PowerSlider(1.0)]_BumpScale("Normal Strength", Range (-10, 10)) = 1.0																					 

		[Enum(Both Sides, 0, Back Side, 1, Front Side, 2)]_CullMode("Cull Mode",Int) = 0																		 
		[Enum(Off, 0, On, 1)]_AlphaMaskMode("Alpha Mode",Int) = 0																								 
		[Space(5)]
		[Enum(Off, 0, On, 1)]_ZWriteMode("ZWrite Mode",Int) = 1																									 

		[Enum(UnityEngine.Rendering.ColorWriteMask)] _ColorMask("Color Mask", int) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)] _ComparisonMode ("Comparison Mode", int) = 0																 
		[Enum(UnityEngine.Rendering.StencilOp)] _PassMode ("Stencil Operation Mode", int) = 0																	 
		_RefValue ("Ref Value", Integer) = 0																													 

		[Enum(PSX Point,0, PSX Bilinear,512, N64, 256, Saturn, 128,  LOD Close, 94, LOD Mid, 59, LOD Far, 17)] _Filtering ("Filtering Mode", int) = 0			 
		
		[Toggle] _AffineMappingToggle("Enable Affine Texture Mapping", float) = 0
		[PowerSlider(2.0)]_AffineMappingStrength("Affine Mapping Strength", Range(0, 1)) = 1.0																				 

		[Toggle] _PixelationToggle("Enable Texture Pixelization", float) = 0																					 
		_PixelationFactor("Texture Resolution", float) = 1024																									 
			
		[Toggle] _ColorPrecisionToggle("Enable Color Precision", float) = 0																						 
		_ColorPrecision("Color Precision", float) = 256																											 

		[Space(5)]
		[Enum(Disabled, 0, Lambert Specular per Vertex,1,Lambert Specular per Pixel,2)] _LightModel ("Light Model", int) = 2													 
		_Attenuation("Attenuation", float) = 0.35																												 
		[Space(10)]
		_MatSmoothness("Smoothness", float) = 1																													 
		[HDR]_SpecularColor("Specular Color", Color) = (0.2358491, 0.2358491, 0.2358491, 1)																	 
		[Space(10)]
		_RimPower("Rim Power", float) = 4																														 
		[HDR]_RimColor("Rim Color", Color) = (0.254717, 0.254717, 0.254717, 1)																			 
		[Space(10)]
		
		_CustomAmbientColor("Custom Ambient Color", Color) = (0.3962264, 0.3962264, 0.3962264, 1)									 

		[Toggle]_CustomLightDirectionToggle("Enable Custom Light Direction", float) = 0
		_CustomLightDirection("Custom Light Direction", vector) = (0,0,0,0)

		// Only really works in addition to the per fragment pass
		[Enum(Disabled, 0, Contribute per Vertex,1,Contribute per Pixel,2)] _AdditionalLights ("Additional Lights Contribution", int) = 2	 
		[Enum(Disabled, 0, Enabled,1)] _AdditionalLightsPerVertex ("Additional Lights Contribution", int) = 1						 

		[Space(5)]
		[Toggle]_VertexColorsToggle("Enable Vertex Color", float) = 0
		_VertexColorsSaturation("Vertex Color Saturation", float) = 1

		[Toggle] _VertexJitterToggle("Disable Vertex Precision", float) = 0
		_vertexResolution("Vertex Precision", float) = 256
		
		[Space(5)]
		[Enum(Disabled, 0, Dynamic LOD, 1, Custom LOD, 2, Both, 3)]_EnableLODToggle("Enable LOD", float) = 0

		[Enum(Dynamic LOD, 0, Custom LOD, 1)] _OverrideMode("Override", float) = 0

		[Enum(Vertex Precision,0, Texture Filtering, 1, Texture Pixelization, 2, Vertex Precision And Texture Filtering, 3, Vertex Precision And Texture Pixelization, 4, Texture Filtering And Texture Pixelization, 5, Vertex Precision And Texture Filtering And Texture Pixelization, 6)] _LODOverrides("Override", Integer) = 0
		[Enum(Disabled,0, Custom Textures, 1)] _CustomLODOverrides("Custom LOD Override", Integer) = 0

		[NoScaleOffset]_CLOD1Tex("First Custom LOD Texture",   2D) = "white"
		[NoScaleOffset]_CLOD2Tex("Second Custom LOD Texture",  2D) = "white"
		[NoScaleOffset]_CLOD3Tex("Third Custom LOD Texture",   2D) = "white"
		[NoScaleOffset]_CLOD4Tex("Forth Custom LOD Texture",   2D) = "white"
		[NoScaleOffset]_CLOD5Tex("Fifth Custom LOD Texture",   2D) = "white"
		[NoScaleOffset]_CLOD6Tex("Sixth Custom LOD Texture",   2D) = "white"
		[NoScaleOffset]_CLOD7Tex("Seventh Custom LOD Texture", 2D) = "white"


		[Space(10)]
		_LOD1("1 - LOD", vector) = (2048, 0,    1024, 10)	 
		_LOD2("2 - LOD", vector) = (256,  512,  512,  20)
		_LOD3("3 - LOD", vector) = (128,  256,  256,  30)
		_LOD4("4 - LOD", vector) = (64,   128,  128,  35)
		_LOD5("5 - LOD", vector) = (32,   94,   64,   40)
		_LOD6("6 - LOD", vector) = (16,   59,   32,   45)
		_LOD7("7 - LOD", vector) = (8,    17,   16,   50)
		
		[Toggle]_DrawDistanceToggle("Enable Draw Distance", float) = 0
		_MaxDrawDistance("Max Draw Distance", float) = 50


		
		[Toggle]_EnableAnimatedVertexToggle("Enable Animated Displacement", float) = 0
		_animVertTex("Animated Vertex Texture", 2D) = "white" {}			
		_Scale("Displacement scale", float) = 0
		_Amplitude("Displacement Amplitude", float) = 0
		_Speed("Displacement Speed", float) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
		ColorMask RGBA
		Cull [_CullMode]
		AlphaToMask [_AlphaMaskMode]
		ZWrite [_ZWriteMode]

		Stencil
        {
            Ref  [_RefValue]
            Comp [_ComparisonMode]
			Pass [_PassMode]
        }

		pass
		{
			Name "Forward PSX Lit"
		
	

			HLSLPROGRAM

			#pragma target 4.0
            #pragma vertex   Vertex
            #pragma fragment Fragment
			#pragma multi_compile_fog

			// Material Keywords
            #pragma shader_feature_local _NORMALMAP

 
            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _FORWARD_PLUS
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            #include "MidnightPSXPass.hlsl"

			ENDHLSL

		}
	 
    }

	CustomEditor "MidnightPSXCustomGUI"
}
