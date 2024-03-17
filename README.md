# MIDNIGHT PSX SHADER

**Midnight PSX Shader** is a fully functional shader made using HLSL that **brings** the original limitations of the PS1 era within the reach of a click. It allows you to create the very look you want for your game/project without needing to touch any code. It is the most flexible shader out there, and the best part is, it's **FREE!**

**Things that the Midnight PSX Shader Can Do:**

**Texture Mapping:**

-   Affine Texture Mapping
-   Texture Filtering
-   Texture Pixelization

**Mapping and Lighting Enhancements:**

-   Normal Mapping (Per Fragment Only)
-   Reflectivity Tricks with a NON-Normal Map as the Normal Input
-   Rim Lighting
-   Toon Shading (Achievable due to the Lighting level of customization)
-   Metallic And Reflective Shading (Achievable due to the Lighting level of customization)

**Lighting Customization:**

-   Custom Lambert + Specular Light Model Per Vertex
-   Custom Lambert + Specular Light Model Per Fragment
-   Customizeable Lighting (Modify every setting used to compute the final pixel color)
-   Multiple Light Sources:
    -   Influencing the final color Per Vertex (Main Light + n Spotlights)
    -   Influencing the final color Per Fragment (Main Light + n Spotlights)
    -   Additional Lights can be disabled or contribute to the final per fragment lighting per Vertex or Per Fragment

**Level of Detail (LOD) Modes:**

-   Dynamic Customizable LOD Mode (Handles dynamic vertex jittering, texture filtering, and texture pixelization)
-   Custom LOD Mode (Allows you to set custom textures for the different LOD levels)
-    You can combine both Dynamic and Custom LODs to achieve a wider range of effects


**Additional Features:**

-   Toggle the Vertex colors painted onto the model On/Off effortlessly
-   Draw Distance Toggle
-   Stencil Mode; Comparison, Pass, and Ref Value (Achieve impossible rooms effects (Non-Euclidean Spaces) and more)
-   Culling Mode
-   ZWrite Mode
-   Color Mask
-   Alpha Mask Mode


**Additional vertical fog shader included**

## Effects Examples

| LOD Dynamic Texture Pixelization | Vertex Colors Toggle |
|----------------------------------|----------------------|
| ![LOD Dynamic Texture Pixelization](Media/Dynamic_Pixelization_2.gif) | ![Vertex Colors Toggle](Media/VertexColors.gif) |
| Not Spyro, Using the actual Shader |    |


## Effects Explanation

## NOTES
- Enabling **Dynamic LOD** has the option to **override** the **Texture Pixelization, Texture Filtering and Vertex Jittering** default settings, **giving you an extra layer of customization**.
- You can also enable Dynamic LOD and Custom LOD to mix the Texture Pixelization, Vertex Jittering and Custom Textures
- Texture Filtering Won't work with custom LOD
- **Set all your textures to point filter** in the texture settings if you want the best results.
- For a **cleaner result** while using Texture Filtering and Texture Pixelization **disable Mip Mapping** in your texture settings.
- Texture Filtering and Texture Pixelization **won't work** with Alpha Cut Outs.



## Custom Lighting Model 

The shader doesn't just crunch numbers; it embodies a custom lighting model meticulously crafted to evoke the distinctive feel and aesthetics of the original PlayStation era. With every calculation, we're not merely simulating; we're conjuring the very essence of what made PS1 games so enchanting. It's akin to embarking on a journey through time, transporting you back to those immersive late-night gaming sessions where each pixel held boundless adventure.

Whether you're a seasoned shader wizard, deftly weaving digital spells with code, or simply a nostalgic gamer longing to revive that retro charm, this bespoke lighting model is your gateway to the ultimate nostalgia trip. So fasten your seatbelt, flex those thumbs, and prepare to elevate your shader prowess to unprecedented levels as we unleash the unparalleled force of PS1 nostalgia like never before!

This step calculates the normalized direction vector of the vertex normal in object space. It discards the W component to ensure that only the directional information is retained. This directional information is crucial for lighting calculations as it determines how the surface reflects light.

$$
\overrightarrow{ND} = \frac{(\vec v.normal * [WorldToObject]).xyz}{||ND||}
$$

Computes the direction from the current vertex to the camera or viewer position in world space. Understanding where the viewer is looking from is essential for simulating realistic lighting effects such as specular highlights and reflections.

$$
\overrightarrow{VD} = \frac{(\overrightarrow{WorldSpaceCameraPosition} - ([ObjectToWorld] * \vec v.pos))} {||VD||}
$$

This step determines the direction of the light source in world space. It's crucial for both diffuse and specular lighting calculations. Depending on the setup, either the direction to a predefined light source (`WorldSpaceLight0`) or a custom light direction (`CustomLightDirection`) is used.

$$
\overrightarrow{LD} = \frac{\overrightarrow{WorldSpaceLight0}} {||WorldSpaceLight0||} or  \frac{\overrightarrow{CustomLightDirection}} {||CustomLightDirection||} 
$$

Diffuse reflections represent the light that is scattered uniformly in all directions upon hitting a surface. This calculation considers the angle between the vertex normal and the light direction, which determines how much light is reflected.

$$
\overrightarrow{DR} = atten * \overrightarrow{LightColor0} * dot(\overrightarrow{ND}, \overrightarrow{LD})
$$

Specular reflections are the highlights that appear on shiny surfaces when illuminated. This calculation involves computing the reflection of the light direction about the vertex normal (using the `reflect` function). It then determines how much of this reflected light aligns with the view direction, modulated by the material's smoothness.

$$
\overrightarrow{SR} = \overrightarrow{SpecularColor} * max(0, dot(\overrightarrow{ND}, \frac{\overrightarrow{LD}} {4})) * (max(0, dot(reflect(\frac{\overrightarrow{-LD}} {4}, \overrightarrow{ND}), \overrightarrow{VD})), Smoothness)
$$

This step calculates the outline effect by determining the angle between the view direction and the vertex normal. 

$$
\overrightarrow{OL} = 1 - saturate(dot(\frac{\overrightarrow{VD}}{||VD||}, \overrightarrow{ND}))
$$

Rim lighting simulates the effect of light scattering along the edges of objects, creating a rim or halo effect. It combines the light color with the rim color based on the angle between the vertex normal and the light direction, modulated by the outline factor and rim power.

$$
\overrightarrow{RL} = atten * \overrightarrow{LightColor0} * \overrightarrow{RimColor} * saturate(dot(\overrightarrow{ND}, \overrightarrow{LD})) * pow(\overrightarrow{OL}, RimPower) 
$$

The pixel's color is computed by combining the diffuse reflections, specular reflections, rim lighting, and any ambient color contribution. This is the culmination of all the lighting calculations and determines the visual appearance of the rendered object.

$$
\overrightarrow{FL} = \overrightarrow{DR} + \overrightarrow{SR} + \overrightarrow{RL} + \overrightarrow{CustomAmbientColor}     
$$




