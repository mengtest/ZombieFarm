// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:3,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:0,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:False,qofs:0,qpre:2,rntp:3,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True,fsmp:False;n:type:ShaderForge.SFN_Final,id:9361,x:34718,y:32688,varname:node_9361,prsc:2|emission-8398-OUT,clip-8817-OUT;n:type:ShaderForge.SFN_TexCoord,id:7963,x:32406,y:32983,varname:node_7963,prsc:2,uv:0,uaff:True;n:type:ShaderForge.SFN_Vector1,id:9808,x:32406,y:33141,varname:node_9808,prsc:2,v1:-0.5;n:type:ShaderForge.SFN_Add,id:7488,x:32590,y:32983,varname:node_7488,prsc:1|A-7963-UVOUT,B-9808-OUT;n:type:ShaderForge.SFN_Vector1,id:6643,x:32590,y:33141,varname:node_6643,prsc:2,v1:4;n:type:ShaderForge.SFN_Multiply,id:8129,x:32783,y:32983,varname:node_8129,prsc:2|A-7488-OUT,B-7488-OUT,C-6643-OUT;n:type:ShaderForge.SFN_ComponentMask,id:4470,x:32956,y:32983,varname:node_4470,prsc:1,cc1:0,cc2:1,cc3:-1,cc4:-1|IN-8129-OUT;n:type:ShaderForge.SFN_Add,id:6713,x:33137,y:32983,varname:node_6713,prsc:2|A-4470-R,B-4470-G;n:type:ShaderForge.SFN_Clamp01,id:1754,x:33317,y:32983,varname:node_1754,prsc:2|IN-6713-OUT;n:type:ShaderForge.SFN_OneMinus,id:8112,x:33505,y:32983,varname:node_8112,prsc:2|IN-1754-OUT;n:type:ShaderForge.SFN_Set,id:2364,x:33676,y:32983,varname:Mask,prsc:1|IN-8112-OUT;n:type:ShaderForge.SFN_Multiply,id:210,x:32590,y:32831,varname:node_210,prsc:2|A-6124-OUT,B-7963-Z;n:type:ShaderForge.SFN_Vector2,id:6124,x:32406,y:32831,varname:node_6124,prsc:1,v1:3,v2:8;n:type:ShaderForge.SFN_ValueProperty,id:7785,x:32401,y:33291,ptovrint:False,ptlb:Tile U,ptin:_TileU,varname:_TileU,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_ValueProperty,id:3897,x:32401,y:33373,ptovrint:False,ptlb:Tile V,ptin:_TileV,varname:_TileV,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Append,id:9326,x:32606,y:33291,varname:node_9326,prsc:2|A-7785-OUT,B-3897-OUT;n:type:ShaderForge.SFN_Multiply,id:1159,x:32809,y:33291,varname:node_1159,prsc:2|A-7963-UVOUT,B-9326-OUT;n:type:ShaderForge.SFN_Add,id:7746,x:33047,y:33291,varname:node_7746,prsc:1|A-210-OUT,B-1159-OUT,C-8996-OUT;n:type:ShaderForge.SFN_Slider,id:7301,x:32249,y:32639,ptovrint:False,ptlb:Panner U,ptin:_PannerU,varname:_PannerU,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.3,max:1;n:type:ShaderForge.SFN_Slider,id:1914,x:32249,y:32730,ptovrint:False,ptlb:Panner V,ptin:_PannerV,varname:_PannerV,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.1,max:1;n:type:ShaderForge.SFN_Append,id:8472,x:32590,y:32639,varname:node_8472,prsc:2|A-7301-OUT,B-1914-OUT;n:type:ShaderForge.SFN_Multiply,id:8996,x:32795,y:32639,varname:node_8996,prsc:2|A-3261-T,B-8472-OUT;n:type:ShaderForge.SFN_Time,id:3261,x:32590,y:32474,varname:node_3261,prsc:1;n:type:ShaderForge.SFN_Tex2d,id:317,x:33272,y:33291,ptovrint:False,ptlb:Texture,ptin:_Texture,varname:_Texture,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:96b250a9d106f0b4285a65a74275769e,ntxv:0,isnm:False|UVIN-7746-OUT;n:type:ShaderForge.SFN_Add,id:5634,x:33469,y:33291,varname:node_5634,prsc:2|A-317-R,B-4137-OUT;n:type:ShaderForge.SFN_Vector1,id:4137,x:33272,y:33472,varname:node_4137,prsc:2,v1:0.45;n:type:ShaderForge.SFN_Multiply,id:8817,x:33666,y:33291,varname:node_8817,prsc:1|A-5634-OUT,B-9206-OUT,C-2506-OUT;n:type:ShaderForge.SFN_VertexColor,id:3167,x:33719,y:32534,varname:node_3167,prsc:2;n:type:ShaderForge.SFN_Set,id:1797,x:33387,y:32509,varname:Alpha,prsc:1|IN-3167-A;n:type:ShaderForge.SFN_Vector1,id:6389,x:33200,y:32598,varname:node_6389,prsc:1,v1:0.5;n:type:ShaderForge.SFN_ValueProperty,id:6114,x:33200,y:32732,ptovrint:False,ptlb:Subtract,ptin:_Subtract,varname:_Subtract,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.5;n:type:ShaderForge.SFN_Subtract,id:4465,x:33408,y:32635,varname:node_4465,prsc:2|A-6389-OUT,B-6114-OUT;n:type:ShaderForge.SFN_Add,id:707,x:33408,y:32782,varname:node_707,prsc:2|A-6389-OUT,B-6114-OUT;n:type:ShaderForge.SFN_Smoothstep,id:2633,x:33865,y:32793,varname:node_2633,prsc:2|A-4465-OUT,B-707-OUT,V-8817-OUT;n:type:ShaderForge.SFN_Get,id:9206,x:33468,y:33435,varname:node_9206,prsc:2|IN-1797-OUT;n:type:ShaderForge.SFN_Get,id:2506,x:33448,y:33225,varname:node_2506,prsc:2|IN-2364-OUT;n:type:ShaderForge.SFN_Color,id:5884,x:33719,y:32376,ptovrint:False,ptlb:Color,ptin:_Color,varname:_Color,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.3235294,c2:0,c3:0,c4:1;n:type:ShaderForge.SFN_Multiply,id:8398,x:34109,y:32565,varname:node_8398,prsc:2|A-5884-RGB,B-3167-RGB,C-2633-OUT,D-416-OUT;n:type:ShaderForge.SFN_ValueProperty,id:416,x:33865,y:32679,ptovrint:False,ptlb:Glow,ptin:_Glow,varname:_Glow,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:2;proporder:5884-317-416-6114-7785-3897-7301-1914;pass:END;sub:END;*/

Shader "FX Kimi/Liquid/Liquid Distortion Add Oneside" {
    Properties {
        _Color ("Color", Color) = (0.3235294,0,0,1)
        _Texture ("Texture", 2D) = "white" {}
        _Glow ("Glow", Float ) = 2
        _Subtract ("Subtract", Float ) = 0.5
        _TileU ("Tile U", Float ) = 1
        _TileV ("Tile V", Float ) = 1
        _PannerU ("Panner U", Range(0, 1)) = 0.3
        _PannerV ("Panner V", Range(0, 1)) = 0.1
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
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform half _TileU;
            uniform half _TileV;
            uniform half _PannerU;
            uniform half _PannerV;
            uniform sampler2D _Texture; uniform float4 _Texture_ST;
            uniform half _Subtract;
            uniform half4 _Color;
            uniform half _Glow;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float4 vertexColor : COLOR;
                UNITY_FOG_COORDS(3)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
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
                half4 node_3261 = _Time;
                half2 node_7746 = ((half2(3,8)*i.uv0.b)+(i.uv0*float2(_TileU,_TileV))+(node_3261.g*float2(_PannerU,_PannerV)));
                half4 _Texture_var = tex2D(_Texture,TRANSFORM_TEX(node_7746, _Texture));
                half Alpha = i.vertexColor.a;
                half2 node_7488 = (i.uv0+(-0.5));
                half2 node_4470 = (node_7488*node_7488*4.0).rg;
                half Mask = (1.0 - saturate((node_4470.r+node_4470.g)));
                half node_8817 = ((_Texture_var.r+0.45)*Alpha*Mask);
                clip(node_8817 - 0.5);
////// Lighting:
////// Emissive:
                half node_6389 = 0.5;
                float3 emissive = (_Color.rgb*i.vertexColor.rgb*smoothstep( (node_6389-_Subtract), (node_6389+_Subtract), node_8817 )*_Glow);
                float3 finalColor = emissive;
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
