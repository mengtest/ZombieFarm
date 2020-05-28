// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:0,lgpr:1,limd:3,spmd:1,trmd:0,grmd:1,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:False,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:33976,y:32676,varname:node_3138,prsc:2|diff-6428-OUT,spec-8908-OUT,alpha-7513-OUT;n:type:ShaderForge.SFN_Vector1,id:8908,x:33591,y:32606,varname:node_8908,prsc:2,v1:0;n:type:ShaderForge.SFN_Lerp,id:6428,x:33317,y:32645,varname:node_6428,prsc:2|A-7563-OUT,B-4664-OUT,T-1777-OUT;n:type:ShaderForge.SFN_Vector1,id:4664,x:33091,y:32440,varname:node_4664,prsc:2,v1:3;n:type:ShaderForge.SFN_Lerp,id:7563,x:33024,y:32561,varname:node_7563,prsc:2|A-6772-OUT,B-7271-RGB,T-3583-OUT;n:type:ShaderForge.SFN_Lerp,id:6772,x:32806,y:32311,varname:node_6772,prsc:2|A-1936-RGB,B-5882-OUT,T-1264-OUT;n:type:ShaderForge.SFN_Clamp01,id:3583,x:32480,y:32725,varname:node_3583,prsc:2|IN-4929-OUT;n:type:ShaderForge.SFN_DepthBlend,id:1264,x:32249,y:32195,varname:node_1264,prsc:2|DIST-3874-OUT;n:type:ShaderForge.SFN_Color,id:1936,x:32366,y:31984,ptovrint:False,ptlb:Water Color,ptin:_WaterColor,varname:_WaterColor,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.007352948,c2:0.6303247,c3:1,c4:1;n:type:ShaderForge.SFN_OneMinus,id:2793,x:32249,y:32407,varname:node_2793,prsc:2|IN-9741-OUT;n:type:ShaderForge.SFN_Multiply,id:5882,x:32480,y:32526,varname:node_5882,prsc:2|A-1936-RGB,B-2793-OUT;n:type:ShaderForge.SFN_Add,id:4929,x:31997,y:32855,varname:node_4929,prsc:1|A-7374-OUT,B-5426-OUT;n:type:ShaderForge.SFN_Multiply,id:5426,x:31764,y:32904,varname:node_5426,prsc:2|A-7374-OUT,B-9538-OUT,C-7271-A;n:type:ShaderForge.SFN_Color,id:7271,x:31315,y:32561,ptovrint:False,ptlb:Rim Color,ptin:_RimColor,varname:_RimColor,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Multiply,id:7374,x:31572,y:32731,varname:node_7374,prsc:1|A-7271-A,B-555-OUT;n:type:ShaderForge.SFN_OneMinus,id:9538,x:31601,y:33026,varname:node_9538,prsc:2|IN-3517-OUT;n:type:ShaderForge.SFN_Subtract,id:555,x:31267,y:32804,varname:node_555,prsc:2|A-1155-OUT,B-409-OUT;n:type:ShaderForge.SFN_DepthBlend,id:1155,x:30903,y:32593,varname:node_1155,prsc:2|DIST-6975-OUT;n:type:ShaderForge.SFN_Slider,id:6975,x:30468,y:32627,ptovrint:False,ptlb:Rim Distance,ptin:_RimDistance,varname:_RimDistance,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.6944705,max:1;n:type:ShaderForge.SFN_DepthBlend,id:9358,x:30838,y:32815,varname:node_9358,prsc:2|DIST-9741-OUT;n:type:ShaderForge.SFN_Multiply,id:3517,x:31393,y:33026,varname:node_3517,prsc:2|A-8543-R,B-1311-R;n:type:ShaderForge.SFN_Tex2d,id:8543,x:31044,y:33096,varname:_node_8543,prsc:1,tex:ac49beeda1d0c854492878a0eff35a21,ntxv:0,isnm:False|UVIN-9953-UVOUT,TEX-4386-TEX;n:type:ShaderForge.SFN_Tex2d,id:1311,x:31044,y:33332,varname:_node_1311,prsc:1,tex:ac49beeda1d0c854492878a0eff35a21,ntxv:0,isnm:False|UVIN-7000-UVOUT,TEX-4386-TEX;n:type:ShaderForge.SFN_Tex2dAsset,id:4386,x:30738,y:33579,ptovrint:False,ptlb:Texture,ptin:_Texture,varname:_Texture,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:ac49beeda1d0c854492878a0eff35a21,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Panner,id:9953,x:30738,y:33144,varname:node_9953,prsc:1,spu:0.5,spv:2|UVIN-3047-OUT,DIST-2821-OUT;n:type:ShaderForge.SFN_Panner,id:7000,x:30738,y:33340,varname:node_7000,prsc:1,spu:-0.5,spv:1.5|UVIN-3047-OUT,DIST-2821-OUT;n:type:ShaderForge.SFN_Slider,id:8595,x:29005,y:33650,ptovrint:False,ptlb:Speed,ptin:_Speed,varname:_Speed,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-10,cur:0.5,max:10;n:type:ShaderForge.SFN_Multiply,id:6472,x:29392,y:33822,varname:node_6472,prsc:2|A-8595-OUT,B-3952-OUT;n:type:ShaderForge.SFN_Vector1,id:3952,x:29095,y:33902,varname:node_3952,prsc:2,v1:0.1;n:type:ShaderForge.SFN_Time,id:1767,x:29392,y:33628,varname:node_1767,prsc:1;n:type:ShaderForge.SFN_Multiply,id:3898,x:29571,y:33706,varname:node_3898,prsc:2|A-1767-T,B-6472-OUT;n:type:ShaderForge.SFN_Set,id:8745,x:29747,y:33706,varname:Wavespeed,prsc:1|IN-3898-OUT;n:type:ShaderForge.SFN_Get,id:2821,x:30352,y:33414,varname:node_2821,prsc:1|IN-8745-OUT;n:type:ShaderForge.SFN_Subtract,id:3835,x:31486,y:33621,varname:node_3835,prsc:2|A-7528-R,B-8531-R;n:type:ShaderForge.SFN_Smoothstep,id:5715,x:31797,y:33629,varname:node_5715,prsc:2|A-2654-OUT,B-7417-OUT,V-3835-OUT;n:type:ShaderForge.SFN_Vector1,id:2654,x:31570,y:33826,varname:node_2654,prsc:2,v1:0;n:type:ShaderForge.SFN_Slider,id:7417,x:31800,y:33857,ptovrint:False,ptlb:Smooths,ptin:_Smooths,varname:_Smooths,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Multiply,id:1777,x:32269,y:33530,varname:node_1777,prsc:1|A-5715-OUT,B-9751-OUT;n:type:ShaderForge.SFN_Slider,id:9751,x:31871,y:33530,ptovrint:False,ptlb:Smooths Light,ptin:_SmoothsLight,varname:_SmoothsLight,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-1,cur:0.4266556,max:1;n:type:ShaderForge.SFN_Clamp01,id:4662,x:32565,y:33570,varname:node_4662,prsc:2|IN-1777-OUT;n:type:ShaderForge.SFN_Tex2d,id:7528,x:31045,y:33629,varname:_node_7528,prsc:1,tex:ac49beeda1d0c854492878a0eff35a21,ntxv:0,isnm:False|UVIN-9700-OUT,TEX-4386-TEX;n:type:ShaderForge.SFN_Tex2d,id:8531,x:31047,y:33912,varname:_node_8531,prsc:1,tex:ac49beeda1d0c854492878a0eff35a21,ntxv:0,isnm:False|UVIN-7853-OUT,TEX-4386-TEX;n:type:ShaderForge.SFN_Multiply,id:9700,x:30770,y:33885,varname:node_9700,prsc:1|A-133-UVOUT,B-580-OUT;n:type:ShaderForge.SFN_Multiply,id:7853,x:30770,y:34042,varname:node_7853,prsc:1|A-332-UVOUT,B-580-OUT;n:type:ShaderForge.SFN_ValueProperty,id:580,x:30449,y:34056,ptovrint:False,ptlb:Smooths Tiling,ptin:_SmoothsTiling,varname:_SmoothsTiling,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.25;n:type:ShaderForge.SFN_Panner,id:133,x:30518,y:33799,varname:node_133,prsc:2,spu:0,spv:1|UVIN-6321-UVOUT,DIST-3789-OUT;n:type:ShaderForge.SFN_Panner,id:332,x:30516,y:34214,varname:node_332,prsc:2,spu:0.1,spv:0|UVIN-6321-UVOUT,DIST-3789-OUT;n:type:ShaderForge.SFN_Get,id:3789,x:30119,y:34001,varname:node_3789,prsc:1|IN-8745-OUT;n:type:ShaderForge.SFN_Add,id:7513,x:33301,y:32957,varname:node_7513,prsc:2|A-7318-OUT,B-4662-OUT;n:type:ShaderForge.SFN_Blend,id:7318,x:33025,y:32957,varname:node_7318,prsc:2,blmd:10,clmp:True|SRC-1264-OUT,DST-4919-OUT;n:type:ShaderForge.SFN_Lerp,id:4919,x:32688,y:32986,varname:node_4919,prsc:2|A-5375-OUT,B-3502-OUT,T-4929-OUT;n:type:ShaderForge.SFN_Vector1,id:3502,x:32352,y:32997,varname:node_3502,prsc:2,v1:1;n:type:ShaderForge.SFN_Slider,id:5375,x:32083,y:33113,ptovrint:False,ptlb:Transparency,ptin:_Transparency,varname:_Transparency,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.6654282,max:1;n:type:ShaderForge.SFN_ValueProperty,id:5508,x:29926,y:33369,ptovrint:False,ptlb:Tiling,ptin:_Tiling,varname:_Tiling,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:2;n:type:ShaderForge.SFN_Multiply,id:3047,x:30230,y:33347,varname:node_3047,prsc:1|A-6321-UVOUT,B-5508-OUT;n:type:ShaderForge.SFN_TexCoord,id:6321,x:29956,y:33821,varname:node_6321,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Multiply,id:409,x:31126,y:32653,varname:node_409,prsc:2|A-9358-OUT,B-9741-OUT;n:type:ShaderForge.SFN_Vector1,id:3874,x:30589,y:32321,varname:node_3874,prsc:2,v1:1;n:type:ShaderForge.SFN_Vector1,id:9741,x:30589,y:32422,varname:node_9741,prsc:2,v1:0;proporder:1936-7271-6975-8595-7417-9751-5375-580-5508-4386;pass:END;sub:END;*/

Shader "FX Kimi/Water/Water mobile" {
    Properties {
        _WaterColor ("Water Color", Color) = (0.007352948,0.6303247,1,1)
        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _RimDistance ("Rim Distance", Range(0, 1)) = 0.6944705
        _Speed ("Speed", Range(-10, 10)) = 0.5
        _Smooths ("Smooths", Range(0, 1)) = 0
        _SmoothsLight ("Smooths Light", Range(-1, 1)) = 0.4266556
        _Transparency ("Transparency", Range(0, 1)) = 0.6654282
        _SmoothsTiling ("Smooths Tiling", Float ) = 0.25
        _Tiling ("Tiling", Float ) = 2
        _Texture ("Texture", 2D) = "white" {}
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
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform sampler2D _CameraDepthTexture;
            uniform half4 _WaterColor;
            uniform half4 _RimColor;
            uniform half _RimDistance;
            uniform sampler2D _Texture; uniform float4 _Texture_ST;
            uniform half _Speed;
            uniform float _Smooths;
            uniform float _SmoothsLight;
            uniform half _SmoothsTiling;
            uniform float _Transparency;
            uniform float _Tiling;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float4 projPos : TEXCOORD3;
                UNITY_FOG_COORDS(4)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                o.projPos = ComputeScreenPos (o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
                float sceneZ = max(0,LinearEyeDepth (UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)))) - _ProjectionParams.g);
                float partZ = max(0,i.projPos.z - _ProjectionParams.g);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = 1;
                float3 attenColor = attenuation * _LightColor0.xyz;
                float Pi = 3.141592654;
                float InvPi = 0.31830988618;
///////// Gloss:
                float gloss = 1.0 - 0.5; // Convert roughness to gloss
                float perceptualRoughness = 0.5;
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
                float node_9741 = 0.0;
                float node_1264 = saturate((sceneZ-partZ)/1.0);
                half node_7374 = (_RimColor.a*(saturate((sceneZ-partZ)/_RimDistance)-(saturate((sceneZ-partZ)/node_9741)*node_9741)));
                half4 node_1767 = _Time;
                half Wavespeed = (node_1767.g*(_Speed*0.1));
                half node_2821 = Wavespeed;
                half2 node_3047 = (i.uv0*_Tiling);
                half2 node_9953 = (node_3047+node_2821*float2(0.5,2));
                half4 _node_8543 = tex2D(_Texture,TRANSFORM_TEX(node_9953, _Texture));
                half2 node_7000 = (node_3047+node_2821*float2(-0.5,1.5));
                half4 _node_1311 = tex2D(_Texture,TRANSFORM_TEX(node_7000, _Texture));
                half node_4929 = (node_7374+(node_7374*(1.0 - (_node_8543.r*_node_1311.r))*_RimColor.a));
                float node_4664 = 3.0;
                half node_3789 = Wavespeed;
                half2 node_9700 = ((i.uv0+node_3789*float2(0,1))*_SmoothsTiling);
                half4 _node_7528 = tex2D(_Texture,TRANSFORM_TEX(node_9700, _Texture));
                half2 node_7853 = ((i.uv0+node_3789*float2(0.1,0))*_SmoothsTiling);
                half4 _node_8531 = tex2D(_Texture,TRANSFORM_TEX(node_7853, _Texture));
                half node_1777 = (smoothstep( 0.0, _Smooths, (_node_7528.r-_node_8531.r) )*_SmoothsLight);
                float3 diffuseColor = lerp(lerp(lerp(_WaterColor.rgb,(_WaterColor.rgb*(1.0 - node_9741)),node_1264),_RimColor.rgb,saturate(node_4929)),float3(node_4664,node_4664,node_4664),node_1777); // Need this for specular when using metallic
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
                float3 indirectDiffuse = float3(0,0,0);
                indirectDiffuse += UNITY_LIGHTMODEL_AMBIENT.rgb; // Ambient Light
                float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
/// Final Color:
                float3 finalColor = diffuse + specular;
                fixed4 finalRGBA = fixed4(finalColor,(saturate(( lerp(_Transparency,1.0,node_4929) > 0.5 ? (1.0-(1.0-2.0*(lerp(_Transparency,1.0,node_4929)-0.5))*(1.0-node_1264)) : (2.0*lerp(_Transparency,1.0,node_4929)*node_1264) ))+saturate(node_1777)));
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
