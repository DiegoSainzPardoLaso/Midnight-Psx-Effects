using UnityEngine;
using UnityEditor;


public class MidnightPSXCustomGUI : ShaderGUI
{
    enum Filtering
    {
        PSX_Point    = 0,
        PSX_Bilinear = 512,
        N64          = 216,
        Saturn       = 128,
        LOD_Close    = 94,
        LOD_Mid      = 59,
        LOD_Far      = 16
    }

    public Texture2D _midnightLog = EditorGUIUtility.Load("Assets/Midnight Logo.png") as Texture2D;
    Material target;
    MaterialEditor editor;
    MaterialProperty[] properties;
    static GUIContent staticLabel = new GUIContent();

    // Texture2D mainTexture;


    bool _textureSettingsShowPosition = true;
    string _textureStatus             = "Texture Settings";

    bool _surfaceSettingsShowPosition = true;
    string _surfaceStatus             = "Surface Settings";

    bool _lightingShowPosition = true;
    string _lightingStatus     = "Lighting Settings";

    bool _vertexShowPosition = true;
    string _vertexStatus     = "Vertex Settings";

    bool   _advancedOptionsShowPosition = true;
    string _advancedOptionsStatus       = "Advanced Settings";

    bool _LODShowPosition = true;
    string _LODStatus     = "LOD Settings";

    bool _DrawDistanceShowPosition = true;
    string _DrawDistanceStatus     = "Draw Distance Settings";

    bool _AnimatedVertexPosition = true;
    string _animatedVertexStatus = "Animated Vertices Settings";

    public override void OnGUI(MaterialEditor editor, MaterialProperty[] properties)
    {
        this.target     = editor.target as Material;
        this.editor     = editor;
        this.properties = properties;

        HandleSurface();
        HandleTextureMaps();
        HandleLighting();
        HandleVertex();
        HandleDrawDistance();
        HandleLOD();
        HandleVertexAnimation();
        HandleAdvancedOptions();
    }

    void HandleSurface()
    {
        _surfaceSettingsShowPosition = EditorGUILayout.BeginFoldoutHeaderGroup(_surfaceSettingsShowPosition, _surfaceStatus);
        if (_surfaceSettingsShowPosition)
        {
            DoAlphaMask();
            DoCulling();
        }

        EditorGUI.EndFoldoutHeaderGroup();
    }

    void HandleTextureMaps()
    {
        // GUI.DrawTexture(new Rect(0, 0, _midnightLog.width / 10, _midnightLog.height / 10), _midnightLog, ScaleMode.StretchToFill);

        _textureSettingsShowPosition = EditorGUILayout.BeginFoldoutHeaderGroup(_textureSettingsShowPosition, _textureStatus);
        if (_textureSettingsShowPosition)
        {
            DoMainTexture();
            DoNormals();
            DoFiltering();
            DoAffineMapping();
            DoTexturePixelization();
            DoColorPrecision();
        }

        EditorGUI.EndFoldoutHeaderGroup();
    }

    void HandleLighting()
    {
        _lightingShowPosition = EditorGUILayout.BeginFoldoutHeaderGroup(_lightingShowPosition, _lightingStatus);
        if (_lightingShowPosition)
        {
            DoLightingModel();
        }

        EditorGUI.EndFoldoutHeaderGroup();
    }

    void HandleVertex()
    {
        _vertexShowPosition = EditorGUILayout.BeginFoldoutHeaderGroup(_vertexShowPosition, _vertexStatus);
        if (_vertexShowPosition)
        {
            DoVertex();
        }

        EditorGUI.EndFoldoutHeaderGroup();
    }


    void HandleLOD()
    {
        _LODShowPosition = EditorGUILayout.BeginFoldoutHeaderGroup(_LODShowPosition, _LODStatus);

        if (_LODShowPosition)
        {
            DoLOD();
        }

        EditorGUI.EndFoldoutHeaderGroup();
    }

    void HandleDrawDistance()
    {      
        _DrawDistanceShowPosition = EditorGUILayout.BeginFoldoutHeaderGroup(_DrawDistanceShowPosition, _DrawDistanceStatus);

        if (_DrawDistanceShowPosition)
        {
            DoDrawDistance();
        }

        EditorGUI.EndFoldoutHeaderGroup();
    }

    void HandleAdvancedOptions()
    {
        EditorGUIUtility.labelWidth = 280;
        _advancedOptionsShowPosition = EditorGUILayout.BeginFoldoutHeaderGroup(_advancedOptionsShowPosition, _advancedOptionsStatus);

        if (_advancedOptionsShowPosition)
        {
            DoZWrite();
            DoColorMask();
            DoStencilComparison();
            DoStencilPass();
            DoReferenceValue();

            DoRenderQueue();
        }

        EditorGUI.EndFoldoutHeaderGroup();

    }


    void HandleVertexAnimation()
    {
        _AnimatedVertexPosition = EditorGUILayout.BeginFoldoutHeaderGroup(_AnimatedVertexPosition, _animatedVertexStatus);

        if (_AnimatedVertexPosition)
        {
            DoAnimatedVertexMovement();
        }

        EditorGUI.EndFoldoutHeaderGroup();
    }


    void DoMainTexture()
    {
  
        // mainTexture = (Texture2D)EditorGUILayout.ObjectField(mainTexture, typeof(Texture2D), false);

        MaterialProperty mainTex = FindProperty("_MainTex");
        GUIContent albedoLabel = MakeLabel("Main Texture", "Main Texture (Set filtering to Point in the texture settings for better results)");

        editor.TextureProperty(mainTex, albedoLabel.text);
    }

    void DoNormals()
    {
 
        MaterialProperty normalTex = FindProperty("_BumpMap");
        GUIContent normalLabel = MakeLabel("Normal Map", "Normal Map Texture (Use a NON-Normal Map Texture for some cool reflective effects)");
        editor.ShaderProperty(normalTex, normalLabel);

 
        MaterialProperty slider = FindProperty("_BumpScale");
        editor.ShaderProperty(slider, MakeLabel("Normal Strength", "Normal Map Strength (For values above 10 or below -10, the result does't really change)"));


        MaterialProperty colorTint = FindProperty("_ColorTint");
        GUIContent colorTintLabel = MakeLabel("Color Tint", "Color tint applied to the main texture (Set Alpha to 0, If you want to set a material as an stencil mask)");

        editor.ColorProperty(colorTint, colorTintLabel.text);

    }

    void DoFiltering()
    {
        MaterialProperty filterProperty = FindProperty("_Filtering");
        EditorGUI.BeginChangeCheck();

        editor.ShaderProperty(filterProperty, MakeLabel("Filtering Mode", "Only applied to the main Texture"));

    }

    void DoAffineMapping()
    {
        MaterialProperty affine = FindProperty("_AffineMappingToggle");
        GUIContent affineLabel = MakeLabel("Enable Affine Mapping", "Emulates the texture warping seen in the original PSX");
        editor.ShaderProperty(affine, affineLabel);

        if (affine.floatValue == 1)
        {
            MaterialProperty affineStrength = FindProperty("_AffineMappingStrength");
            GUIContent affineStrengthLabel = MakeLabel("Affine Mapping Strength", "Controls the strength of the affine mapping effect");
            editor.ShaderProperty(affineStrength, affineStrengthLabel);
        }
    }

    void DoTexturePixelization()
    {
        MaterialProperty pixelization = FindProperty("_PixelationToggle");
        GUIContent pixelizationLabel = MakeLabel("Enable Texture Pixelization", "For a better result disable mip-mapping and select 'Point' in the texture import settings");
        editor.ShaderProperty(pixelization, pixelizationLabel);

        if (pixelization.floatValue == 1)
        {
            MaterialProperty pixelizationFactor = FindProperty("_PixelationFactor");
            GUIContent pixelizationFactorLabel = MakeLabel("Pixelization Factor", "Determines how much pixelization is gonna be applied to the main texture and it's normal");
            editor.ShaderProperty(pixelizationFactor, pixelizationFactorLabel);
        }
    }

    void DoColorPrecision()
    {
        MaterialProperty colorPrecision = FindProperty("_ColorPrecisionToggle");
        GUIContent colorPrecisionLabel = MakeLabel("Enable Color Precision", "Reduces the number of colors used by the textures");
        editor.ShaderProperty(colorPrecision, colorPrecisionLabel);

        if (colorPrecision.floatValue == 1)
        {
            MaterialProperty _ColorPrecision = FindProperty("_ColorPrecision");
            GUIContent _ColorPrecisionLabel = MakeLabel("Color Precision", "Determines how much pixelization is gonna be applied to the main texture and it's normal");
            editor.ShaderProperty(_ColorPrecision, _ColorPrecisionLabel);
        }
    }

    void DoLightingModel()
    {
        MaterialProperty lightModel = FindProperty("_LightModel");
        GUIContent lightModelLabel = MakeLabel("Lighting Model", "");
        editor.ShaderProperty(lightModel, lightModelLabel);

        if (lightModel.floatValue != 0)
        {
            
            if (lightModel.floatValue == 1)
            {
                MaterialProperty additionalLightsPerVertex = FindProperty("_AdditionalLightsPerVertex");
                GUIContent additionalLightsPerVertexLabel = MakeLabel("Additional Lights Contribution", "");
                editor.ShaderProperty(additionalLightsPerVertex, additionalLightsPerVertexLabel);
            }

            if (lightModel.floatValue == 2)
            {
                MaterialProperty additionalLights = FindProperty("_AdditionalLights");
                GUIContent additionalLightsLabel = MakeLabel("Additional Lights Contribution", "Per Fragment/Pixel Lighting has some extra options that Per Vertex lighting doesn't have, options only available for the 'Per Fragment' lighting ('Per Vertex' Lighting only allows additional lights to contribute per vertex)");
                editor.ShaderProperty(additionalLights, additionalLightsLabel);
            }



            MaterialProperty attenuation = FindProperty("_Attenuation");
            GUIContent attenuationLabel = MakeLabel("Attenuation Factor", "");
            editor.ShaderProperty(attenuation, attenuationLabel);

            MaterialProperty smoothness = FindProperty("_MatSmoothness");
            GUIContent smoothnessLabel = MakeLabel("Smoothness", "");
            editor.ShaderProperty(smoothness, smoothnessLabel);
        
            MaterialProperty specularColor = FindProperty("_SpecularColor");
            GUIContent specularColorLabel = MakeLabel("Specular Color", "");
            editor.ShaderProperty(specularColor, specularColorLabel);
        
            MaterialProperty rimPower = FindProperty("_RimPower");
            GUIContent rimPowerLabel = MakeLabel("Rim Factor", "");
            editor.ShaderProperty(rimPower, rimPowerLabel);
        
            MaterialProperty rimColor = FindProperty("_RimColor");
            GUIContent rimColorLabel = MakeLabel("Rim Color", "");
            editor.ShaderProperty(rimColor, rimColorLabel);
        
            MaterialProperty ambientColor = FindProperty("_CustomAmbientColor");
            GUIContent ambientColorLabel = MakeLabel("Ambient Color", "");
            editor.ShaderProperty(ambientColor, ambientColorLabel);
        
            MaterialProperty customLightDirectionToggle = FindProperty("_CustomLightDirectionToggle");
            GUIContent customLightDirectionToggleLabel = MakeLabel("Enable Custom Light Direction", "");
            editor.ShaderProperty(customLightDirectionToggle, customLightDirectionToggleLabel);

            if (customLightDirectionToggle.floatValue == 1)
            {
                MaterialProperty customLightDirection = FindProperty("_CustomLightDirection");
                GUIContent customLightDirectionLabel = MakeLabel("Custom Light Direction", "");
                editor.ShaderProperty(customLightDirection, customLightDirectionLabel);
            }
        }



    }

    void DoVertex()
    {
        MaterialProperty vertexColorsToggle = FindProperty("_VertexColorsToggle");
        GUIContent vertexColorsToggleLabel  = MakeLabel("Enable Vertex Colors", "");
        editor.ShaderProperty(vertexColorsToggle, vertexColorsToggleLabel);


        MaterialProperty vertexJitterToggle = FindProperty("_VertexJitterToggle");
        GUIContent vertexJitterLabel        = MakeLabel("Disable Vertex Precision", "");
        editor.ShaderProperty(vertexJitterToggle, vertexJitterLabel);

        if (vertexJitterToggle.floatValue == 1)
        {
            MaterialProperty vertexResolution = FindProperty("_vertexResolution");
            GUIContent vertexResolutionLabel  = MakeLabel("New Vertex Precision", "");
            editor.ShaderProperty(vertexResolution, vertexResolutionLabel);
        }

    }

    void DoLOD()
    {
        MaterialProperty lod = FindProperty("_EnableLODToggle");
        GUIContent lodLabel = MakeLabel("Enable LOD", "Enables an LOD system as seen in the Spyro trilogy, where they had up to seven layers of Levels of Detail");
        editor.ShaderProperty(lod, lodLabel);

        if (lod.floatValue == 1 || lod.floatValue == 3)
        {
            MaterialProperty lodOverride = FindProperty("_LODOverrides");
            GUIContent LODOverrideLabel = MakeLabel("Override ", "Allows to set a list of values for how much precision a vertex should have, and how filtered or how pixelated a texture should look at certain camera distances");
            editor.ShaderProperty(lodOverride, LODOverrideLabel);


            EditorGUILayout.BeginHorizontal();

            EditorGUIUtility.labelWidth = 80;

            GUIContent fillLabel = MakeLabel("", "Just To Fill Space");
            EditorGUILayout.LabelField(fillLabel);

            if (lodOverride.intValue == 0 || lodOverride.intValue == 3 || lodOverride.intValue == 4 || lodOverride.intValue == 6)
            {
                GUIContent overrideVertexLabel = MakeLabel("Vertex Precision", "Allows to set a list of values for how much precision a vertex should have at certain camera distances");
                EditorGUILayout.LabelField(overrideVertexLabel);
            }

            if (lodOverride.intValue == 1 || lodOverride.intValue == 3 || lodOverride.intValue == 5 || lodOverride.intValue == 6)
            {
                GUIContent overrideFilterLabel = MakeLabel("Texture Filtering", "Allows to set a list of values for how filtered a texture should look at certain camera distances");
                EditorGUILayout.LabelField(overrideFilterLabel);
            }

            if (lodOverride.intValue == 2 || lodOverride.intValue == 4 || lodOverride.intValue == 5 || lodOverride.intValue == 6)
            {
                GUIContent overrideFilterLabel = MakeLabel("Texture Pixelization", "Allows to set a list of values for how pixelated a texture should look at certain camera distances");
                EditorGUILayout.LabelField(overrideFilterLabel);
            }
    
            GUIContent cameraDistanceLabel = MakeLabel("Camera Distance", "Camera Distance at which the different LOD's are applied");
            EditorGUILayout.LabelField(cameraDistanceLabel);

            EditorGUILayout.EndHorizontal();

           if (lodOverride.intValue == 0)
                {
                    for (int i = 1; i < 8; i++)
                    {
                        EditorGUIUtility.labelWidth = 80;
                        EditorGUILayout.BeginVertical();
                        MaterialProperty LOD = FindProperty("_LOD" + i);
                        Vector4 LODValues = target.GetVector(Shader.PropertyToID(LOD.name));

                        Vector4 newValues = LODValues;

                        EditorGUILayout.BeginHorizontal();
                        GUIContent overrideVertexLabel = MakeLabel("LOD [" + i + "]", "");
                        if (i == 1)
                            overrideVertexLabel = MakeLabel("LOD [" + i + "]", "Closest Level Of Detail");

                        if (i == 7)
                            overrideVertexLabel = MakeLabel("LOD [" + i + "]", "Farthest Level Of Detail");
                        EditorGUILayout.LabelField(overrideVertexLabel);

                        newValues.x = EditorGUILayout.FloatField("", LODValues.x);
                        newValues.w = EditorGUILayout.FloatField("", LODValues.w);

                        target.SetVector(Shader.PropertyToID(LOD.name), newValues);


                        EditorGUILayout.EndHorizontal();
                        EditorGUILayout.EndVertical();
                  
                    }

                }

           if (lodOverride.intValue == 1)
                {
                    for (int i = 1; i < 8; i++)
                    {
                        EditorGUIUtility.labelWidth = 80;
                        EditorGUILayout.BeginVertical();
                        MaterialProperty LOD = FindProperty("_LOD" + i);
                        Vector4 LODValues = target.GetVector(Shader.PropertyToID(LOD.name));
                        Vector4 newValues = LODValues;

                        EditorGUILayout.BeginHorizontal();
                        GUIContent overrideVertexLabel = MakeLabel("LOD [" + i + "]", "");
                        if (i == 1)
                            overrideVertexLabel = MakeLabel("LOD [" + i + "]", "Closest Level Of Detail");

                        if (i == 7)
                            overrideVertexLabel = MakeLabel("LOD [" + i + "]", "Farthest Level Of Detail");
                        EditorGUILayout.LabelField(overrideVertexLabel);

                        newValues.y = EditorGUILayout.FloatField("", LODValues.y);
                        newValues.w = EditorGUILayout.FloatField("", LODValues.w);

                        target.SetVector(Shader.PropertyToID(LOD.name), newValues);

                        EditorGUILayout.EndHorizontal();
                        EditorGUILayout.EndVertical();
                    }
                }

           if (lodOverride.intValue == 2)
                {
                    for (int i = 1; i < 8; i++)
                    {
                        EditorGUIUtility.labelWidth = 80;
                        EditorGUILayout.BeginVertical();
                        MaterialProperty LOD = FindProperty("_LOD" + i);
                        Vector4 LODValues = target.GetVector(Shader.PropertyToID(LOD.name));
                        Vector4 newValues = LODValues;

                        EditorGUILayout.BeginHorizontal();
                        GUIContent overrideVertexLabel = MakeLabel("LOD [" + i + "]", "");
                        if (i == 1)
                            overrideVertexLabel = MakeLabel("LOD [" + i + "]", "Closest Level Of Detail");

                        if (i == 7)
                            overrideVertexLabel = MakeLabel("LOD [" + i + "]", "Farthest Level Of Detail");
                        EditorGUILayout.LabelField(overrideVertexLabel);

                        newValues.z = EditorGUILayout.FloatField("", LODValues.z);
                        newValues.w = EditorGUILayout.FloatField("", LODValues.w);

                        target.SetVector(Shader.PropertyToID(LOD.name), newValues);

                        EditorGUILayout.EndHorizontal();
                        EditorGUILayout.EndVertical();
                    }
                }

           if (lodOverride.intValue == 3)
                {
                    for (int i = 1; i < 8; i++)
                    {
                        EditorGUIUtility.labelWidth = 80;
                        EditorGUILayout.BeginVertical();
                        MaterialProperty LOD = FindProperty("_LOD" + i);
                        Vector4 LODValues = target.GetVector(Shader.PropertyToID(LOD.name));
                        Vector4 newValues = LODValues;

                        EditorGUILayout.BeginHorizontal();
                        GUIContent overrideVertexLabel = MakeLabel("LOD [" + i + "]", "");

                        if (i == 1)
                            overrideVertexLabel = MakeLabel("LOD [" + i + "]", "Closest Level Of Detail");

                        if (i == 7)
                            overrideVertexLabel = MakeLabel("LOD [" + i + "]", "Farthest Level Of Detail");

                        EditorGUILayout.LabelField(overrideVertexLabel);

                        newValues.x = EditorGUILayout.FloatField("", LODValues.x);
                        newValues.y = EditorGUILayout.FloatField("", LODValues.y);
                        newValues.w = EditorGUILayout.FloatField("", LODValues.w);

                        target.SetVector(Shader.PropertyToID(LOD.name), newValues);

                        EditorGUILayout.EndHorizontal();
                        EditorGUILayout.EndVertical();
                    }

                }

           if (lodOverride.intValue == 4)
                {
                    for (int i = 1; i < 8; i++)
                    {
                        EditorGUIUtility.labelWidth = 80;
                        EditorGUILayout.BeginVertical();
                        MaterialProperty LOD = FindProperty("_LOD" + i);
                        Vector4 LODValues = target.GetVector(Shader.PropertyToID(LOD.name));
                        Vector4 newValues = LODValues;

                        EditorGUILayout.BeginHorizontal();
                        GUIContent overrideVertexLabel = MakeLabel("LOD [" + i + "]", "");

                        if (i == 1)
                            overrideVertexLabel = MakeLabel("LOD [" + i + "]", "Closest Level Of Detail");

                        if (i == 7)
                            overrideVertexLabel = MakeLabel("LOD [" + i + "]", "Farthest Level Of Detail");

                        EditorGUILayout.LabelField(overrideVertexLabel);

                        newValues.x = EditorGUILayout.FloatField("", LODValues.x);
                        newValues.z = EditorGUILayout.FloatField("", LODValues.z);
                        newValues.w = EditorGUILayout.FloatField("", LODValues.w);

                        target.SetVector(Shader.PropertyToID(LOD.name), newValues);

                        EditorGUILayout.EndHorizontal();
                        EditorGUILayout.EndVertical();
                    }

                }

           if (lodOverride.intValue == 5)
                {
                    for (int i = 1; i < 8; i++)
                    {
                        EditorGUIUtility.labelWidth = 80;
                        EditorGUILayout.BeginVertical();
                        MaterialProperty LOD = FindProperty("_LOD" + i);
                        Vector4 LODValues = target.GetVector(Shader.PropertyToID(LOD.name));
                        Vector4 newValues = LODValues;

                        EditorGUILayout.BeginHorizontal();
                        GUIContent overrideVertexLabel = MakeLabel("LOD [" + i + "]", "");
                        if (i == 1)
                            overrideVertexLabel = MakeLabel("LOD [" + i + "]", "Closest Level Of Detail");

                        if (i == 7)
                            overrideVertexLabel = MakeLabel("LOD [" + i + "]", "Farthest Level Of Detail");
                        EditorGUILayout.LabelField(overrideVertexLabel);

                        newValues.y = EditorGUILayout.FloatField("", LODValues.y);
                        newValues.z = EditorGUILayout.FloatField("", LODValues.z);
                        newValues.w = EditorGUILayout.FloatField("", LODValues.w);

                        target.SetVector(Shader.PropertyToID(LOD.name), newValues);

                        EditorGUILayout.EndHorizontal();
                        EditorGUILayout.EndVertical();
                    }

                }

           if (lodOverride.intValue == 6)
                {
                    for (int i = 1; i < 8; i++)
                    {
                        EditorGUIUtility.labelWidth = 80;
                        EditorGUILayout.BeginVertical();
                        MaterialProperty LOD = FindProperty("_LOD" + i);
                        Vector4 LODValues = target.GetVector(Shader.PropertyToID(LOD.name));
                        Vector4 newValues = LODValues;

                        EditorGUILayout.BeginHorizontal();
                        GUIContent overrideVertexLabel = MakeLabel("LOD [" + i + "]", "");
                        if (i == 1)
                            overrideVertexLabel = MakeLabel("LOD [" + i + "]", "Closest Level Of Detail");

                        if (i == 7)
                            overrideVertexLabel = MakeLabel("LOD [" + i + "]", "Farthest Level Of Detail");
                        EditorGUILayout.LabelField(overrideVertexLabel);

                        newValues.x = EditorGUILayout.FloatField("", LODValues.x);
                        newValues.y = EditorGUILayout.FloatField("", LODValues.y);
                        newValues.z = EditorGUILayout.FloatField("", LODValues.z);
                        newValues.w = EditorGUILayout.FloatField("", LODValues.w);

                        target.SetVector(Shader.PropertyToID(LOD.name), newValues);

                        EditorGUILayout.EndHorizontal();
                        EditorGUILayout.EndVertical();
                    }

                }
       
        }

        if (lod.floatValue == 2 || lod.floatValue == 3)
        {

            EditorGUILayout.BeginHorizontal();

            EditorGUIUtility.labelWidth = 80;

            GUIContent fillLabel2 = MakeLabel("", "Just To Fill Space");
            EditorGUILayout.LabelField(fillLabel2);


 
            GUIContent overrideFilterLabel = MakeLabel("Custom Textures", "Allows to set a list of values for how filtered a texture should look at certain camera distances");
            EditorGUILayout.LabelField(overrideFilterLabel);

            GUIContent cameraDistanceLabel2 = MakeLabel("Camera Distance", "Camera Distance at which the different LOD's are applied");
            EditorGUILayout.LabelField(cameraDistanceLabel2);
 
            EditorGUILayout.EndHorizontal();

 
            
            for (int i = 1; i < 8; i++)
            {
                EditorGUIUtility.labelWidth = 80;
                EditorGUILayout.BeginVertical();

                MaterialProperty CLODTex = FindProperty("_CLOD" + i + "Tex");
                Texture CLODValues = target.GetTexture(Shader.PropertyToID(CLODTex.name));

                MaterialProperty LODCameraDistance = FindProperty("_LOD" + i);
                Vector4 LODCameraDistanceValues = target.GetVector(Shader.PropertyToID(LODCameraDistance.name));

                Vector4 newValues = LODCameraDistanceValues;


                EditorGUILayout.BeginHorizontal();
    
                GUIContent overrideLODLabel = MakeLabel("LOD [" + i + "]", "");
                if (i == 1)
                    overrideLODLabel = MakeLabel("LOD [" + i + "]", "Closest Level Of Detail");
                if (i == 7)
                    overrideLODLabel = MakeLabel("LOD [" + i + "]", "Farthest Level Of Detail");

                EditorGUILayout.LabelField(overrideLODLabel);
 
                editor.ShaderProperty(CLODTex, "");

                        
                newValues.w = EditorGUILayout.FloatField("", LODCameraDistanceValues.w);

                target.SetVector(Shader.PropertyToID(LODCameraDistance.name), newValues);


                EditorGUILayout.EndHorizontal();
                EditorGUILayout.EndVertical();

            }

        }
    }

    void DoDrawDistance()
    {
        MaterialProperty draw = FindProperty("_DrawDistanceToggle");
        GUIContent drawLabel = MakeLabel("Enable Draw Distance", "When you enable draw distance, it overrides the set LOD Parameters for any distance greater than the maximum draw distance");

        editor.ShaderProperty(draw, drawLabel);

        if (draw.floatValue == 1)
        {
            MaterialProperty maxDrawDistance = FindProperty("_MaxDrawDistance");
            GUIContent maxDrawDistanceLabel = MakeLabel("Maximum Draw Distance", "");

            editor.ShaderProperty(maxDrawDistance, maxDrawDistanceLabel);
        }

    }


    void DoAnimatedVertexMovement()
    {
        MaterialProperty toggle = FindProperty("_EnableAnimatedVertexToggle");
        MaterialProperty draw   = FindProperty("_animVertTex");
                      
        GUIContent drawLabel    = MakeLabel   ("Enable Animated Vertex", "When you enable animated vertex, It lets you apply a texture to be evaluated at each vertex and modify their position");

        editor.ShaderProperty(toggle, drawLabel);

        if (toggle.floatValue == 1)
        {
            MaterialProperty maxDrawDistance = FindProperty("_animVertTex");
            GUIContent maxDrawDistanceLabel  = MakeLabel("Maximum Draw Distance", "");            
            editor.ShaderProperty(maxDrawDistance, maxDrawDistanceLabel);

            MaterialProperty speed = FindProperty("_Speed");
            GUIContent speedLabel = MakeLabel("Displacement Speed", "");
            editor.ShaderProperty(speed, speedLabel);

            MaterialProperty amplitude = FindProperty("_Amplitude");
            GUIContent aLabel = MakeLabel("Displacement Amplitude", "");
            editor.ShaderProperty(amplitude, aLabel);

            MaterialProperty scale = FindProperty("_Scale");
            GUIContent scaleLabel = MakeLabel("Displacement Scale", "");
            editor.ShaderProperty(scale, scaleLabel);
        }

    }



    void DoZWrite()
    {
        MaterialProperty zWrite = FindProperty("_ZWriteMode");
        GUIContent zWriteLabel = MakeLabel("ZWrite Mode", "");
        editor.ShaderProperty(zWrite, zWriteLabel);
    }

    void DoCulling()
    {
        MaterialProperty cull = FindProperty("_CullMode");
        GUIContent cullLabel  = MakeLabel("Culling Mode", "");
        editor.ShaderProperty(cull, cullLabel);
    }

    void DoAlphaMask()
    {
        MaterialProperty alphaMask = FindProperty("_AlphaMaskMode");
        GUIContent alphaMaskLabel  = MakeLabel("Alpha Mask Mode", "");
        editor.ShaderProperty(alphaMask, alphaMaskLabel);
    }

    void DoColorMask()
    {
        MaterialProperty colorMask = FindProperty("_ColorMask");
        GUIContent colorMaskLabel  = MakeLabel("Color Mask", "Sets the color channel writing mask, which prevents the GPU from writing to channels in the render target.");

        editor.ShaderProperty(colorMask, colorMaskLabel);
    }

    void DoStencilComparison()
    {
        MaterialProperty comparison = FindProperty("_ComparisonMode");
        GUIContent comparisonLabel  = MakeLabel("Stencil Comparison Mode", "");
        editor.ShaderProperty(comparison, comparisonLabel);
    }

    void DoStencilPass()
    {
        MaterialProperty passMode = FindProperty("_PassMode");
        GUIContent passLabel      = MakeLabel("Stencil Operation Mode", "");
        editor.ShaderProperty(passMode, passLabel);
    }

    void DoReferenceValue()
    {
        MaterialProperty reference = FindProperty("_RefValue");
        GUIContent referenceLabel  = MakeLabel("Reference Value", "");
        editor.ShaderProperty(reference, referenceLabel);
    }

    void DoRenderQueue()
    {
        editor.RenderQueueField();
    }
 

    MaterialProperty FindProperty(string name)
    {
        return FindProperty(name, properties);
    }

    static GUIContent MakeLabel(string text, string tooltip)
    {
        staticLabel.text    = text;
        staticLabel.tooltip = tooltip;
        return staticLabel;
    }

}
