#ifndef MIDNIGHTPSX_PASS_INCLUDED
#define MIDNIGHTPSX_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"

// *-----------------------------------------------* 
// |                  Variables                    |
// *-----------------------------------------------*

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);
float4 _MainTex_ST;

float4 _ColorTint;

TEXTURE2D(_BumpMap);
SAMPLER(sampler_BumpMap);
float4 _BumpMap_ST;
float  _BumpScale;

float _Filtering;
float _FilterResolution;

float _AffineMappingToggle;
float _AffineMappingStrength;
float _PixelationToggle;
float _PixelationFactor;
 
float _ColorPrecisionToggle;
float _ColorPrecision;

float _LightModel;

float  _MatSmoothness;
float4 _SpecularColor;
float4 _CustomAmbientColor;
float  _Attenuation;

float  _CustomLightDirectionToggle;
float3 _CustomLightDirection;

float _AdditionalLights;
float _AdditionalLightsPerVertex;

float  _RimPower;
float4 _RimColor;

float _VertexColorsToggle;
float _VertexColorsSaturation;

float _VertexJitterToggle;
float _vertexResolution;

float  _EnableLODToggle;
int    _LODOverrides;
int    _CustomLODOverrides;
float  _OverrideMode;

TEXTURE2D(_CLOD1Tex);
SAMPLER(sampler_CLOD1Tex);
float4 _CLOD1Tex_ST;

TEXTURE2D(_CLOD2Tex);
SAMPLER(sampler_CLOD2Tex);
float4 _CLOD2Tex_ST;

TEXTURE2D(_CLOD3Tex);
SAMPLER(sampler_CLOD3Tex);
float4 _CLOD3Tex_ST;

TEXTURE2D(_CLOD4Tex);
SAMPLER(sampler_CLOD4Tex);
float4 _CLOD4Tex_ST;

TEXTURE2D(_CLOD5Tex);
SAMPLER(sampler_CLOD5Tex);
float4 _CLOD5Tex_ST;

TEXTURE2D(_CLOD6Tex);
SAMPLER(sampler_CLOD6Tex);
float4 _CLOD6Tex_ST;

TEXTURE2D(_CLOD7Tex);
SAMPLER(sampler_CLOD7Tex);
float4 _CLOD7Tex_ST;

float  _LODVertexResolution              = 1;
float  _LODTextureFilteringResolution    = 2048;
float  _LODTexturePixelizationResolution = 2048;
float4 _LOD1, _LOD2, _LOD3, _LOD4, _LOD5, _LOD6, _LOD7;

float _DrawDistanceToggle;
float _MaxDrawDistance;

float _EnableAnimatedVertexToggle;
TEXTURE2D(_animVertTex);
SAMPLER(sampler_animVertTex);
float4 _animVertTex_ST;

float _Scale;
float _Amplitude;
float _Speed;



// *-----------------------------------------------* 
// |                   Structs                     |
// *-----------------------------------------------*

struct VertexAttributes
{
    float4 positionOS         : POSITION;
    float3 normalOS           : NORMAL;
    float4 tangentOS          : TANGENT;       
    float2 uv                 : TEXCOORD0;
    float4 vertexPaintedColor : COLOR;
};


struct ToFragmentData
{
    float4 positionWS       : SV_POSITION;

    float3 normalWS         : NORMAL;
    float3 tangentWS        : TEXCOORD5;
    float3 bitangentWS      : TEXCOORD6;
    float4 uv               : TEXCOORD0;
    float3 vertexLightColor : COLOR;
	
    float3 normalDirection    : TEXCOORD1;
    float3 positionVS         : TEXCOORD2;
    float3 positionWSFL       : TEXCOORD3;
    float3 additionLightsFL   : TEXCOORD4;

    float4 vertexPaintedColor   : TEXCOORD7;
    float3 additionaLightVColor : TEXCOORD8;
    
    float4 CLOD1234             : TEXCOORD9;
    float4 CLOD567              : TEXCOORD10;
    
      
};


// *-----------------------------------------------*
// |            Custom Vertex Functions            |
// *-----------------------------------------------*

float3 LambertSpecularLightModelPerVertex(VertexAttributes v)
{
    float3 normalDirection = normalize(TransformObjectToWorldNormal(v.normalOS));
    float3 viewDirection   = normalize(GetCameraPositionWS() - TransformObjectToWorld(v.positionOS.xyz));
    float3 lightDirection;

    if (_CustomLightDirectionToggle)
        lightDirection = normalize(_CustomLightDirection.xyz);
    else
        lightDirection = normalize(GetMainLight().direction);
		 
    float3 diffuseReflection  = _Attenuation * _MainLightColor.rgb * dot(normalDirection, lightDirection);
    float3 specularReflection = _SpecularColor.rgb * max(0, dot(normalDirection, lightDirection / 4)) * (max(0, dot(reflect(-lightDirection / 4, normalDirection), viewDirection)), _MatSmoothness);


    float rim          = 1 - saturate(dot(viewDirection, normalDirection));
    float3 rimLighting = _Attenuation * _MainLightColor.rgb * _RimColor.rgb * saturate(dot(normalDirection, lightDirection)) * pow(rim, _RimPower);

    return diffuseReflection + specularReflection + rimLighting + _CustomAmbientColor.rgb;

}

float3 HandleLightingPerVertex(VertexAttributes v, VertexPositionInputs vertexInput, float3 normalWS)
{
    if (_LightModel == 1)
    {
        // Custom Lighting Model
        float3 mainLight = LambertSpecularLightModelPerVertex(v);
        // Vertex Lighting from nearby Lights
        float3 vertexLight = VertexLighting(vertexInput.positionWS, normalWS);

        // Having the ability to Toggle the mesh vertex colors is a really nice feature
        if (_VertexColorsToggle && _AdditionalLightsPerVertex == 1)
            return (mainLight + vertexLight) * v.vertexPaintedColor.rgb;
        if (_VertexColorsToggle && _AdditionalLightsPerVertex == 0)
            return (mainLight) * v.vertexPaintedColor.rgb;
        
        if (_AdditionalLightsPerVertex == 0)
            return mainLight;
        
        return mainLight + vertexLight;

    }
    
    return float3(1, 1, 1);

}


float2 HandleAffineMappingVertexPart(VertexAttributes v, ToFragmentData outputData)
{
    if (_AffineMappingToggle)
    {
        // Lerp between normal UVs and affine UVs BEFORE interpolation
        float2 transformedUV = TRANSFORM_TEX(v.uv, _MainTex);
        float2 affineUV = transformedUV * outputData.positionWS.w;
        return lerp(transformedUV, affineUV, _AffineMappingStrength);
    }

    return v.uv;
}


float  CalculateVertexDistanceFromCamera(float3 position)
{
    return distance(GetCameraPositionWS(), TransformObjectToWorld(position));
}

float4 VertexJitter(VertexAttributes v, float callFromLOD)
{			
    float4 viewPosition = mul(UNITY_MATRIX_MV, (v.positionOS));
	
    // Regular Vertex Jitter
    if (callFromLOD == 0)
    {
        if (_DrawDistanceToggle)
        {
            float distance = CalculateVertexDistanceFromCamera(v.positionOS.xyz);
        
            // Division by 0 is necessary to avoid a weird vanishing point effect when applying the draw distance
            if (distance > _MaxDrawDistance)
                viewPosition = floor(viewPosition * 0) / 0;
            else
                viewPosition = floor(viewPosition * _vertexResolution) / _vertexResolution;
        }
        else
            viewPosition = floor(viewPosition * _vertexResolution) / _vertexResolution;
    }
    // LOD Vertex Jitter
    else if (callFromLOD == 1)
    {
        if (_DrawDistanceToggle)
        {
            float distance = CalculateVertexDistanceFromCamera(v.positionOS.xyz);
        
            if (distance > _MaxDrawDistance)
                viewPosition = floor(viewPosition * 0) / 0;
            else
                viewPosition = floor(viewPosition * _LODVertexResolution) / _LODVertexResolution;
        }
        else
            viewPosition = floor(viewPosition * _LODVertexResolution) / _LODVertexResolution;
    }
    // Max Draw Distance
    else if (callFromLOD == 2)
    {
        float distance = CalculateVertexDistanceFromCamera(v.positionOS.xyz);
        
        if (distance > _MaxDrawDistance)
            viewPosition = floor(viewPosition * 0) / 0;
        else if (_VertexJitterToggle)
            viewPosition = floor(viewPosition * _vertexResolution) / _vertexResolution;
    }
    
    float4 screenPosition = mul(UNITY_MATRIX_P, viewPosition);

    return screenPosition;
}

float4 DynamicLOD(VertexAttributes v)
{
    float actualCameraDistanceFromVertex = CalculateVertexDistanceFromCamera(v.positionOS.xyz);
				
    // LOD 1
    if (actualCameraDistanceFromVertex < _LOD1.w)
        _LODVertexResolution = _LOD1.x;
	// LOD 2
    else if (actualCameraDistanceFromVertex > _LOD1.w && actualCameraDistanceFromVertex < _LOD2.w)
        _LODVertexResolution = _LOD2.x;
	// LOD 3
    else if (actualCameraDistanceFromVertex > _LOD2.w && actualCameraDistanceFromVertex < _LOD3.w)
        _LODVertexResolution = _LOD3.x;
	// LOD 4
    else if (actualCameraDistanceFromVertex > _LOD3.w && actualCameraDistanceFromVertex < _LOD4.w)
        _LODVertexResolution = _LOD4.x;
	// LOD 5
    else if (actualCameraDistanceFromVertex > _LOD4.w && actualCameraDistanceFromVertex < _LOD5.w)
        _LODVertexResolution = _LOD5.x;
	// LOD 6
    else if (actualCameraDistanceFromVertex > _LOD5.w && actualCameraDistanceFromVertex < _LOD6.w)
        _LODVertexResolution = _LOD6.x;
	// LOD 7
    else if (actualCameraDistanceFromVertex > _LOD6.w && actualCameraDistanceFromVertex < _LOD7.w)
        _LODVertexResolution = _LOD7.x;
    else if (actualCameraDistanceFromVertex > _LOD7.w)
        _LODVertexResolution = _LOD7.x;

    return VertexJitter(v, 1);
}

// DELETE
float HandleCustomLODCameraDistance(VertexAttributes v)
{
    float distance = CalculateVertexDistanceFromCamera(v.positionOS);
    // LOD 1
    if (distance < _LOD1.w)
        return distance > _LOD1.w && _LOD1.w > 0;
    // LOD 2
    else if (distance > _LOD1.w && distance < _LOD2.w)
        return distance > _LOD2.w && _LOD2.w > 0;
    // LOD 3
    else if (distance > _LOD2.w && distance < _LOD3.w)
        return distance > _LOD3.w && _LOD3.w > 0;
    // LOD 4
    else if (distance > _LOD3.w && distance < _LOD4.w)
        return distance > _LOD4.w && _LOD4.w > 0;
    // LOD 5
    else if (distance > _LOD4.w && distance < _LOD5.w)
        return distance > _LOD5.w && _LOD5.w > 0;
    // LOD 6
    else if (distance > _LOD5.w && distance < _LOD6.w)
        return distance > _LOD6.w && _LOD6.w > 0;
    // LOD 7
    else if (distance > _LOD6.w && distance < _LOD7.w)
        return distance > _LOD7.w && _LOD7.w > 0;

    return CalculateVertexDistanceFromCamera(v.positionOS) > _LOD7.w && _LOD7.w > 0;
}


float4 HandleVertAnimations(VertexAttributes v)
{
    float4 posOS = v.positionOS;

    if (_EnableAnimatedVertexToggle == 1)
    {
        float2 noiseUV = (v.uv.xy + _TimeParameters.x * _Speed) * _Scale;
        float noiseValue = SAMPLE_TEXTURE2D_LOD(_animVertTex, sampler_animVertTex, noiseUV, 0).r * _Amplitude;

        posOS.xyz += float3(0.0, 0.0, noiseValue); // displace in Y
    }

    return posOS;
}
 

float4 HandleVertexOutput(VertexAttributes v)
{
    if (_EnableLODToggle == 1 && (_LODOverrides == 0 || _LODOverrides == 3 || _LODOverrides == 4 || _LODOverrides == 6))
        return DynamicLOD(v);
    
    if (_VertexJitterToggle)
        return VertexJitter(v, 0);
    
    if (_DrawDistanceToggle)
        return VertexJitter(v, 2);

    return TransformObjectToHClip(v.positionOS.xyz);
}



// *-----------------------------------------------* 
// |           Custom Fragment Functions           |
// *-----------------------------------------------*

float3 LambertSpecularLightModelPerFragment(ToFragmentData input, float3 normals)
{
    float3 normalDirection = normals;
    float3 viewDirection = normalize(GetCameraPositionWS() - input.positionWSFL);
    float3 lightDirection;
			 
    if (_CustomLightDirectionToggle)
        lightDirection = normalize(_CustomLightDirection);
    else
        lightDirection = normalize(GetMainLight().direction);
				
    float3 diffuseReflection = _Attenuation * _MainLightColor.xyz * saturate(dot(normalDirection, lightDirection));
    
    float3 specularReflection = _SpecularColor.rgb * pow(max(0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _MatSmoothness);
    

    float rim = 1 - saturate(dot(normalize(viewDirection), normalDirection));
    float3 rimLighting = _Attenuation * _MainLightColor.xyz * _RimColor.rgb * pow(rim, _RimPower);
    
    return diffuseReflection + specularReflection + rimLighting + _CustomAmbientColor.rgb;
}

float3 HandleLightingPerFragment(ToFragmentData input, float3 normals)
{
    
    if (_LightModel == 0)
    {
        if (_VertexColorsToggle == 1)
            return input.vertexPaintedColor;

        
        return float3(1, 1, 1);
    }
    
    
    // Per Vertex
    if (_LightModel == 1)
        return input.vertexLightColor;
    
    
    // Final Light + Additional Lighting per Vertex
    if (_AdditionalLights == 1)
    {
        // Per Fragment
        if (_VertexColorsToggle)
            return (LambertSpecularLightModelPerFragment(input, normals) + input.additionaLightVColor) * input.vertexPaintedColor.rgb;
    
        return LambertSpecularLightModelPerFragment(input, normals) + input.additionaLightVColor;

    }
    else if (_AdditionalLights == 0)
    {
        if (_VertexColorsToggle)
            return (LambertSpecularLightModelPerFragment(input, normals) * input.vertexPaintedColor.rgb);
        
        return (LambertSpecularLightModelPerFragment(input, normals));
    }
    
    // Final Light + Additional Lighting Per Frament
    float3 vertexLight = VertexLighting(input.positionWSFL, normals);

    // Per Fragment
    if (_VertexColorsToggle)
        return (LambertSpecularLightModelPerFragment(input, normals) + vertexLight) * input.vertexPaintedColor.rgb;
    
    return LambertSpecularLightModelPerFragment(input, normals) + vertexLight;
}


float2 HandleAffineTextureMappingFragmentPart(float2 uv, float w)
{
    if (_AffineMappingToggle)
    {
        // Strength is 1: uv was multiplied by w in vertex, so divide by w
        // Strength is 0: uv was not multiplied, so don't divide
        float divisor = lerp(1.0, w, _AffineMappingStrength);
        return float2(uv / divisor);
    }

    return uv;
}


float2 TexturePixelation(float2 uv, int callFromLOD)
{
    if (_PixelationToggle && callFromLOD == 0)
        return floor(uv * _PixelationFactor) / _PixelationFactor;
    else if (callFromLOD == 1)
        return floor(uv * _LODTexturePixelizationResolution) / _LODTexturePixelizationResolution;

    return uv;
}

float4 ColorPrecisionTreatment(float4 pixel)
{
    if (_ColorPrecisionToggle)
        return floor(pixel.rgba * _ColorPrecision) / _ColorPrecision;
				
    return pixel;
}

float3 Filtering(float2 uv, int callFromLOD)
{        
    // NO LOD just the regular filtering | And LOD with an override that doesn't include filtering
    if ((_Filtering == 0 && (_EnableLODToggle == 0 || _EnableLODToggle == 2 || _EnableLODToggle == 3) || (_Filtering == 0 && (_EnableLODToggle == 1 || _EnableLODToggle == 3) && _LODOverrides != 1 && _LODOverrides != 3 && _LODOverrides != 5 && _LODOverrides != 6)))
        return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv).rgb;
    
    // Dynamic LOD or Both
    if ((_EnableLODToggle == 1 || _EnableLODToggle == 3)  && _LODTextureFilteringResolution == 0 && (_LODOverrides == 1 || _LODOverrides == 3 || _LODOverrides == 5 || _LODOverrides == 6))
        return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv).rgb;


    
    float textureSize;

    if (callFromLOD == 0)
        textureSize = _Filtering;
    else
        textureSize = _LODTextureFilteringResolution;

    float s = (1.0 / textureSize);
    float2 pixel = uv * textureSize + 0.5;
    float2 f     = frac(pixel);
    pixel        = (floor(pixel) / textureSize) - float2(s / 2.0, s / 2.0);
    float3 C11 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, pixel + float2(0.0, 0.0)).rgb;
    float3 C21 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, pixel + float2(s, 0.0)).rgb;
    float3 C12 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, pixel + float2(0.0, s)).rgb;
    float3 C22 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, pixel + float2(s, s)).rgb;
    float3 x1    = lerp(C11, C21, f.x);
    float3 x2    = lerp(C12, C22, f.x);

    return lerp(x1, x2, f.y);
}


float3 HandleDynamicLODTextureFiltering(ToFragmentData input, float2 uv)
{    
    _LODTextureFilteringResolution = _LOD1.y;
    
    if (input.uv.w >= _LOD1.w && input.CLOD1234.x >= 0.99)
    {
        _LODTextureFilteringResolution = _LOD1.y;
    }
    else if (input.uv.w >= _LOD2.w && input.CLOD1234.y >= 0.99)
    {
        _LODTextureFilteringResolution = _LOD2.y;
    }
    else if (input.uv.w >= _LOD3.w && input.CLOD1234.z >= 0.99)
    {
        _LODTextureFilteringResolution = _LOD3.y;
    }
    else if (input.uv.w >= _LOD4.w && input.CLOD1234.w >= 0.99)
    {
        _LODTextureFilteringResolution = _LOD4.y;
    }
    else if (input.uv.w >= _LOD5.w && input.CLOD567.x >= 0.99)
    {
        _LODTextureFilteringResolution = _LOD5.y;
    }
    else if (input.uv.w >= _LOD6.w && input.CLOD567.y >= 0.99)
    {
        _LODTextureFilteringResolution = _LOD6.y;
    }
    else if (input.uv.w >= _LOD7.w && input.CLOD567.z >= 0.99)
    {
        _LODTextureFilteringResolution = _LOD7.y;
    }


    return Filtering(uv, 1);
}

float2 HandleDynamicLODTexturePixelization(ToFragmentData input, float2 uv)
{
    _LODTexturePixelizationResolution = _LOD1.z;
   
    if (input.uv.w >= _LOD1.w && input.CLOD1234.x >= 0.99)
    {
        _LODTexturePixelizationResolution = _LOD1.z;
    }
    else if (input.uv.w >= _LOD2.w && input.CLOD1234.y >= 0.99)
    {
        _LODTexturePixelizationResolution = _LOD2.z;
    }
    else if (input.uv.w >= _LOD3.w && input.CLOD1234.z >= 0.99)
    {
        _LODTexturePixelizationResolution = _LOD3.z;
    }
    else if (input.uv.w >= _LOD4.w && input.CLOD1234.w >= 0.99)
    {
        _LODTexturePixelizationResolution = _LOD4.z;
    }
    else if (input.uv.w >= _LOD5.w && input.CLOD567.x >= 0.99)
    {
        _LODTexturePixelizationResolution = _LOD5.z;
    }
    else if (input.uv.w >= _LOD6.w && input.CLOD567.y >= 0.99)
    {
        _LODTexturePixelizationResolution = _LOD6.z;
    }
    else if (input.uv.w >= _LOD7.w && input.CLOD567.z >= 0.99)
    {
        _LODTexturePixelizationResolution = _LOD7.z;
    }


    return TexturePixelation(uv, 1);

}

float4 HandleCustomLevelOfDetail(ToFragmentData input, float4 finalColor, float2 finalUV)
{
    float4 finalProcessedColor = finalColor;
    
    // This aren't Integer comparisons, so there's a floating point error that prevents the 
    // texture adding from happening if I compare them directly to 1

    if (input.CLOD1234.x >= 0.99)
    {
        float4 cLOD1 = SAMPLE_TEXTURE2D(_CLOD1Tex, sampler_CLOD1Tex, finalUV);
        finalProcessedColor = cLOD1;
    }

    if (input.CLOD1234.y >= 0.99)
    {
        float4 cLOD2 = SAMPLE_TEXTURE2D(_CLOD2Tex, sampler_CLOD2Tex, finalUV);
        finalProcessedColor = cLOD2;
    }

    if (input.CLOD1234.z >= 0.99)
    {
        float4 cLOD3 = SAMPLE_TEXTURE2D(_CLOD3Tex, sampler_CLOD3Tex, finalUV);
        finalProcessedColor = cLOD3;
    }

    if (input.CLOD1234.w >= 0.99)
    {
        float4 cLOD4 = SAMPLE_TEXTURE2D(_CLOD4Tex, sampler_CLOD4Tex, finalUV);
        finalProcessedColor = cLOD4;
    }

    if (input.CLOD567.x >= 0.99)
    {
        float4 cLOD5 = SAMPLE_TEXTURE2D(_CLOD5Tex, sampler_CLOD5Tex, finalUV);
        finalProcessedColor = cLOD5;
    }
    
    if (input.CLOD567.y >= 0.99)
    {
        float4 cLOD6 = SAMPLE_TEXTURE2D(_CLOD6Tex, sampler_CLOD6Tex, finalUV);
        finalProcessedColor = cLOD6;
    }
    
    if (input.CLOD567.z >= 0.99)
    {
        float4 cLOD7 = SAMPLE_TEXTURE2D(_CLOD7Tex, sampler_CLOD7Tex, finalUV);
        finalProcessedColor = cLOD7;
    }
    
    return finalProcessedColor;

}


void HandleFinalColor(ToFragmentData input, float2 affineUV, float4 originalColor, out float4 finalColor, out float2 finalUV)
{
    float2 pixelatedUV = affineUV;
    float4 finalPixelColorPrecision;
    finalColor = originalColor;
    
    if (_EnableLODToggle == 1)
    {
        if (_LODOverrides == 2 || _LODOverrides == 4 || _LODOverrides == 5 || _LODOverrides == 6)
        {
            pixelatedUV = HandleDynamicLODTexturePixelization(input, affineUV);
            finalUV = pixelatedUV;
        }
        else
        {
            pixelatedUV = TexturePixelation(affineUV, 0);
            finalUV = pixelatedUV;
        }
					
        if (_LODOverrides == 1 || _LODOverrides == 3 || _LODOverrides == 5 || _LODOverrides == 6)
            finalColor.rgb = HandleDynamicLODTextureFiltering(input, pixelatedUV);
        else
            finalColor.rgb = Filtering(pixelatedUV, 0);
    }
    else if (_EnableLODToggle == 2)
    {   
        pixelatedUV = TexturePixelation(affineUV, 0);
        finalUV = pixelatedUV;
        finalColor.rgb = Filtering(pixelatedUV, 0);
            
        finalColor = HandleCustomLevelOfDetail(input, finalColor, finalUV);
    }
    else if (_EnableLODToggle == 3)
    {
	
        if (_LODOverrides == 2 || _LODOverrides == 4 || _LODOverrides == 5 || _LODOverrides == 6)
        {
            pixelatedUV = HandleDynamicLODTexturePixelization(input, affineUV);
            finalUV = pixelatedUV;
        }
        else
        {
            pixelatedUV = TexturePixelation(affineUV, 0);
            finalUV = pixelatedUV;
        }
        
        finalColor = HandleCustomLevelOfDetail(input, finalColor, finalUV);    
    }
    else
    {
        pixelatedUV    = TexturePixelation(affineUV, 0);
        finalColor.rgb = Filtering(pixelatedUV, 0);
        finalUV = pixelatedUV;
    }
    
    
    finalColor.a = originalColor.a;
    finalColor   = ColorPrecisionTreatment(finalColor);
}

// *-----------------------------------------------* 
// |                     Vertex                    |
// *-----------------------------------------------*

ToFragmentData Vertex(VertexAttributes v, const uint instance_id : SV_InstanceID)
{
    ToFragmentData outputData;
    
    // Apply vertex animations first
    v.positionOS = HandleVertAnimations(v);
    // Structure that contains multiple vertex position Data CS, WS, VS
    VertexPositionInputs vertexInput = GetVertexPositionInputs(v.positionOS.xyz);
    // Structure that contains multiple vertex normal Data TangentWS, NormalWS, BiTangentWS (Used when a normal map has not been assigned)
    VertexNormalInputs normalInput = GetVertexNormalInputs(v.normalOS, v.tangentOS);
           

    // NORMALS
    outputData.normalWS    = normalInput.normalWS;
    outputData.tangentWS   = normalInput.tangentWS;
    outputData.bitangentWS = normalInput.bitangentWS;
    
    float3 finalVertexLight = HandleLightingPerVertex(v, vertexInput, normalInput.normalWS);
    
    outputData.positionWS       = HandleVertexOutput(v);
    outputData.positionVS       = TransformWorldToView(TransformObjectToWorld(v.positionOS.xyz));
    outputData.normalWS         = normalInput.normalWS;
    outputData.uv.xy            = HandleAffineMappingVertexPart(v, outputData);

    outputData.uv.w             = CalculateVertexDistanceFromCamera(v.positionOS);

    // Every LOD checks one more than the next one to fill the gaps that will be produced between LOD's if
    // the check was done between the actual LOD and the next LOD
    if ((_EnableLODToggle && _OverrideMode == 1 && (_CustomLODOverrides == 2 || _CustomLODOverrides == 3)) || (_EnableLODToggle && _OverrideMode == 0 && (_LODOverrides == 2 || _LODOverrides == 3 || _LODOverrides == 4 || _LODOverrides == 5 || _LODOverrides == 6 || _LODOverrides == 7)))
    {
        outputData.CLOD1234.x = (outputData.uv.w >= _LOD1.w && outputData.uv.w <= _LOD3.w);
        outputData.CLOD1234.y = (outputData.uv.w >= _LOD2.w && outputData.uv.w <= _LOD4.w);
        outputData.CLOD1234.z = (outputData.uv.w >= _LOD3.w && outputData.uv.w <= _LOD5.w);
        outputData.CLOD1234.w = (outputData.uv.w >= _LOD4.w && outputData.uv.w <= _LOD6.w);
    
        outputData.CLOD567.x = (outputData.uv.w >= _LOD5.w && outputData.uv.w <= _LOD7.w);
        outputData.CLOD567.y = (outputData.uv.w >= _LOD6.w && outputData.uv.w <= _LOD7.w + _LOD7.w);
        outputData.CLOD567.z = (outputData.uv.w >= _LOD7.w);
    }
    
    
    outputData.vertexLightColor = finalVertexLight;
    
    // Per Fragment Lighting prerequisites
    outputData.positionWSFL       = TransformObjectToWorld(v.positionOS.xyz);
    outputData.normalDirection    = normalize(mul(float4(v.normalOS, 0), unity_WorldToObject).xyz);
    outputData.additionLightsFL   = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
    
    outputData.vertexPaintedColor = v.vertexPaintedColor;
    outputData.additionaLightVColor = VertexLighting(vertexInput.positionWS, outputData.normalWS);

    return outputData;
}

// *-----------------------------------------------* 
// |                    Fragment                   |
// *-----------------------------------------------*

float4 Fragment(ToFragmentData input) : SV_Target
{

    float2 tilingAndOffsetUV = TRANSFORM_TEX(input.uv, _MainTex);
    float2 affineUV;
    if (_AffineMappingToggle == 1)
        affineUV = HandleAffineTextureMappingFragmentPart(input.uv, input.positionWS.w);
    else
        affineUV = HandleAffineTextureMappingFragmentPart(tilingAndOffsetUV, input.positionWS.w);
    
    float4 originalColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, affineUV);
    
    float4 finalColor;
    float2 finalUV;
    
    HandleFinalColor(input, affineUV, originalColor, finalColor, finalUV);
     
    // Normals
    float3 tangentSpaceNormal = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, finalUV));

    float3x3 mtxTangentToWorld =
    {
        input.tangentWS.x, input.bitangentWS.x, input.normalWS.x,
        input.tangentWS.y, input.bitangentWS.y, input.normalWS.y,
        input.tangentWS.z, input.bitangentWS.z, input.normalWS.z
    };
    
    float3 finalNormals = mul(mtxTangentToWorld, tangentSpaceNormal) * _BumpScale;
    float3 finalLight   = HandleLightingPerFragment(input, finalNormals);

    return (finalColor * _ColorTint) * float4(finalLight, 1);
}

#endif
