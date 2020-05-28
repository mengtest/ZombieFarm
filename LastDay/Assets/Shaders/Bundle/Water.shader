// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:3,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:True,hqlp:False,rprd:True,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:2865,x:33242,y:32559,varname:node_2865,prsc:2|diff-7355-OUT,spec-9448-OUT,gloss-318-OUT,normal-6478-OUT,alpha-9584-OUT,voffset-3033-OUT;n:type:ShaderForge.SFN_Vector1,id:9448,x:32407,y:32799,varname:node_9448,prsc:2,v1:0;n:type:ShaderForge.SFN_Lerp,id:7355,x:32287,y:32262,varname:node_7355,prsc:2|A-7504-RGB,B-1155-RGB,T-5222-OUT;n:type:ShaderForge.SFN_Color,id:7504,x:32068,y:32262,ptovrint:False,ptlb:Color1,ptin:_Color1,varname:_Color1,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.1362457,c2:0.599481,c3:0.9264706,c4:1;n:type:ShaderForge.SFN_Color,id:1155,x:32068,y:32493,ptovrint:False,ptlb:Color2,ptin:_Color2,varname:_Color2,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.05449827,c2:0.2047965,c3:0.4117647,c4:1;n:type:ShaderForge.SFN_Fresnel,id:5222,x:32068,y:32706,varname:node_5222,prsc:2|NRM-8627-OUT,EXP-5590-OUT;n:type:ShaderForge.SFN_NormalVector,id:8627,x:31840,y:32706,prsc:2,pt:True;n:type:ShaderForge.SFN_ValueProperty,id:325,x:31840,y:32879,ptovrint:False,ptlb:Fersnel,ptin:_Fersnel,varname:_Fersnel,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1.336;n:type:ShaderForge.SFN_ConstantClamp,id:5590,x:32068,y:32835,varname:node_5590,prsc:2,min:0,max:4|IN-325-OUT;n:type:ShaderForge.SFN_Tex2d,id:9560,x:32099,y:33088,varname:_node_9560,prsc:1,tex:161114273551dd74fb4e0d2bb8bbdc79,ntxv:0,isnm:False|UVIN-4968-OUT,TEX-393-TEX;n:type:ShaderForge.SFN_Tex2d,id:6026,x:32099,y:33337,varname:_node_6026,prsc:1,tex:161114273551dd74fb4e0d2bb8bbdc79,ntxv:0,isnm:False|UVIN-7566-OUT,TEX-393-TEX;n:type:ShaderForge.SFN_Tex2dAsset,id:393,x:31852,y:33108,ptovrint:False,ptlb:Normal,ptin:_Normal,varname:_Normal,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:161114273551dd74fb4e0d2bb8bbdc79,ntxv:2,isnm:False;n:type:ShaderForge.SFN_Lerp,id:6478,x:32404,y:33131,varname:node_6478,prsc:1|A-9560-RGB,B-6026-RGB,T-9658-OUT;n:type:ShaderForge.SFN_Slider,id:9658,x:31978,y:33557,ptovrint:False,ptlb:Lerp,ptin:_Lerp,varname:_Lerp,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.142612,max:1;n:type:ShaderForge.SFN_FragmentPosition,id:2181,x:31669,y:33821,varname:node_2181,prsc:2;n:type:ShaderForge.SFN_Append,id:2712,x:31854,y:33838,varname:node_2712,prsc:2|A-2181-X,B-2181-Z;n:type:ShaderForge.SFN_Divide,id:7542,x:32054,y:33838,varname:node_7542,prsc:2|A-2712-OUT,B-3027-OUT;n:type:ShaderForge.SFN_ValueProperty,id:3027,x:31854,y:33991,ptovrint:False,ptlb:UV Size,ptin:_UVSize,varname:_UVSize,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Set,id:78,x:32054,y:33991,varname:UV,prsc:1|IN-7542-OUT;n:type:ShaderForge.SFN_Get,id:3140,x:31688,y:33465,varname:node_3140,prsc:1|IN-78-OUT;n:type:ShaderForge.SFN_Multiply,id:3033,x:32867,y:32996,varname:node_3033,prsc:2|A-8627-OUT,B-6869-OUT,C-6478-OUT;n:type:ShaderForge.SFN_ValueProperty,id:6869,x:32664,y:33313,ptovrint:False,ptlb:Offset,ptin:_Offset,varname:_Offset,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.2;n:type:ShaderForge.SFN_Time,id:4186,x:31135,y:33081,varname:node_4186,prsc:1;n:type:ShaderForge.SFN_TexCoord,id:3972,x:31186,y:32919,varname:node_3972,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Slider,id:9009,x:31101,y:33310,ptovrint:False,ptlb:Panner U1,ptin:_PannerU1,varname:_PannerU1,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-1,cur:0,max:1;n:type:ShaderForge.SFN_Slider,id:4792,x:31101,y:33457,ptovrint:False,ptlb:Panner V1,ptin:_PannerV1,varname:_PannerV1,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-1,cur:0,max:1;n:type:ShaderForge.SFN_Add,id:3,x:31624,y:33081,varname:node_3,prsc:1|A-3972-UVOUT,B-652-OUT;n:type:ShaderForge.SFN_Add,id:4968,x:31852,y:33298,varname:node_4968,prsc:1|A-3-OUT,B-3140-OUT;n:type:ShaderForge.SFN_Append,id:5589,x:31486,y:33308,varname:node_5589,prsc:2|A-9009-OUT,B-4792-OUT;n:type:ShaderForge.SFN_Multiply,id:652,x:31437,y:33113,varname:node_652,prsc:2|A-4186-T,B-5589-OUT;n:type:ShaderForge.SFN_Time,id:9049,x:30946,y:33732,varname:node_9049,prsc:1;n:type:ShaderForge.SFN_TexCoord,id:2817,x:30997,y:33570,varname:node_2817,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Slider,id:5711,x:30912,y:33961,ptovrint:False,ptlb:Panner U2,ptin:_PannerU2,varname:_PannerU2,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-1,cur:0,max:1;n:type:ShaderForge.SFN_Slider,id:5999,x:30912,y:34108,ptovrint:False,ptlb:Panner V2,ptin:_PannerV2,varname:_PannerV2,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-1,cur:0,max:1;n:type:ShaderForge.SFN_Add,id:3225,x:31435,y:33732,varname:node_3225,prsc:1|A-2817-UVOUT,B-4588-OUT;n:type:ShaderForge.SFN_Append,id:7693,x:31297,y:33959,varname:node_7693,prsc:2|A-5711-OUT,B-5999-OUT;n:type:ShaderForge.SFN_Multiply,id:4588,x:31248,y:33764,varname:node_4588,prsc:2|A-9049-T,B-7693-OUT;n:type:ShaderForge.SFN_Add,id:7566,x:31802,y:33608,varname:node_7566,prsc:1|A-3225-OUT,B-3140-OUT;n:type:ShaderForge.SFN_ValueProperty,id:318,x:32819,y:32578,ptovrint:False,ptlb:Gloss,ptin:_Gloss,varname:_Gloss,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Slider,id:6016,x:32525,y:32909,ptovrint:False,ptlb:Opacity,ptin:_Opacity,varname:_Opacity,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.6068376,max:1;n:type:ShaderForge.SFN_Multiply,id:9584,x:32944,y:32784,varname:node_9584,prsc:2|A-2198-OUT,B-6016-OUT;n:type:ShaderForge.SFN_Multiply,id:2198,x:32405,y:32970,varname:node_2198,prsc:2|A-9560-R,B-6026-R;proporder:393-7504-1155-325-9658-3027-6869-9009-4792-5711-5999-318-6016;pass:END;sub:END;*/

Shader "FX Kimi/Water/Water" {
    Properties {
        _Normal ("Normal", 2D) = "black" {}
        _Color1 ("Color1", Color) = (0.1362457,0.599481,0.9264706,1)
        _Color2 ("Color2", Color) = (0.05449827,0.2047965,0.4117647,1)
        _Fersnel ("Fersnel", Float ) = 1.336
        _Lerp ("Lerp", Range(0, 1)) = 0.142612
        _UVSize ("UV Size", Float ) = 1
        _Offset ("Offset", Float ) = 0.2
        _PannerU1 ("Panner U1", Range(-1, 1)) = 0
        _PannerV1 ("Panner V1", Range(-1, 1)) = 0
        _PannerU2 ("Panner U2", Range(-1, 1)) = 0
        _PannerV2 ("Panner V2", Range(-1, 1)) = 0
        _Gloss ("Gloss", Float ) = 1
        _Opacity ("Opacity", Range(0, 1)) = 0.6068376
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #define SHOULD_SAMPLE_SH ( defined (LIGHTMAP_OFF) && defined(DYNAMICLIGHTMAP_OFF) )
            #define _GLOSSYENV 1
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
            #pragma multi_compile DIRLIGHTMAP_OFF DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
            #pragma multi_compile DYNAMICLIGHTMAP_OFF DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform half4 _Color1;
            uniform half4 _Color2;
            uniform half _Fersnel;
            uniform sampler2D _Normal; uniform float4 _Normal_ST;
            uniform half _Lerp;
            uniform half _UVSize;
            uniform float _Offset;
            uniform half _PannerU1;
            uniform half _PannerV1;
            uniform half _PannerU2;
            uniform half _PannerV2;
            uniform half _Gloss;
            uniform float _Opacity;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
                float2 texcoord2 : TEXCOORD2;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                float4 posWorld : TEXCOORD3;
                float3 normalDir : TEXCOORD4;
                float3 tangentDir : TEXCOORD5;
                float3 bitangentDir : TEXCOORD6;
                UNITY_FOG_COORDS(7)
                #if defined(LIGHTMAP_ON) || defined(UNITY_SHOULD_SAMPLE_SH)
                    float4 ambientOrLightmapUV : TEXCOORD8;
                #endif
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.uv1 = v.texcoord1;
                o.uv2 = v.texcoord2;
                #ifdef LIGHTMAP_ON
                    o.ambientOrLightmapUV.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                    o.ambientOrLightmapUV.zw = 0;
                #elif UNITY_SHOULD_SAMPLE_SH
                #endif
                #ifdef DYNAMICLIGHTMAP_ON
                    o.ambientOrLightmapUV.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
                #endif
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                half4 node_4186 = _Time;
                half2 UV = (float2(mul(unity_ObjectToWorld, v.vertex).r,mul(unity_ObjectToWorld, v.vertex).b)/_UVSize);
                half2 node_3140 = UV;
                half2 node_4968 = ((o.uv0+(node_4186.g*float2(_PannerU1,_PannerV1)))+node_3140);
                half4 _node_9560 = tex2Dlod(_Normal,float4(TRANSFORM_TEX(node_4968, _Normal),0.0,0));
                half4 node_9049 = _Time;
                half2 node_7566 = ((o.uv0+(node_9049.g*float2(_PannerU2,_PannerV2)))+node_3140);
                half4 _node_6026 = tex2Dlod(_Normal,float4(TRANSFORM_TEX(node_7566, _Normal),0.0,0));
                half3 node_6478 = lerp(_node_9560.rgb,_node_6026.rgb,_Lerp);
                v.vertex.xyz += (v.normal*_Offset*node_6478);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                half4 node_4186 = _Time;
                half2 UV = (float2(i.posWorld.r,i.posWorld.b)/_UVSize);
                half2 node_3140 = UV;
                half2 node_4968 = ((i.uv0+(node_4186.g*float2(_PannerU1,_PannerV1)))+node_3140);
                half4 _node_9560 = tex2D(_Normal,TRANSFORM_TEX(node_4968, _Normal));
                half4 node_9049 = _Time;
                half2 node_7566 = ((i.uv0+(node_9049.g*float2(_PannerU2,_PannerV2)))+node_3140);
                half4 _node_6026 = tex2D(_Normal,TRANSFORM_TEX(node_7566, _Normal));
                half3 node_6478 = lerp(_node_9560.rgb,_node_6026.rgb,_Lerp);
                float3 normalLocal = node_6478;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = 1;
                float3 attenColor = attenuation * _LightColor0.xyz;
                float Pi = 3.141592654;
                float InvPi = 0.31830988618;
///////// Gloss:
                float gloss = _Gloss;
                float perceptualRoughness = 1.0 - _Gloss;
                float roughness = perceptualRoughness * perceptualRoughness;
                float specPow = exp2( gloss * 10.0 + 1.0 );
/////// GI Data:
                UnityLight light;
                #ifdef LIGHTMAP_OFF
                    light.color = lightColor;
                    light.dir = lightDirection;
                    light.ndotl = LambertTerm (normalDirection, light.dir);
                #else
                    light.color = half3(0.f, 0.f, 0.f);
                    light.ndotl = 0.0f;
                    light.dir = half3(0.f, 0.f, 0.f);
                #endif
                UnityGIInput d;
                d.light = light;
                d.worldPos = i.posWorld.xyz;
                d.worldViewDir = viewDirection;
                d.atten = attenuation;
                #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
                    d.ambient = 0;
                    d.lightmapUV = i.ambientOrLightmapUV;
                #else
                    d.ambient = i.ambientOrLightmapUV;
                #endif
                #if UNITY_SPECCUBE_BLENDING || UNITY_SPECCUBE_BOX_PROJECTION
                    d.boxMin[0] = unity_SpecCube0_BoxMin;
                    d.boxMin[1] = unity_SpecCube1_BoxMin;
                #endif
                #if UNITY_SPECCUBE_BOX_PROJECTION
                    d.boxMax[0] = unity_SpecCube0_BoxMax;
                    d.boxMax[1] = unity_SpecCube1_BoxMax;
                    d.probePosition[0] = unity_SpecCube0_ProbePosition;
                    d.probePosition[1] = unity_SpecCube1_ProbePosition;
                #endif
                d.probeHDR[0] = unity_SpecCube0_HDR;
                d.probeHDR[1] = unity_SpecCube1_HDR;
                Unity_GlossyEnvironmentData ugls_en_data;
                ugls_en_data.roughness = 1.0 - gloss;
                ugls_en_data.reflUVW = viewReflectDirection;
                UnityGI gi = UnityGlobalIllumination(d, 1, normalDirection, ugls_en_data );
                lightDirection = gi.light.dir;
                lightColor = gi.light.color;
////// Specular:
                float NdotL = saturate(dot( normalDirection, lightDirection ));
                float LdotH = saturate(dot(lightDirection, halfDirection));
                float3 specularColor = 0.0;
                float specularMonochrome;
                float3 diffuseColor = lerp(_Color1.rgb,_Color2.rgb,pow(1.0-max(0,dot(normalDirection, viewDirection)),clamp(_Fersnel,0,4))); // Need this for specular when using metallic
                diffuseColor = DiffuseAndSpecularFromMetallic( diffuseColor, specularColor, specularColor, specularMonochrome );
                specularMonochrome = 1.0-specularMonochrome;
                float NdotV = abs(dot( normalDirection, viewDirection ));
                float NdotH = saturate(dot( normalDirection, halfDirection ));
                float VdotH = saturate(dot( viewDirection, halfDirection ));
                float visTerm = SmithJointGGXVisibilityTerm( NdotL, NdotV, roughness );
                float normTerm = GGXTerm(NdotH, roughness);
                float specularPBL = (visTerm*normTerm) * UNITY_PI;
                #ifdef UNITY_COLORSPACE_GAMMA
                    specularPBL = sqrt(max(1e-4h, specularPBL));
                #endif
                specularPBL = max(0, specularPBL * NdotL);
                #if defined(_SPECULARHIGHLIGHTS_OFF)
                    specularPBL = 0.0;
                #endif
                half surfaceReduction;
                #ifdef UNITY_COLORSPACE_GAMMA
                    surfaceReduction = 1.0-0.28*roughness*perceptualRoughness;
                #else
                    surfaceReduction = 1.0/(roughness*roughness + 1.0);
                #endif
                specularPBL *= any(specularColor) ? 1.0 : 0.0;
                float3 directSpecular = attenColor*specularPBL*FresnelTerm(specularColor, LdotH);
                half grazingTerm = saturate( gloss + specularMonochrome );
                float3 indirectSpecular = (gi.indirect.specular);
                indirectSpecular *= FresnelLerp (specularColor, grazingTerm, NdotV);
                indirectSpecular *= surfaceReduction;
                float3 specular = (directSpecular + indirectSpecular);
/////// Diffuse:
                NdotL = max(0.0,dot( normalDirection, lightDirection ));
                half fd90 = 0.5 + 2 * LdotH * LdotH * (1-gloss);
                float nlPow5 = Pow5(1-NdotL);
                float nvPow5 = Pow5(1-NdotV);
                float3 directDiffuse = ((1 +(fd90 - 1)*nlPow5) * (1 + (fd90 - 1)*nvPow5) * NdotL) * attenColor;
                float3 indirectDiffuse = float3(0,0,0);
                indirectDiffuse += gi.indirect.diffuse;
                float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
/// Final Color:
                float3 finalColor = diffuse + specular;
                fixed4 finalRGBA = fixed4(finalColor,((_node_9560.r*_node_6026.r)*_Opacity));
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        Pass {
            Name "FORWARD_DELTA"
            Tags {
                "LightMode"="ForwardAdd"
            }
            Blend One One
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDADD
            #define SHOULD_SAMPLE_SH ( defined (LIGHTMAP_OFF) && defined(DYNAMICLIGHTMAP_OFF) )
            #define _GLOSSYENV 1
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #pragma multi_compile_fwdadd
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
            #pragma multi_compile DIRLIGHTMAP_OFF DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
            #pragma multi_compile DYNAMICLIGHTMAP_OFF DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform half4 _Color1;
            uniform half4 _Color2;
            uniform half _Fersnel;
            uniform sampler2D _Normal; uniform float4 _Normal_ST;
            uniform half _Lerp;
            uniform half _UVSize;
            uniform float _Offset;
            uniform half _PannerU1;
            uniform half _PannerV1;
            uniform half _PannerU2;
            uniform half _PannerV2;
            uniform half _Gloss;
            uniform float _Opacity;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
                float2 texcoord2 : TEXCOORD2;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                float4 posWorld : TEXCOORD3;
                float3 normalDir : TEXCOORD4;
                float3 tangentDir : TEXCOORD5;
                float3 bitangentDir : TEXCOORD6;
                LIGHTING_COORDS(7,8)
                UNITY_FOG_COORDS(9)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.uv1 = v.texcoord1;
                o.uv2 = v.texcoord2;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                half4 node_4186 = _Time;
                half2 UV = (float2(mul(unity_ObjectToWorld, v.vertex).r,mul(unity_ObjectToWorld, v.vertex).b)/_UVSize);
                half2 node_3140 = UV;
                half2 node_4968 = ((o.uv0+(node_4186.g*float2(_PannerU1,_PannerV1)))+node_3140);
                half4 _node_9560 = tex2Dlod(_Normal,float4(TRANSFORM_TEX(node_4968, _Normal),0.0,0));
                half4 node_9049 = _Time;
                half2 node_7566 = ((o.uv0+(node_9049.g*float2(_PannerU2,_PannerV2)))+node_3140);
                half4 _node_6026 = tex2Dlod(_Normal,float4(TRANSFORM_TEX(node_7566, _Normal),0.0,0));
                half3 node_6478 = lerp(_node_9560.rgb,_node_6026.rgb,_Lerp);
                v.vertex.xyz += (v.normal*_Offset*node_6478);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                half4 node_4186 = _Time;
                half2 UV = (float2(i.posWorld.r,i.posWorld.b)/_UVSize);
                half2 node_3140 = UV;
                half2 node_4968 = ((i.uv0+(node_4186.g*float2(_PannerU1,_PannerV1)))+node_3140);
                half4 _node_9560 = tex2D(_Normal,TRANSFORM_TEX(node_4968, _Normal));
                half4 node_9049 = _Time;
                half2 node_7566 = ((i.uv0+(node_9049.g*float2(_PannerU2,_PannerV2)))+node_3140);
                half4 _node_6026 = tex2D(_Normal,TRANSFORM_TEX(node_7566, _Normal));
                half3 node_6478 = lerp(_node_9560.rgb,_node_6026.rgb,_Lerp);
                float3 normalLocal = node_6478;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
                float Pi = 3.141592654;
                float InvPi = 0.31830988618;
///////// Gloss:
                float gloss = _Gloss;
                float perceptualRoughness = 1.0 - _Gloss;
                float roughness = perceptualRoughness * perceptualRoughness;
                float specPow = exp2( gloss * 10.0 + 1.0 );
////// Specular:
                float NdotL = saturate(dot( normalDirection, lightDirection ));
                float LdotH = saturate(dot(lightDirection, halfDirection));
                float3 specularColor = 0.0;
                float specularMonochrome;
                float3 diffuseColor = lerp(_Color1.rgb,_Color2.rgb,pow(1.0-max(0,dot(normalDirection, viewDirection)),clamp(_Fersnel,0,4))); // Need this for specular when using metallic
                diffuseColor = DiffuseAndSpecularFromMetallic( diffuseColor, specularColor, specularColor, specularMonochrome );
                specularMonochrome = 1.0-specularMonochrome;
                float NdotV = abs(dot( normalDirection, viewDirection ));
                float NdotH = saturate(dot( normalDirection, halfDirection ));
                float VdotH = saturate(dot( viewDirection, halfDirection ));
                float visTerm = SmithJointGGXVisibilityTerm( NdotL, NdotV, roughness );
                float normTerm = GGXTerm(NdotH, roughness);
                float specularPBL = (visTerm*normTerm) * UNITY_PI;
                #ifdef UNITY_COLORSPACE_GAMMA
                    specularPBL = sqrt(max(1e-4h, specularPBL));
                #endif
                specularPBL = max(0, specularPBL * NdotL);
                #if defined(_SPECULARHIGHLIGHTS_OFF)
                    specularPBL = 0.0;
                #endif
                specularPBL *= any(specularColor) ? 1.0 : 0.0;
                float3 directSpecular = attenColor*specularPBL*FresnelTerm(specularColor, LdotH);
                float3 specular = directSpecular;
/////// Diffuse:
                NdotL = max(0.0,dot( normalDirection, lightDirection ));
                half fd90 = 0.5 + 2 * LdotH * LdotH * (1-gloss);
                float nlPow5 = Pow5(1-NdotL);
                float nvPow5 = Pow5(1-NdotV);
                float3 directDiffuse = ((1 +(fd90 - 1)*nlPow5) * (1 + (fd90 - 1)*nvPow5) * NdotL) * attenColor;
                float3 diffuse = directDiffuse * diffuseColor;
/// Final Color:
                float3 finalColor = diffuse + specular;
                fixed4 finalRGBA = fixed4(finalColor * ((_node_9560.r*_node_6026.r)*_Opacity),0);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            Cull Back
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCASTER
            #define SHOULD_SAMPLE_SH ( defined (LIGHTMAP_OFF) && defined(DYNAMICLIGHTMAP_OFF) )
            #define _GLOSSYENV 1
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
            #pragma multi_compile DIRLIGHTMAP_OFF DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
            #pragma multi_compile DYNAMICLIGHTMAP_OFF DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform sampler2D _Normal; uniform float4 _Normal_ST;
            uniform half _Lerp;
            uniform half _UVSize;
            uniform float _Offset;
            uniform half _PannerU1;
            uniform half _PannerV1;
            uniform half _PannerU2;
            uniform half _PannerV2;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
                float2 texcoord2 : TEXCOORD2;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                float2 uv0 : TEXCOORD1;
                float2 uv1 : TEXCOORD2;
                float2 uv2 : TEXCOORD3;
                float4 posWorld : TEXCOORD4;
                float3 normalDir : TEXCOORD5;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.uv1 = v.texcoord1;
                o.uv2 = v.texcoord2;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                half4 node_4186 = _Time;
                half2 UV = (float2(mul(unity_ObjectToWorld, v.vertex).r,mul(unity_ObjectToWorld, v.vertex).b)/_UVSize);
                half2 node_3140 = UV;
                half2 node_4968 = ((o.uv0+(node_4186.g*float2(_PannerU1,_PannerV1)))+node_3140);
                half4 _node_9560 = tex2Dlod(_Normal,float4(TRANSFORM_TEX(node_4968, _Normal),0.0,0));
                half4 node_9049 = _Time;
                half2 node_7566 = ((o.uv0+(node_9049.g*float2(_PannerU2,_PannerV2)))+node_3140);
                half4 _node_6026 = tex2Dlod(_Normal,float4(TRANSFORM_TEX(node_7566, _Normal),0.0,0));
                half3 node_6478 = lerp(_node_9560.rgb,_node_6026.rgb,_Lerp);
                v.vertex.xyz += (v.normal*_Offset*node_6478);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
        Pass {
            Name "Meta"
            Tags {
                "LightMode"="Meta"
            }
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_META 1
            #define SHOULD_SAMPLE_SH ( defined (LIGHTMAP_OFF) && defined(DYNAMICLIGHTMAP_OFF) )
            #define _GLOSSYENV 1
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #include "UnityMetaPass.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
            #pragma multi_compile DIRLIGHTMAP_OFF DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
            #pragma multi_compile DYNAMICLIGHTMAP_OFF DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform half4 _Color1;
            uniform half4 _Color2;
            uniform half _Fersnel;
            uniform sampler2D _Normal; uniform float4 _Normal_ST;
            uniform half _Lerp;
            uniform half _UVSize;
            uniform float _Offset;
            uniform half _PannerU1;
            uniform half _PannerV1;
            uniform half _PannerU2;
            uniform half _PannerV2;
            uniform half _Gloss;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
                float2 texcoord2 : TEXCOORD2;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                float4 posWorld : TEXCOORD3;
                float3 normalDir : TEXCOORD4;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.uv1 = v.texcoord1;
                o.uv2 = v.texcoord2;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                half4 node_4186 = _Time;
                half2 UV = (float2(mul(unity_ObjectToWorld, v.vertex).r,mul(unity_ObjectToWorld, v.vertex).b)/_UVSize);
                half2 node_3140 = UV;
                half2 node_4968 = ((o.uv0+(node_4186.g*float2(_PannerU1,_PannerV1)))+node_3140);
                half4 _node_9560 = tex2Dlod(_Normal,float4(TRANSFORM_TEX(node_4968, _Normal),0.0,0));
                half4 node_9049 = _Time;
                half2 node_7566 = ((o.uv0+(node_9049.g*float2(_PannerU2,_PannerV2)))+node_3140);
                half4 _node_6026 = tex2Dlod(_Normal,float4(TRANSFORM_TEX(node_7566, _Normal),0.0,0));
                half3 node_6478 = lerp(_node_9560.rgb,_node_6026.rgb,_Lerp);
                v.vertex.xyz += (v.normal*_Offset*node_6478);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityMetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST, unity_DynamicLightmapST );
                return o;
            }
            float4 frag(VertexOutput i) : SV_Target {
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                UnityMetaInput o;
                UNITY_INITIALIZE_OUTPUT( UnityMetaInput, o );
                
                o.Emission = 0;
                
                float3 diffColor = lerp(_Color1.rgb,_Color2.rgb,pow(1.0-max(0,dot(normalDirection, viewDirection)),clamp(_Fersnel,0,4)));
                float specularMonochrome;
                float3 specColor;
                diffColor = DiffuseAndSpecularFromMetallic( diffColor, 0.0, specColor, specularMonochrome );
                float roughness = 1.0 - _Gloss;
                o.Albedo = diffColor + specColor * roughness * roughness * 0.5;
                
                return UnityMetaFragment( o );
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
