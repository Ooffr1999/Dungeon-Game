Shader "Ooffr/See-Through"
{
    Properties
    {
        [NoScaleOffset] Main_Texture("Main Texture", 2D) = "white" {}
        Tint("Tint", Color) = (1, 1, 1, 0)
        _playerPosition("PlayerPosition", Vector) = (0.5, 0.5, 0, 0)
        _size("Sphere Size", Float) = 1
        Smoothness("Smoothness", Range(0, 1)) = 0.5
        Opacity("Opacity", Range(0, 3)) = 1
        ScrollTime("ScrollTime", Range(0, 2)) = 0.1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue" = "Transparent"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma multi_compile_fog
    #pragma multi_compile _ DOTS_INSTANCING_ON
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
    #pragma multi_compile _ LIGHTMAP_ON
    #pragma multi_compile _ DIRLIGHTMAP_COMBINED
    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
    #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
    #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
    #pragma multi_compile _ _SHADOWS_SOFT
    #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
    #pragma multi_compile _ SHADOWS_SHADOWMASK
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float3 normalWS;
        float4 tangentWS;
        float4 texCoord0;
        float3 viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        float2 lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 sh;
        #endif
        float4 fogFactorAndVertexLight;
        float4 shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 TangentSpaceNormal;
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float4 uv0;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float3 interp1 : TEXCOORD1;
        float4 interp2 : TEXCOORD2;
        float4 interp3 : TEXCOORD3;
        float3 interp4 : TEXCOORD4;
        #if defined(LIGHTMAP_ON)
        float2 interp5 : TEXCOORD5;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 interp6 : TEXCOORD6;
        #endif
        float4 interp7 : TEXCOORD7;
        float4 interp8 : TEXCOORD8;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyz = input.normalWS;
        output.interp2.xyzw = input.tangentWS;
        output.interp3.xyzw = input.texCoord0;
        output.interp4.xyz = input.viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        output.interp5.xy = input.lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.interp6.xyz = input.sh;
        #endif
        output.interp7.xyzw = input.fogFactorAndVertexLight;
        output.interp8.xyzw = input.shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.normalWS = input.interp1.xyz;
        output.tangentWS = input.interp2.xyzw;
        output.texCoord0 = input.interp3.xyzw;
        output.viewDirectionWS = input.interp4.xyz;
        #if defined(LIGHTMAP_ON)
        output.lightmapUV = input.interp5.xy;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.sh = input.interp6.xyz;
        #endif
        output.fogFactorAndVertexLight = input.interp7.xyzw;
        output.shadowCoord = input.interp8.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 Main_Texture_TexelSize;
float4 Tint;
float2 _playerPosition;
float _size;
float Smoothness;
float Opacity;
float ScrollTime;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(Main_Texture);
SAMPLER(samplerMain_Texture);

// Graph Functions

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
    Out = A * B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Clamp_float(float In, float Min, float Max, out float Out)
{
    Out = clamp(In, Min, Max);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float3 NormalTS;
    float3 Emission;
    float Metallic;
    float Smoothness;
    float Occlusion;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    UnityTexture2D _Property_c4b770cbab1e464b89603a1721aeea07_Out_0 = UnityBuildTexture2DStructNoScale(Main_Texture);
    float4 _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0 = SAMPLE_TEXTURE2D(_Property_c4b770cbab1e464b89603a1721aeea07_Out_0.tex, _Property_c4b770cbab1e464b89603a1721aeea07_Out_0.samplerstate, IN.uv0.xy);
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_R_4 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.r;
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_G_5 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.g;
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_B_6 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.b;
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_A_7 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.a;
    float4 _Property_424965800e2046b8841548422bac7057_Out_0 = Tint;
    float4 _Multiply_1e0d82cb0edf4f2a9f53fb0f5e000e84_Out_2;
    Unity_Multiply_float(_SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0, _Property_424965800e2046b8841548422bac7057_Out_0, _Multiply_1e0d82cb0edf4f2a9f53fb0f5e000e84_Out_2);
    float4 _ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float _Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0 = ScrollTime;
    float _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2;
    Unity_Multiply_float(_Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0, IN.TimeParameters.x, _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2);
    float2 _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0.xy), float2 (1, 1), (_Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2.xx), _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3);
    float _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2;
    Unity_GradientNoise_float(_TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3, 10, _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2);
    float _Property_a152fa67057c46e880ce80c413044693_Out_0 = Smoothness;
    float4 _ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_b4a03a33e8004826a9d486b83be156d2_Out_0 = _playerPosition;
    float2 _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3;
    Unity_Remap_float2(_Property_b4a03a33e8004826a9d486b83be156d2_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3);
    float2 _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2;
    Unity_Add_float2((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3, _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2);
    float2 _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), float2 (1, 1), _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2, _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3);
    float2 _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2;
    Unity_Multiply_float(_TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3, float2(2, 2), _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2);
    float2 _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2;
    Unity_Subtract_float2(_Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2, float2(1, 1), _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2);
    float _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2);
    float _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0 = _size;
    float _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2;
    Unity_Multiply_float(_Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0, _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2);
    float2 _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0 = float2(_Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0);
    float2 _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2;
    Unity_Divide_float2(_Subtract_ec003425fddd450a952607a75b1c01d1_Out_2, _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0, _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2);
    float _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1;
    Unity_Length_float2(_Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2, _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1);
    float _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1;
    Unity_OneMinus_float(_Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1, _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1);
    float _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1;
    Unity_Saturate_float(_OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1);
    float _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3;
    Unity_Smoothstep_float(0, _Property_a152fa67057c46e880ce80c413044693_Out_0, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3);
    float _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2;
    Unity_Multiply_float(_GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2);
    float _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2;
    Unity_Add_float(_Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2);
    float _Property_ccc6c4f29c884e439e3da633449251c6_Out_0 = Opacity;
    float _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2;
    Unity_Multiply_float(_Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2, _Property_ccc6c4f29c884e439e3da633449251c6_Out_0, _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2);
    float _Clamp_bcce38c6417842408407dc2161c368a6_Out_3;
    Unity_Clamp_float(_Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2, 0, 1, _Clamp_bcce38c6417842408407dc2161c368a6_Out_3);
    float _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    Unity_OneMinus_float(_Clamp_bcce38c6417842408407dc2161c368a6_Out_3, _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1);
    surface.BaseColor = (_Multiply_1e0d82cb0edf4f2a9f53fb0f5e000e84_Out_2.xyz);
    surface.NormalTS = IN.TangentSpaceNormal;
    surface.Emission = float3(0, 0, 0);
    surface.Metallic = 0;
    surface.Smoothness = 0.5;
    surface.Occlusion = 1;
    surface.Alpha = _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    output.uv0 = input.texCoord0;
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "GBuffer"
    Tags
    {
        "LightMode" = "UniversalGBuffer"
    }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma multi_compile_fog
    #pragma multi_compile _ DOTS_INSTANCING_ON
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
    #pragma multi_compile _ DIRLIGHTMAP_COMBINED
    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
    #pragma multi_compile _ _SHADOWS_SOFT
    #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
    #pragma multi_compile _ _GBUFFER_NORMALS_OCT
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float3 normalWS;
        float4 tangentWS;
        float4 texCoord0;
        float3 viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        float2 lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 sh;
        #endif
        float4 fogFactorAndVertexLight;
        float4 shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 TangentSpaceNormal;
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float4 uv0;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float3 interp1 : TEXCOORD1;
        float4 interp2 : TEXCOORD2;
        float4 interp3 : TEXCOORD3;
        float3 interp4 : TEXCOORD4;
        #if defined(LIGHTMAP_ON)
        float2 interp5 : TEXCOORD5;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 interp6 : TEXCOORD6;
        #endif
        float4 interp7 : TEXCOORD7;
        float4 interp8 : TEXCOORD8;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyz = input.normalWS;
        output.interp2.xyzw = input.tangentWS;
        output.interp3.xyzw = input.texCoord0;
        output.interp4.xyz = input.viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        output.interp5.xy = input.lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.interp6.xyz = input.sh;
        #endif
        output.interp7.xyzw = input.fogFactorAndVertexLight;
        output.interp8.xyzw = input.shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.normalWS = input.interp1.xyz;
        output.tangentWS = input.interp2.xyzw;
        output.texCoord0 = input.interp3.xyzw;
        output.viewDirectionWS = input.interp4.xyz;
        #if defined(LIGHTMAP_ON)
        output.lightmapUV = input.interp5.xy;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.sh = input.interp6.xyz;
        #endif
        output.fogFactorAndVertexLight = input.interp7.xyzw;
        output.shadowCoord = input.interp8.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 Main_Texture_TexelSize;
float4 Tint;
float2 _playerPosition;
float _size;
float Smoothness;
float Opacity;
float ScrollTime;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(Main_Texture);
SAMPLER(samplerMain_Texture);

// Graph Functions

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
    Out = A * B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Clamp_float(float In, float Min, float Max, out float Out)
{
    Out = clamp(In, Min, Max);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float3 NormalTS;
    float3 Emission;
    float Metallic;
    float Smoothness;
    float Occlusion;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    UnityTexture2D _Property_c4b770cbab1e464b89603a1721aeea07_Out_0 = UnityBuildTexture2DStructNoScale(Main_Texture);
    float4 _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0 = SAMPLE_TEXTURE2D(_Property_c4b770cbab1e464b89603a1721aeea07_Out_0.tex, _Property_c4b770cbab1e464b89603a1721aeea07_Out_0.samplerstate, IN.uv0.xy);
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_R_4 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.r;
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_G_5 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.g;
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_B_6 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.b;
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_A_7 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.a;
    float4 _Property_424965800e2046b8841548422bac7057_Out_0 = Tint;
    float4 _Multiply_1e0d82cb0edf4f2a9f53fb0f5e000e84_Out_2;
    Unity_Multiply_float(_SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0, _Property_424965800e2046b8841548422bac7057_Out_0, _Multiply_1e0d82cb0edf4f2a9f53fb0f5e000e84_Out_2);
    float4 _ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float _Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0 = ScrollTime;
    float _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2;
    Unity_Multiply_float(_Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0, IN.TimeParameters.x, _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2);
    float2 _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0.xy), float2 (1, 1), (_Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2.xx), _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3);
    float _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2;
    Unity_GradientNoise_float(_TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3, 10, _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2);
    float _Property_a152fa67057c46e880ce80c413044693_Out_0 = Smoothness;
    float4 _ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_b4a03a33e8004826a9d486b83be156d2_Out_0 = _playerPosition;
    float2 _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3;
    Unity_Remap_float2(_Property_b4a03a33e8004826a9d486b83be156d2_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3);
    float2 _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2;
    Unity_Add_float2((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3, _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2);
    float2 _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), float2 (1, 1), _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2, _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3);
    float2 _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2;
    Unity_Multiply_float(_TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3, float2(2, 2), _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2);
    float2 _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2;
    Unity_Subtract_float2(_Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2, float2(1, 1), _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2);
    float _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2);
    float _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0 = _size;
    float _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2;
    Unity_Multiply_float(_Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0, _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2);
    float2 _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0 = float2(_Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0);
    float2 _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2;
    Unity_Divide_float2(_Subtract_ec003425fddd450a952607a75b1c01d1_Out_2, _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0, _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2);
    float _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1;
    Unity_Length_float2(_Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2, _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1);
    float _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1;
    Unity_OneMinus_float(_Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1, _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1);
    float _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1;
    Unity_Saturate_float(_OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1);
    float _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3;
    Unity_Smoothstep_float(0, _Property_a152fa67057c46e880ce80c413044693_Out_0, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3);
    float _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2;
    Unity_Multiply_float(_GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2);
    float _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2;
    Unity_Add_float(_Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2);
    float _Property_ccc6c4f29c884e439e3da633449251c6_Out_0 = Opacity;
    float _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2;
    Unity_Multiply_float(_Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2, _Property_ccc6c4f29c884e439e3da633449251c6_Out_0, _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2);
    float _Clamp_bcce38c6417842408407dc2161c368a6_Out_3;
    Unity_Clamp_float(_Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2, 0, 1, _Clamp_bcce38c6417842408407dc2161c368a6_Out_3);
    float _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    Unity_OneMinus_float(_Clamp_bcce38c6417842408407dc2161c368a6_Out_3, _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1);
    surface.BaseColor = (_Multiply_1e0d82cb0edf4f2a9f53fb0f5e000e84_Out_2.xyz);
    surface.NormalTS = IN.TangentSpaceNormal;
    surface.Emission = float3(0, 0, 0);
    surface.Metallic = 0;
    surface.Smoothness = 0.5;
    surface.Occlusion = 1;
    surface.Alpha = _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    output.uv0 = input.texCoord0;
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "ShadowCaster"
    Tags
    {
        "LightMode" = "ShadowCaster"
    }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite On
    ColorMask 0

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma multi_compile _ DOTS_INSTANCING_ON
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 Main_Texture_TexelSize;
float4 Tint;
float2 _playerPosition;
float _size;
float Smoothness;
float Opacity;
float ScrollTime;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(Main_Texture);
SAMPLER(samplerMain_Texture);

// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Clamp_float(float In, float Min, float Max, out float Out)
{
    Out = clamp(In, Min, Max);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float4 _ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float _Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0 = ScrollTime;
    float _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2;
    Unity_Multiply_float(_Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0, IN.TimeParameters.x, _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2);
    float2 _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0.xy), float2 (1, 1), (_Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2.xx), _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3);
    float _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2;
    Unity_GradientNoise_float(_TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3, 10, _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2);
    float _Property_a152fa67057c46e880ce80c413044693_Out_0 = Smoothness;
    float4 _ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_b4a03a33e8004826a9d486b83be156d2_Out_0 = _playerPosition;
    float2 _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3;
    Unity_Remap_float2(_Property_b4a03a33e8004826a9d486b83be156d2_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3);
    float2 _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2;
    Unity_Add_float2((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3, _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2);
    float2 _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), float2 (1, 1), _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2, _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3);
    float2 _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2;
    Unity_Multiply_float(_TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3, float2(2, 2), _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2);
    float2 _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2;
    Unity_Subtract_float2(_Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2, float2(1, 1), _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2);
    float _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2);
    float _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0 = _size;
    float _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2;
    Unity_Multiply_float(_Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0, _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2);
    float2 _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0 = float2(_Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0);
    float2 _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2;
    Unity_Divide_float2(_Subtract_ec003425fddd450a952607a75b1c01d1_Out_2, _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0, _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2);
    float _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1;
    Unity_Length_float2(_Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2, _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1);
    float _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1;
    Unity_OneMinus_float(_Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1, _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1);
    float _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1;
    Unity_Saturate_float(_OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1);
    float _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3;
    Unity_Smoothstep_float(0, _Property_a152fa67057c46e880ce80c413044693_Out_0, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3);
    float _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2;
    Unity_Multiply_float(_GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2);
    float _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2;
    Unity_Add_float(_Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2);
    float _Property_ccc6c4f29c884e439e3da633449251c6_Out_0 = Opacity;
    float _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2;
    Unity_Multiply_float(_Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2, _Property_ccc6c4f29c884e439e3da633449251c6_Out_0, _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2);
    float _Clamp_bcce38c6417842408407dc2161c368a6_Out_3;
    Unity_Clamp_float(_Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2, 0, 1, _Clamp_bcce38c6417842408407dc2161c368a6_Out_3);
    float _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    Unity_OneMinus_float(_Clamp_bcce38c6417842408407dc2161c368a6_Out_3, _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1);
    surface.Alpha = _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "DepthOnly"
    Tags
    {
        "LightMode" = "DepthOnly"
    }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite On
    ColorMask 0

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma multi_compile _ DOTS_INSTANCING_ON
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 Main_Texture_TexelSize;
float4 Tint;
float2 _playerPosition;
float _size;
float Smoothness;
float Opacity;
float ScrollTime;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(Main_Texture);
SAMPLER(samplerMain_Texture);

// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Clamp_float(float In, float Min, float Max, out float Out)
{
    Out = clamp(In, Min, Max);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float4 _ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float _Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0 = ScrollTime;
    float _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2;
    Unity_Multiply_float(_Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0, IN.TimeParameters.x, _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2);
    float2 _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0.xy), float2 (1, 1), (_Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2.xx), _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3);
    float _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2;
    Unity_GradientNoise_float(_TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3, 10, _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2);
    float _Property_a152fa67057c46e880ce80c413044693_Out_0 = Smoothness;
    float4 _ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_b4a03a33e8004826a9d486b83be156d2_Out_0 = _playerPosition;
    float2 _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3;
    Unity_Remap_float2(_Property_b4a03a33e8004826a9d486b83be156d2_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3);
    float2 _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2;
    Unity_Add_float2((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3, _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2);
    float2 _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), float2 (1, 1), _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2, _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3);
    float2 _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2;
    Unity_Multiply_float(_TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3, float2(2, 2), _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2);
    float2 _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2;
    Unity_Subtract_float2(_Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2, float2(1, 1), _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2);
    float _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2);
    float _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0 = _size;
    float _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2;
    Unity_Multiply_float(_Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0, _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2);
    float2 _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0 = float2(_Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0);
    float2 _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2;
    Unity_Divide_float2(_Subtract_ec003425fddd450a952607a75b1c01d1_Out_2, _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0, _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2);
    float _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1;
    Unity_Length_float2(_Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2, _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1);
    float _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1;
    Unity_OneMinus_float(_Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1, _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1);
    float _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1;
    Unity_Saturate_float(_OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1);
    float _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3;
    Unity_Smoothstep_float(0, _Property_a152fa67057c46e880ce80c413044693_Out_0, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3);
    float _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2;
    Unity_Multiply_float(_GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2);
    float _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2;
    Unity_Add_float(_Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2);
    float _Property_ccc6c4f29c884e439e3da633449251c6_Out_0 = Opacity;
    float _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2;
    Unity_Multiply_float(_Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2, _Property_ccc6c4f29c884e439e3da633449251c6_Out_0, _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2);
    float _Clamp_bcce38c6417842408407dc2161c368a6_Out_3;
    Unity_Clamp_float(_Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2, 0, 1, _Clamp_bcce38c6417842408407dc2161c368a6_Out_3);
    float _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    Unity_OneMinus_float(_Clamp_bcce38c6417842408407dc2161c368a6_Out_3, _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1);
    surface.Alpha = _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "DepthNormals"
    Tags
    {
        "LightMode" = "DepthNormals"
    }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma multi_compile _ DOTS_INSTANCING_ON
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv1 : TEXCOORD1;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float3 normalWS;
        float4 tangentWS;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 TangentSpaceNormal;
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float3 interp1 : TEXCOORD1;
        float4 interp2 : TEXCOORD2;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyz = input.normalWS;
        output.interp2.xyzw = input.tangentWS;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.normalWS = input.interp1.xyz;
        output.tangentWS = input.interp2.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 Main_Texture_TexelSize;
float4 Tint;
float2 _playerPosition;
float _size;
float Smoothness;
float Opacity;
float ScrollTime;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(Main_Texture);
SAMPLER(samplerMain_Texture);

// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Clamp_float(float In, float Min, float Max, out float Out)
{
    Out = clamp(In, Min, Max);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 NormalTS;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float4 _ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float _Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0 = ScrollTime;
    float _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2;
    Unity_Multiply_float(_Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0, IN.TimeParameters.x, _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2);
    float2 _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0.xy), float2 (1, 1), (_Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2.xx), _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3);
    float _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2;
    Unity_GradientNoise_float(_TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3, 10, _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2);
    float _Property_a152fa67057c46e880ce80c413044693_Out_0 = Smoothness;
    float4 _ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_b4a03a33e8004826a9d486b83be156d2_Out_0 = _playerPosition;
    float2 _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3;
    Unity_Remap_float2(_Property_b4a03a33e8004826a9d486b83be156d2_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3);
    float2 _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2;
    Unity_Add_float2((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3, _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2);
    float2 _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), float2 (1, 1), _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2, _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3);
    float2 _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2;
    Unity_Multiply_float(_TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3, float2(2, 2), _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2);
    float2 _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2;
    Unity_Subtract_float2(_Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2, float2(1, 1), _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2);
    float _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2);
    float _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0 = _size;
    float _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2;
    Unity_Multiply_float(_Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0, _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2);
    float2 _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0 = float2(_Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0);
    float2 _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2;
    Unity_Divide_float2(_Subtract_ec003425fddd450a952607a75b1c01d1_Out_2, _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0, _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2);
    float _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1;
    Unity_Length_float2(_Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2, _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1);
    float _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1;
    Unity_OneMinus_float(_Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1, _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1);
    float _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1;
    Unity_Saturate_float(_OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1);
    float _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3;
    Unity_Smoothstep_float(0, _Property_a152fa67057c46e880ce80c413044693_Out_0, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3);
    float _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2;
    Unity_Multiply_float(_GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2);
    float _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2;
    Unity_Add_float(_Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2);
    float _Property_ccc6c4f29c884e439e3da633449251c6_Out_0 = Opacity;
    float _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2;
    Unity_Multiply_float(_Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2, _Property_ccc6c4f29c884e439e3da633449251c6_Out_0, _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2);
    float _Clamp_bcce38c6417842408407dc2161c368a6_Out_3;
    Unity_Clamp_float(_Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2, 0, 1, _Clamp_bcce38c6417842408407dc2161c368a6_Out_3);
    float _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    Unity_OneMinus_float(_Clamp_bcce38c6417842408407dc2161c368a6_Out_3, _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1);
    surface.NormalTS = IN.TangentSpaceNormal;
    surface.Alpha = _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "Meta"
    Tags
    {
        "LightMode" = "Meta"
    }

        // Render State
        Cull Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        float4 uv2 : TEXCOORD2;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float4 uv0;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float4 interp1 : TEXCOORD1;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.texCoord0 = input.interp1.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 Main_Texture_TexelSize;
float4 Tint;
float2 _playerPosition;
float _size;
float Smoothness;
float Opacity;
float ScrollTime;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(Main_Texture);
SAMPLER(samplerMain_Texture);

// Graph Functions

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
    Out = A * B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Clamp_float(float In, float Min, float Max, out float Out)
{
    Out = clamp(In, Min, Max);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float3 Emission;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    UnityTexture2D _Property_c4b770cbab1e464b89603a1721aeea07_Out_0 = UnityBuildTexture2DStructNoScale(Main_Texture);
    float4 _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0 = SAMPLE_TEXTURE2D(_Property_c4b770cbab1e464b89603a1721aeea07_Out_0.tex, _Property_c4b770cbab1e464b89603a1721aeea07_Out_0.samplerstate, IN.uv0.xy);
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_R_4 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.r;
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_G_5 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.g;
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_B_6 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.b;
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_A_7 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.a;
    float4 _Property_424965800e2046b8841548422bac7057_Out_0 = Tint;
    float4 _Multiply_1e0d82cb0edf4f2a9f53fb0f5e000e84_Out_2;
    Unity_Multiply_float(_SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0, _Property_424965800e2046b8841548422bac7057_Out_0, _Multiply_1e0d82cb0edf4f2a9f53fb0f5e000e84_Out_2);
    float4 _ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float _Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0 = ScrollTime;
    float _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2;
    Unity_Multiply_float(_Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0, IN.TimeParameters.x, _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2);
    float2 _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0.xy), float2 (1, 1), (_Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2.xx), _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3);
    float _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2;
    Unity_GradientNoise_float(_TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3, 10, _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2);
    float _Property_a152fa67057c46e880ce80c413044693_Out_0 = Smoothness;
    float4 _ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_b4a03a33e8004826a9d486b83be156d2_Out_0 = _playerPosition;
    float2 _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3;
    Unity_Remap_float2(_Property_b4a03a33e8004826a9d486b83be156d2_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3);
    float2 _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2;
    Unity_Add_float2((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3, _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2);
    float2 _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), float2 (1, 1), _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2, _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3);
    float2 _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2;
    Unity_Multiply_float(_TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3, float2(2, 2), _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2);
    float2 _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2;
    Unity_Subtract_float2(_Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2, float2(1, 1), _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2);
    float _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2);
    float _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0 = _size;
    float _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2;
    Unity_Multiply_float(_Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0, _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2);
    float2 _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0 = float2(_Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0);
    float2 _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2;
    Unity_Divide_float2(_Subtract_ec003425fddd450a952607a75b1c01d1_Out_2, _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0, _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2);
    float _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1;
    Unity_Length_float2(_Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2, _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1);
    float _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1;
    Unity_OneMinus_float(_Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1, _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1);
    float _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1;
    Unity_Saturate_float(_OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1);
    float _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3;
    Unity_Smoothstep_float(0, _Property_a152fa67057c46e880ce80c413044693_Out_0, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3);
    float _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2;
    Unity_Multiply_float(_GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2);
    float _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2;
    Unity_Add_float(_Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2);
    float _Property_ccc6c4f29c884e439e3da633449251c6_Out_0 = Opacity;
    float _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2;
    Unity_Multiply_float(_Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2, _Property_ccc6c4f29c884e439e3da633449251c6_Out_0, _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2);
    float _Clamp_bcce38c6417842408407dc2161c368a6_Out_3;
    Unity_Clamp_float(_Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2, 0, 1, _Clamp_bcce38c6417842408407dc2161c368a6_Out_3);
    float _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    Unity_OneMinus_float(_Clamp_bcce38c6417842408407dc2161c368a6_Out_3, _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1);
    surface.BaseColor = (_Multiply_1e0d82cb0edf4f2a9f53fb0f5e000e84_Out_2.xyz);
    surface.Emission = float3(0, 0, 0);
    surface.Alpha = _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    output.uv0 = input.texCoord0;
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

    ENDHLSL
}
Pass
{
        // Name: <None>
        Tags
        {
            "LightMode" = "Universal2D"
        }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float4 uv0;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float4 interp1 : TEXCOORD1;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.texCoord0 = input.interp1.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 Main_Texture_TexelSize;
float4 Tint;
float2 _playerPosition;
float _size;
float Smoothness;
float Opacity;
float ScrollTime;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(Main_Texture);
SAMPLER(samplerMain_Texture);

// Graph Functions

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
    Out = A * B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Clamp_float(float In, float Min, float Max, out float Out)
{
    Out = clamp(In, Min, Max);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    UnityTexture2D _Property_c4b770cbab1e464b89603a1721aeea07_Out_0 = UnityBuildTexture2DStructNoScale(Main_Texture);
    float4 _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0 = SAMPLE_TEXTURE2D(_Property_c4b770cbab1e464b89603a1721aeea07_Out_0.tex, _Property_c4b770cbab1e464b89603a1721aeea07_Out_0.samplerstate, IN.uv0.xy);
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_R_4 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.r;
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_G_5 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.g;
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_B_6 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.b;
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_A_7 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.a;
    float4 _Property_424965800e2046b8841548422bac7057_Out_0 = Tint;
    float4 _Multiply_1e0d82cb0edf4f2a9f53fb0f5e000e84_Out_2;
    Unity_Multiply_float(_SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0, _Property_424965800e2046b8841548422bac7057_Out_0, _Multiply_1e0d82cb0edf4f2a9f53fb0f5e000e84_Out_2);
    float4 _ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float _Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0 = ScrollTime;
    float _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2;
    Unity_Multiply_float(_Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0, IN.TimeParameters.x, _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2);
    float2 _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0.xy), float2 (1, 1), (_Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2.xx), _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3);
    float _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2;
    Unity_GradientNoise_float(_TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3, 10, _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2);
    float _Property_a152fa67057c46e880ce80c413044693_Out_0 = Smoothness;
    float4 _ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_b4a03a33e8004826a9d486b83be156d2_Out_0 = _playerPosition;
    float2 _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3;
    Unity_Remap_float2(_Property_b4a03a33e8004826a9d486b83be156d2_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3);
    float2 _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2;
    Unity_Add_float2((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3, _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2);
    float2 _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), float2 (1, 1), _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2, _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3);
    float2 _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2;
    Unity_Multiply_float(_TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3, float2(2, 2), _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2);
    float2 _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2;
    Unity_Subtract_float2(_Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2, float2(1, 1), _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2);
    float _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2);
    float _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0 = _size;
    float _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2;
    Unity_Multiply_float(_Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0, _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2);
    float2 _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0 = float2(_Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0);
    float2 _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2;
    Unity_Divide_float2(_Subtract_ec003425fddd450a952607a75b1c01d1_Out_2, _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0, _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2);
    float _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1;
    Unity_Length_float2(_Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2, _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1);
    float _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1;
    Unity_OneMinus_float(_Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1, _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1);
    float _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1;
    Unity_Saturate_float(_OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1);
    float _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3;
    Unity_Smoothstep_float(0, _Property_a152fa67057c46e880ce80c413044693_Out_0, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3);
    float _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2;
    Unity_Multiply_float(_GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2);
    float _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2;
    Unity_Add_float(_Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2);
    float _Property_ccc6c4f29c884e439e3da633449251c6_Out_0 = Opacity;
    float _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2;
    Unity_Multiply_float(_Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2, _Property_ccc6c4f29c884e439e3da633449251c6_Out_0, _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2);
    float _Clamp_bcce38c6417842408407dc2161c368a6_Out_3;
    Unity_Clamp_float(_Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2, 0, 1, _Clamp_bcce38c6417842408407dc2161c368a6_Out_3);
    float _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    Unity_OneMinus_float(_Clamp_bcce38c6417842408407dc2161c368a6_Out_3, _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1);
    surface.BaseColor = (_Multiply_1e0d82cb0edf4f2a9f53fb0f5e000e84_Out_2.xyz);
    surface.Alpha = _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    output.uv0 = input.texCoord0;
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

    ENDHLSL
}
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue" = "Transparent"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma only_renderers gles gles3 glcore d3d11
    #pragma multi_compile_instancing
    #pragma multi_compile_fog
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
    #pragma multi_compile _ LIGHTMAP_ON
    #pragma multi_compile _ DIRLIGHTMAP_COMBINED
    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
    #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
    #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
    #pragma multi_compile _ _SHADOWS_SOFT
    #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
    #pragma multi_compile _ SHADOWS_SHADOWMASK
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float3 normalWS;
        float4 tangentWS;
        float4 texCoord0;
        float3 viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        float2 lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 sh;
        #endif
        float4 fogFactorAndVertexLight;
        float4 shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 TangentSpaceNormal;
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float4 uv0;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float3 interp1 : TEXCOORD1;
        float4 interp2 : TEXCOORD2;
        float4 interp3 : TEXCOORD3;
        float3 interp4 : TEXCOORD4;
        #if defined(LIGHTMAP_ON)
        float2 interp5 : TEXCOORD5;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 interp6 : TEXCOORD6;
        #endif
        float4 interp7 : TEXCOORD7;
        float4 interp8 : TEXCOORD8;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyz = input.normalWS;
        output.interp2.xyzw = input.tangentWS;
        output.interp3.xyzw = input.texCoord0;
        output.interp4.xyz = input.viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        output.interp5.xy = input.lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.interp6.xyz = input.sh;
        #endif
        output.interp7.xyzw = input.fogFactorAndVertexLight;
        output.interp8.xyzw = input.shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.normalWS = input.interp1.xyz;
        output.tangentWS = input.interp2.xyzw;
        output.texCoord0 = input.interp3.xyzw;
        output.viewDirectionWS = input.interp4.xyz;
        #if defined(LIGHTMAP_ON)
        output.lightmapUV = input.interp5.xy;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.sh = input.interp6.xyz;
        #endif
        output.fogFactorAndVertexLight = input.interp7.xyzw;
        output.shadowCoord = input.interp8.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 Main_Texture_TexelSize;
float4 Tint;
float2 _playerPosition;
float _size;
float Smoothness;
float Opacity;
float ScrollTime;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(Main_Texture);
SAMPLER(samplerMain_Texture);

// Graph Functions

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
    Out = A * B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Clamp_float(float In, float Min, float Max, out float Out)
{
    Out = clamp(In, Min, Max);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float3 NormalTS;
    float3 Emission;
    float Metallic;
    float Smoothness;
    float Occlusion;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    UnityTexture2D _Property_c4b770cbab1e464b89603a1721aeea07_Out_0 = UnityBuildTexture2DStructNoScale(Main_Texture);
    float4 _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0 = SAMPLE_TEXTURE2D(_Property_c4b770cbab1e464b89603a1721aeea07_Out_0.tex, _Property_c4b770cbab1e464b89603a1721aeea07_Out_0.samplerstate, IN.uv0.xy);
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_R_4 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.r;
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_G_5 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.g;
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_B_6 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.b;
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_A_7 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.a;
    float4 _Property_424965800e2046b8841548422bac7057_Out_0 = Tint;
    float4 _Multiply_1e0d82cb0edf4f2a9f53fb0f5e000e84_Out_2;
    Unity_Multiply_float(_SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0, _Property_424965800e2046b8841548422bac7057_Out_0, _Multiply_1e0d82cb0edf4f2a9f53fb0f5e000e84_Out_2);
    float4 _ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float _Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0 = ScrollTime;
    float _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2;
    Unity_Multiply_float(_Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0, IN.TimeParameters.x, _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2);
    float2 _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0.xy), float2 (1, 1), (_Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2.xx), _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3);
    float _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2;
    Unity_GradientNoise_float(_TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3, 10, _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2);
    float _Property_a152fa67057c46e880ce80c413044693_Out_0 = Smoothness;
    float4 _ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_b4a03a33e8004826a9d486b83be156d2_Out_0 = _playerPosition;
    float2 _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3;
    Unity_Remap_float2(_Property_b4a03a33e8004826a9d486b83be156d2_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3);
    float2 _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2;
    Unity_Add_float2((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3, _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2);
    float2 _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), float2 (1, 1), _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2, _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3);
    float2 _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2;
    Unity_Multiply_float(_TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3, float2(2, 2), _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2);
    float2 _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2;
    Unity_Subtract_float2(_Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2, float2(1, 1), _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2);
    float _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2);
    float _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0 = _size;
    float _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2;
    Unity_Multiply_float(_Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0, _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2);
    float2 _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0 = float2(_Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0);
    float2 _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2;
    Unity_Divide_float2(_Subtract_ec003425fddd450a952607a75b1c01d1_Out_2, _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0, _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2);
    float _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1;
    Unity_Length_float2(_Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2, _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1);
    float _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1;
    Unity_OneMinus_float(_Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1, _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1);
    float _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1;
    Unity_Saturate_float(_OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1);
    float _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3;
    Unity_Smoothstep_float(0, _Property_a152fa67057c46e880ce80c413044693_Out_0, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3);
    float _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2;
    Unity_Multiply_float(_GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2);
    float _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2;
    Unity_Add_float(_Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2);
    float _Property_ccc6c4f29c884e439e3da633449251c6_Out_0 = Opacity;
    float _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2;
    Unity_Multiply_float(_Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2, _Property_ccc6c4f29c884e439e3da633449251c6_Out_0, _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2);
    float _Clamp_bcce38c6417842408407dc2161c368a6_Out_3;
    Unity_Clamp_float(_Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2, 0, 1, _Clamp_bcce38c6417842408407dc2161c368a6_Out_3);
    float _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    Unity_OneMinus_float(_Clamp_bcce38c6417842408407dc2161c368a6_Out_3, _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1);
    surface.BaseColor = (_Multiply_1e0d82cb0edf4f2a9f53fb0f5e000e84_Out_2.xyz);
    surface.NormalTS = IN.TangentSpaceNormal;
    surface.Emission = float3(0, 0, 0);
    surface.Metallic = 0;
    surface.Smoothness = 0.5;
    surface.Occlusion = 1;
    surface.Alpha = _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    output.uv0 = input.texCoord0;
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "ShadowCaster"
    Tags
    {
        "LightMode" = "ShadowCaster"
    }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite On
    ColorMask 0

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma only_renderers gles gles3 glcore d3d11
    #pragma multi_compile_instancing
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 Main_Texture_TexelSize;
float4 Tint;
float2 _playerPosition;
float _size;
float Smoothness;
float Opacity;
float ScrollTime;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(Main_Texture);
SAMPLER(samplerMain_Texture);

// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Clamp_float(float In, float Min, float Max, out float Out)
{
    Out = clamp(In, Min, Max);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float4 _ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float _Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0 = ScrollTime;
    float _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2;
    Unity_Multiply_float(_Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0, IN.TimeParameters.x, _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2);
    float2 _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0.xy), float2 (1, 1), (_Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2.xx), _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3);
    float _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2;
    Unity_GradientNoise_float(_TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3, 10, _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2);
    float _Property_a152fa67057c46e880ce80c413044693_Out_0 = Smoothness;
    float4 _ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_b4a03a33e8004826a9d486b83be156d2_Out_0 = _playerPosition;
    float2 _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3;
    Unity_Remap_float2(_Property_b4a03a33e8004826a9d486b83be156d2_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3);
    float2 _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2;
    Unity_Add_float2((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3, _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2);
    float2 _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), float2 (1, 1), _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2, _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3);
    float2 _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2;
    Unity_Multiply_float(_TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3, float2(2, 2), _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2);
    float2 _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2;
    Unity_Subtract_float2(_Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2, float2(1, 1), _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2);
    float _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2);
    float _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0 = _size;
    float _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2;
    Unity_Multiply_float(_Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0, _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2);
    float2 _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0 = float2(_Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0);
    float2 _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2;
    Unity_Divide_float2(_Subtract_ec003425fddd450a952607a75b1c01d1_Out_2, _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0, _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2);
    float _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1;
    Unity_Length_float2(_Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2, _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1);
    float _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1;
    Unity_OneMinus_float(_Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1, _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1);
    float _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1;
    Unity_Saturate_float(_OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1);
    float _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3;
    Unity_Smoothstep_float(0, _Property_a152fa67057c46e880ce80c413044693_Out_0, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3);
    float _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2;
    Unity_Multiply_float(_GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2);
    float _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2;
    Unity_Add_float(_Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2);
    float _Property_ccc6c4f29c884e439e3da633449251c6_Out_0 = Opacity;
    float _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2;
    Unity_Multiply_float(_Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2, _Property_ccc6c4f29c884e439e3da633449251c6_Out_0, _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2);
    float _Clamp_bcce38c6417842408407dc2161c368a6_Out_3;
    Unity_Clamp_float(_Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2, 0, 1, _Clamp_bcce38c6417842408407dc2161c368a6_Out_3);
    float _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    Unity_OneMinus_float(_Clamp_bcce38c6417842408407dc2161c368a6_Out_3, _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1);
    surface.Alpha = _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "DepthOnly"
    Tags
    {
        "LightMode" = "DepthOnly"
    }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite On
    ColorMask 0

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma only_renderers gles gles3 glcore d3d11
    #pragma multi_compile_instancing
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 Main_Texture_TexelSize;
float4 Tint;
float2 _playerPosition;
float _size;
float Smoothness;
float Opacity;
float ScrollTime;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(Main_Texture);
SAMPLER(samplerMain_Texture);

// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Clamp_float(float In, float Min, float Max, out float Out)
{
    Out = clamp(In, Min, Max);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float4 _ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float _Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0 = ScrollTime;
    float _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2;
    Unity_Multiply_float(_Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0, IN.TimeParameters.x, _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2);
    float2 _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0.xy), float2 (1, 1), (_Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2.xx), _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3);
    float _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2;
    Unity_GradientNoise_float(_TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3, 10, _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2);
    float _Property_a152fa67057c46e880ce80c413044693_Out_0 = Smoothness;
    float4 _ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_b4a03a33e8004826a9d486b83be156d2_Out_0 = _playerPosition;
    float2 _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3;
    Unity_Remap_float2(_Property_b4a03a33e8004826a9d486b83be156d2_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3);
    float2 _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2;
    Unity_Add_float2((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3, _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2);
    float2 _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), float2 (1, 1), _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2, _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3);
    float2 _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2;
    Unity_Multiply_float(_TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3, float2(2, 2), _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2);
    float2 _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2;
    Unity_Subtract_float2(_Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2, float2(1, 1), _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2);
    float _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2);
    float _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0 = _size;
    float _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2;
    Unity_Multiply_float(_Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0, _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2);
    float2 _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0 = float2(_Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0);
    float2 _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2;
    Unity_Divide_float2(_Subtract_ec003425fddd450a952607a75b1c01d1_Out_2, _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0, _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2);
    float _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1;
    Unity_Length_float2(_Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2, _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1);
    float _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1;
    Unity_OneMinus_float(_Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1, _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1);
    float _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1;
    Unity_Saturate_float(_OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1);
    float _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3;
    Unity_Smoothstep_float(0, _Property_a152fa67057c46e880ce80c413044693_Out_0, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3);
    float _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2;
    Unity_Multiply_float(_GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2);
    float _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2;
    Unity_Add_float(_Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2);
    float _Property_ccc6c4f29c884e439e3da633449251c6_Out_0 = Opacity;
    float _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2;
    Unity_Multiply_float(_Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2, _Property_ccc6c4f29c884e439e3da633449251c6_Out_0, _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2);
    float _Clamp_bcce38c6417842408407dc2161c368a6_Out_3;
    Unity_Clamp_float(_Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2, 0, 1, _Clamp_bcce38c6417842408407dc2161c368a6_Out_3);
    float _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    Unity_OneMinus_float(_Clamp_bcce38c6417842408407dc2161c368a6_Out_3, _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1);
    surface.Alpha = _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "DepthNormals"
    Tags
    {
        "LightMode" = "DepthNormals"
    }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma only_renderers gles gles3 glcore d3d11
    #pragma multi_compile_instancing
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv1 : TEXCOORD1;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float3 normalWS;
        float4 tangentWS;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 TangentSpaceNormal;
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float3 interp1 : TEXCOORD1;
        float4 interp2 : TEXCOORD2;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyz = input.normalWS;
        output.interp2.xyzw = input.tangentWS;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.normalWS = input.interp1.xyz;
        output.tangentWS = input.interp2.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 Main_Texture_TexelSize;
float4 Tint;
float2 _playerPosition;
float _size;
float Smoothness;
float Opacity;
float ScrollTime;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(Main_Texture);
SAMPLER(samplerMain_Texture);

// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Clamp_float(float In, float Min, float Max, out float Out)
{
    Out = clamp(In, Min, Max);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 NormalTS;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float4 _ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float _Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0 = ScrollTime;
    float _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2;
    Unity_Multiply_float(_Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0, IN.TimeParameters.x, _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2);
    float2 _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0.xy), float2 (1, 1), (_Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2.xx), _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3);
    float _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2;
    Unity_GradientNoise_float(_TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3, 10, _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2);
    float _Property_a152fa67057c46e880ce80c413044693_Out_0 = Smoothness;
    float4 _ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_b4a03a33e8004826a9d486b83be156d2_Out_0 = _playerPosition;
    float2 _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3;
    Unity_Remap_float2(_Property_b4a03a33e8004826a9d486b83be156d2_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3);
    float2 _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2;
    Unity_Add_float2((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3, _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2);
    float2 _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), float2 (1, 1), _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2, _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3);
    float2 _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2;
    Unity_Multiply_float(_TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3, float2(2, 2), _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2);
    float2 _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2;
    Unity_Subtract_float2(_Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2, float2(1, 1), _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2);
    float _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2);
    float _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0 = _size;
    float _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2;
    Unity_Multiply_float(_Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0, _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2);
    float2 _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0 = float2(_Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0);
    float2 _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2;
    Unity_Divide_float2(_Subtract_ec003425fddd450a952607a75b1c01d1_Out_2, _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0, _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2);
    float _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1;
    Unity_Length_float2(_Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2, _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1);
    float _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1;
    Unity_OneMinus_float(_Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1, _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1);
    float _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1;
    Unity_Saturate_float(_OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1);
    float _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3;
    Unity_Smoothstep_float(0, _Property_a152fa67057c46e880ce80c413044693_Out_0, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3);
    float _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2;
    Unity_Multiply_float(_GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2);
    float _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2;
    Unity_Add_float(_Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2);
    float _Property_ccc6c4f29c884e439e3da633449251c6_Out_0 = Opacity;
    float _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2;
    Unity_Multiply_float(_Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2, _Property_ccc6c4f29c884e439e3da633449251c6_Out_0, _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2);
    float _Clamp_bcce38c6417842408407dc2161c368a6_Out_3;
    Unity_Clamp_float(_Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2, 0, 1, _Clamp_bcce38c6417842408407dc2161c368a6_Out_3);
    float _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    Unity_OneMinus_float(_Clamp_bcce38c6417842408407dc2161c368a6_Out_3, _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1);
    surface.NormalTS = IN.TangentSpaceNormal;
    surface.Alpha = _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "Meta"
    Tags
    {
        "LightMode" = "Meta"
    }

        // Render State
        Cull Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma only_renderers gles gles3 glcore d3d11
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        float4 uv2 : TEXCOORD2;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float4 uv0;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float4 interp1 : TEXCOORD1;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.texCoord0 = input.interp1.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 Main_Texture_TexelSize;
float4 Tint;
float2 _playerPosition;
float _size;
float Smoothness;
float Opacity;
float ScrollTime;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(Main_Texture);
SAMPLER(samplerMain_Texture);

// Graph Functions

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
    Out = A * B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Clamp_float(float In, float Min, float Max, out float Out)
{
    Out = clamp(In, Min, Max);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float3 Emission;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    UnityTexture2D _Property_c4b770cbab1e464b89603a1721aeea07_Out_0 = UnityBuildTexture2DStructNoScale(Main_Texture);
    float4 _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0 = SAMPLE_TEXTURE2D(_Property_c4b770cbab1e464b89603a1721aeea07_Out_0.tex, _Property_c4b770cbab1e464b89603a1721aeea07_Out_0.samplerstate, IN.uv0.xy);
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_R_4 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.r;
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_G_5 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.g;
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_B_6 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.b;
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_A_7 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.a;
    float4 _Property_424965800e2046b8841548422bac7057_Out_0 = Tint;
    float4 _Multiply_1e0d82cb0edf4f2a9f53fb0f5e000e84_Out_2;
    Unity_Multiply_float(_SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0, _Property_424965800e2046b8841548422bac7057_Out_0, _Multiply_1e0d82cb0edf4f2a9f53fb0f5e000e84_Out_2);
    float4 _ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float _Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0 = ScrollTime;
    float _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2;
    Unity_Multiply_float(_Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0, IN.TimeParameters.x, _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2);
    float2 _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0.xy), float2 (1, 1), (_Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2.xx), _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3);
    float _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2;
    Unity_GradientNoise_float(_TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3, 10, _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2);
    float _Property_a152fa67057c46e880ce80c413044693_Out_0 = Smoothness;
    float4 _ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_b4a03a33e8004826a9d486b83be156d2_Out_0 = _playerPosition;
    float2 _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3;
    Unity_Remap_float2(_Property_b4a03a33e8004826a9d486b83be156d2_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3);
    float2 _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2;
    Unity_Add_float2((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3, _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2);
    float2 _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), float2 (1, 1), _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2, _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3);
    float2 _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2;
    Unity_Multiply_float(_TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3, float2(2, 2), _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2);
    float2 _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2;
    Unity_Subtract_float2(_Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2, float2(1, 1), _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2);
    float _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2);
    float _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0 = _size;
    float _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2;
    Unity_Multiply_float(_Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0, _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2);
    float2 _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0 = float2(_Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0);
    float2 _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2;
    Unity_Divide_float2(_Subtract_ec003425fddd450a952607a75b1c01d1_Out_2, _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0, _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2);
    float _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1;
    Unity_Length_float2(_Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2, _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1);
    float _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1;
    Unity_OneMinus_float(_Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1, _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1);
    float _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1;
    Unity_Saturate_float(_OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1);
    float _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3;
    Unity_Smoothstep_float(0, _Property_a152fa67057c46e880ce80c413044693_Out_0, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3);
    float _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2;
    Unity_Multiply_float(_GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2);
    float _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2;
    Unity_Add_float(_Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2);
    float _Property_ccc6c4f29c884e439e3da633449251c6_Out_0 = Opacity;
    float _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2;
    Unity_Multiply_float(_Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2, _Property_ccc6c4f29c884e439e3da633449251c6_Out_0, _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2);
    float _Clamp_bcce38c6417842408407dc2161c368a6_Out_3;
    Unity_Clamp_float(_Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2, 0, 1, _Clamp_bcce38c6417842408407dc2161c368a6_Out_3);
    float _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    Unity_OneMinus_float(_Clamp_bcce38c6417842408407dc2161c368a6_Out_3, _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1);
    surface.BaseColor = (_Multiply_1e0d82cb0edf4f2a9f53fb0f5e000e84_Out_2.xyz);
    surface.Emission = float3(0, 0, 0);
    surface.Alpha = _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    output.uv0 = input.texCoord0;
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

    ENDHLSL
}
Pass
{
        // Name: <None>
        Tags
        {
            "LightMode" = "Universal2D"
        }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma only_renderers gles gles3 glcore d3d11
    #pragma multi_compile_instancing
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float4 uv0;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float4 interp1 : TEXCOORD1;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.texCoord0 = input.interp1.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 Main_Texture_TexelSize;
float4 Tint;
float2 _playerPosition;
float _size;
float Smoothness;
float Opacity;
float ScrollTime;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(Main_Texture);
SAMPLER(samplerMain_Texture);

// Graph Functions

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
    Out = A * B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Clamp_float(float In, float Min, float Max, out float Out)
{
    Out = clamp(In, Min, Max);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    UnityTexture2D _Property_c4b770cbab1e464b89603a1721aeea07_Out_0 = UnityBuildTexture2DStructNoScale(Main_Texture);
    float4 _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0 = SAMPLE_TEXTURE2D(_Property_c4b770cbab1e464b89603a1721aeea07_Out_0.tex, _Property_c4b770cbab1e464b89603a1721aeea07_Out_0.samplerstate, IN.uv0.xy);
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_R_4 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.r;
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_G_5 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.g;
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_B_6 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.b;
    float _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_A_7 = _SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0.a;
    float4 _Property_424965800e2046b8841548422bac7057_Out_0 = Tint;
    float4 _Multiply_1e0d82cb0edf4f2a9f53fb0f5e000e84_Out_2;
    Unity_Multiply_float(_SampleTexture2D_af72e1879c2344d5a90750b57e674ce3_RGBA_0, _Property_424965800e2046b8841548422bac7057_Out_0, _Multiply_1e0d82cb0edf4f2a9f53fb0f5e000e84_Out_2);
    float4 _ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float _Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0 = ScrollTime;
    float _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2;
    Unity_Multiply_float(_Property_4e450a66d44f4ca8ac5a1f590bce0f2f_Out_0, IN.TimeParameters.x, _Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2);
    float2 _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_69a0fbbdbcea4713b8df050328e2b19c_Out_0.xy), float2 (1, 1), (_Multiply_055f358d7de34ee28a316af3a6a18f05_Out_2.xx), _TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3);
    float _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2;
    Unity_GradientNoise_float(_TilingAndOffset_9f615976035745778e810e16ce5faf2a_Out_3, 10, _GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2);
    float _Property_a152fa67057c46e880ce80c413044693_Out_0 = Smoothness;
    float4 _ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_b4a03a33e8004826a9d486b83be156d2_Out_0 = _playerPosition;
    float2 _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3;
    Unity_Remap_float2(_Property_b4a03a33e8004826a9d486b83be156d2_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3);
    float2 _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2;
    Unity_Add_float2((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), _Remap_4b76bbfb90a546ed913f48219ad8fae0_Out_3, _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2);
    float2 _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_ed041cd71a5d4d53a611625d9a75298a_Out_0.xy), float2 (1, 1), _Add_a3bc521be1e844b6bffdb99d997f14db_Out_2, _TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3);
    float2 _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2;
    Unity_Multiply_float(_TilingAndOffset_f74c30a7fdc94fc580ce7cbdc4390d6b_Out_3, float2(2, 2), _Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2);
    float2 _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2;
    Unity_Subtract_float2(_Multiply_49aacbc16ab84ddbb6bb69fac2be82e2_Out_2, float2(1, 1), _Subtract_ec003425fddd450a952607a75b1c01d1_Out_2);
    float _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2);
    float _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0 = _size;
    float _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2;
    Unity_Multiply_float(_Divide_d4ba4d4694f94610ae26d86223c763e4_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0, _Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2);
    float2 _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0 = float2(_Multiply_78f690a7b56d4ae9839ca18866969f7b_Out_2, _Property_fbe7d1952ab143e0a1878c0747535c30_Out_0);
    float2 _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2;
    Unity_Divide_float2(_Subtract_ec003425fddd450a952607a75b1c01d1_Out_2, _Vector2_22b74b940f1f4bc7b239a7530615e271_Out_0, _Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2);
    float _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1;
    Unity_Length_float2(_Divide_d5ef44ca547e4c1da8141c10bed1f842_Out_2, _Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1);
    float _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1;
    Unity_OneMinus_float(_Length_1181b1f0dad74c48a3d0c77fb8bf3993_Out_1, _OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1);
    float _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1;
    Unity_Saturate_float(_OneMinus_9b7a489d6ce848bb8efd8603d1e48d62_Out_1, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1);
    float _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3;
    Unity_Smoothstep_float(0, _Property_a152fa67057c46e880ce80c413044693_Out_0, _Saturate_3ffd93099ec047b9b7f19599b04dcd07_Out_1, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3);
    float _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2;
    Unity_Multiply_float(_GradientNoise_3e7c690e0ae641438c34655c30a3804f_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2);
    float _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2;
    Unity_Add_float(_Multiply_a5b8ffa0f94c48a5889112a9b2b5aa98_Out_2, _Smoothstep_866fc0083db449d2bf9f0647875ac7e1_Out_3, _Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2);
    float _Property_ccc6c4f29c884e439e3da633449251c6_Out_0 = Opacity;
    float _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2;
    Unity_Multiply_float(_Add_b3edc61c6f0a4ac8bbd4093b6fd39963_Out_2, _Property_ccc6c4f29c884e439e3da633449251c6_Out_0, _Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2);
    float _Clamp_bcce38c6417842408407dc2161c368a6_Out_3;
    Unity_Clamp_float(_Multiply_d92ef0b55b804fbead76f6534b4681c2_Out_2, 0, 1, _Clamp_bcce38c6417842408407dc2161c368a6_Out_3);
    float _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    Unity_OneMinus_float(_Clamp_bcce38c6417842408407dc2161c368a6_Out_3, _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1);
    surface.BaseColor = (_Multiply_1e0d82cb0edf4f2a9f53fb0f5e000e84_Out_2.xyz);
    surface.Alpha = _OneMinus_1bd25ee90def4640a4fca830517912e0_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    output.uv0 = input.texCoord0;
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

    ENDHLSL
}
    }
        CustomEditorForRenderPipeline "ShaderGraph.PBRMasterGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
        FallBack "Hidden/Shader Graph/FallbackError"
}