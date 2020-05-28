// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:3,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:0,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:False,qofs:0,qpre:2,rntp:3,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True,fsmp:False;n:type:ShaderForge.SFN_Final,id:9361,x:37569,y:32392,varname:node_9361,prsc:2|emission-2381-OUT,clip-7348-OUT;n:type:ShaderForge.SFN_Tex2d,id:4283,x:36031,y:32764,ptovrint:False,ptlb:Texture,ptin:_Texture,varname:_Texture,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:9676cafee0e67ec4b80e2f51dc0d27d8,ntxv:0,isnm:False;n:type:ShaderForge.SFN_VertexColor,id:901,x:36481,y:32636,varname:node_901,prsc:2;n:type:ShaderForge.SFN_Multiply,id:6376,x:36688,y:32759,varname:node_6376,prsc:2|A-901-A,B-7711-OUT,C-2378-A;n:type:ShaderForge.SFN_Subtract,id:7711,x:36349,y:32781,varname:node_7711,prsc:2|A-4283-R,B-300-OUT;n:type:ShaderForge.SFN_Color,id:2378,x:36481,y:32478,ptovrint:False,ptlb:Color,ptin:_Color,varname:_Color,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.1838235,c2:0,c3:0,c4:1;n:type:ShaderForge.SFN_Multiply,id:1427,x:36842,y:32473,varname:node_1427,prsc:2|A-2378-RGB,B-901-RGB,C-3839-OUT;n:type:ShaderForge.SFN_Tex2d,id:3095,x:36100,y:33145,ptovrint:False,ptlb:Texture Distort,ptin:_TextureDistort,varname:_TextureDistort,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:06dc695b2df649942ad4ad96b75c352d,ntxv:0,isnm:False|UVIN-5354-OUT;n:type:ShaderForge.SFN_Vector2,id:5158,x:35677,y:33286,varname:node_5158,prsc:1,v1:2,v2:2;n:type:ShaderForge.SFN_Multiply,id:4480,x:35674,y:33121,varname:node_4480,prsc:2|A-7876-UVOUT,B-5158-OUT;n:type:ShaderForge.SFN_Slider,id:6032,x:35994,y:33379,ptovrint:False,ptlb:Power,ptin:_Power,varname:_Power,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.3247863,max:1;n:type:ShaderForge.SFN_Multiply,id:7495,x:36627,y:32959,varname:node_7495,prsc:2|A-4283-R,B-6561-OUT,C-1682-OUT,D-3246-OUT;n:type:ShaderForge.SFN_Add,id:7348,x:36951,y:32757,varname:node_7348,prsc:1|A-6376-OUT,B-7495-OUT;n:type:ShaderForge.SFN_Subtract,id:3181,x:36293,y:32459,varname:node_3181,prsc:2|A-4283-R,B-2139-OUT;n:type:ShaderForge.SFN_Slider,id:2139,x:35967,y:32459,ptovrint:False,ptlb:Subtract,ptin:_Subtract,varname:_Subtract,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1.265929,max:3;n:type:ShaderForge.SFN_OneMinus,id:9726,x:36481,y:32313,varname:node_9726,prsc:2|IN-8644-OUT;n:type:ShaderForge.SFN_Multiply,id:3839,x:36689,y:32313,varname:node_3839,prsc:2|A-8227-OUT,B-9726-OUT;n:type:ShaderForge.SFN_Vector1,id:8227,x:36481,y:32248,varname:node_8227,prsc:2,v1:3;n:type:ShaderForge.SFN_Slider,id:300,x:35884,y:33003,ptovrint:False,ptlb:Strength,ptin:_Strength,varname:_Strength,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-1,cur:-0.2564103,max:1;n:type:ShaderForge.SFN_TexCoord,id:7876,x:35232,y:32978,varname:node_7876,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Vector2,id:8445,x:35232,y:33145,varname:node_8445,prsc:1,v1:0.5,v2:0.5;n:type:ShaderForge.SFN_Multiply,id:5207,x:35586,y:32596,varname:node_5207,prsc:1|A-7876-UVOUT,B-8445-OUT;n:type:ShaderForge.SFN_Tex2d,id:5385,x:35816,y:32596,ptovrint:False,ptlb:Texture Mask,ptin:_TextureMask,varname:_TextureMask,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:28c7aad1372ff114b90d330f8a2dd938,ntxv:0,isnm:False|UVIN-5207-OUT;n:type:ShaderForge.SFN_Multiply,id:1682,x:36031,y:32596,varname:node_1682,prsc:1|A-5385-R,B-4283-R,C-5962-OUT;n:type:ShaderForge.SFN_Add,id:8644,x:36293,y:32324,varname:node_8644,prsc:2|A-3181-OUT,B-4283-R,C-2651-OUT;n:type:ShaderForge.SFN_Multiply,id:2651,x:36293,y:32599,varname:node_2651,prsc:2|A-1682-OUT,B-4283-R;n:type:ShaderForge.SFN_Slider,id:5962,x:35598,y:32855,ptovrint:False,ptlb:Glow,ptin:_Glow,varname:_Glow,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:5;n:type:ShaderForge.SFN_Time,id:1649,x:35487,y:33498,varname:node_1649,prsc:1;n:type:ShaderForge.SFN_Slider,id:648,x:35158,y:33654,ptovrint:False,ptlb:Panner U,ptin:_PannerU,varname:_PannerU,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:1,max:5;n:type:ShaderForge.SFN_Slider,id:5298,x:35158,y:33745,ptovrint:False,ptlb:Panner V,ptin:_PannerV,varname:_PannerV,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:0,max:5;n:type:ShaderForge.SFN_Append,id:4975,x:35487,y:33654,varname:node_4975,prsc:2|A-648-OUT,B-5298-OUT;n:type:ShaderForge.SFN_Multiply,id:856,x:35677,y:33498,varname:node_856,prsc:2|A-1649-T,B-4975-OUT;n:type:ShaderForge.SFN_Add,id:5354,x:35855,y:33475,varname:node_5354,prsc:1|A-4480-OUT,B-856-OUT;n:type:ShaderForge.SFN_Multiply,id:2381,x:37268,y:32614,varname:node_2381,prsc:2|A-1427-OUT,B-7348-OUT;n:type:ShaderForge.SFN_Subtract,id:1363,x:36349,y:33009,varname:node_1363,prsc:2|A-3095-R,B-6032-OUT;n:type:ShaderForge.SFN_Vector1,id:3246,x:36488,y:33175,varname:node_3246,prsc:1,v1:1.5;n:type:ShaderForge.SFN_Multiply,id:6561,x:36714,y:33141,varname:node_6561,prsc:2|A-1363-OUT,B-3246-OUT;proporder:2378-4283-5385-3095-6032-2139-300-5962-648-5298;pass:END;sub:END;*/

Shader "FX Kimi/Liquid/Liquid Distortion Add" {
    Properties {
        _Color ("Color", Color) = (0.1838235,0,0,1)
        _Texture ("Texture", 2D) = "white" {}
        _TextureMask ("Texture Mask", 2D) = "white" {}
        _TextureDistort ("Texture Distort", 2D) = "white" {}
        _Power ("Power", Range(0, 1)) = 0.3247863
        _Subtract ("Subtract", Range(0, 3)) = 1.265929
        _Strength ("Strength", Range(-1, 1)) = -0.2564103
        _Glow ("Glow", Range(0, 5)) = 0
        _PannerU ("Panner U", Range(-5, 5)) = 1
        _PannerV ("Panner V", Range(-5, 5)) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "Queue"="AlphaTest"
            "RenderType"="TransparentCutout"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend One One
            Cull Off
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform sampler2D _Texture; uniform float4 _Texture_ST;
            uniform half4 _Color;
            uniform sampler2D _TextureDistort; uniform float4 _TextureDistort_ST;
            uniform half _Power;
            uniform half _Subtract;
            uniform half _Strength;
            uniform sampler2D _TextureMask; uniform float4 _TextureMask_ST;
            uniform half _Glow;
            uniform half _PannerU;
            uniform half _PannerV;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
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
                half4 _Texture_var = tex2D(_Texture,TRANSFORM_TEX(i.uv0, _Texture));
                half4 node_1649 = _Time;
                half2 node_5354 = ((i.uv0*half2(2,2))+(node_1649.g*float2(_PannerU,_PannerV)));
                half4 _TextureDistort_var = tex2D(_TextureDistort,TRANSFORM_TEX(node_5354, _TextureDistort));
                half node_3246 = 1.5;
                half2 node_5207 = (i.uv0*half2(0.5,0.5));
                half4 _TextureMask_var = tex2D(_TextureMask,TRANSFORM_TEX(node_5207, _TextureMask));
                half node_1682 = (_TextureMask_var.r*_Texture_var.r*_Glow);
                half node_7348 = ((i.vertexColor.a*(_Texture_var.r-_Strength)*_Color.a)+(_Texture_var.r*((_TextureDistort_var.r-_Power)*node_3246)*node_1682*node_3246));
                clip(node_7348 - 0.5);
////// Lighting:
////// Emissive:
                float3 emissive = ((_Color.rgb*i.vertexColor.rgb*(3.0*(1.0 - ((_Texture_var.r-_Subtract)+_Texture_var.r+(node_1682*_Texture_var.r)))))*node_7348);
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
