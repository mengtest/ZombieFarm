// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True,fsmp:False;n:type:ShaderForge.SFN_Final,id:9361,x:35627,y:32570,varname:node_9361,prsc:2|emission-102-OUT,alpha-5124-OUT,clip-5124-OUT;n:type:ShaderForge.SFN_ScreenPos,id:463,x:32914,y:32675,varname:node_463,prsc:2,sctp:0;n:type:ShaderForge.SFN_Multiply,id:3442,x:33144,y:32675,varname:node_3442,prsc:1|A-463-UVOUT,B-1439-OUT;n:type:ShaderForge.SFN_Tex2d,id:8657,x:33363,y:32675,ptovrint:False,ptlb:Texture Screen,ptin:_TextureScreen,varname:_TextureScreen,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:6e149f7b8c13e5742b9f54f2f207f1b9,ntxv:0,isnm:False|UVIN-3442-OUT;n:type:ShaderForge.SFN_ComponentMask,id:8333,x:33552,y:32675,varname:node_8333,prsc:2,cc1:0,cc2:1,cc3:-1,cc4:-1|IN-8657-RGB;n:type:ShaderForge.SFN_Multiply,id:7310,x:33849,y:32675,varname:node_7310,prsc:2|A-8333-OUT,B-6671-OUT;n:type:ShaderForge.SFN_Add,id:7411,x:33983,y:32768,varname:node_7411,prsc:1|A-7310-OUT,B-1959-UVOUT,C-6835-OUT;n:type:ShaderForge.SFN_TexCoord,id:1959,x:33474,y:32999,varname:node_1959,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Tex2d,id:4934,x:34209,y:32670,ptovrint:False,ptlb:Texture,ptin:_Texture,varname:_Texture,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:6e149f7b8c13e5742b9f54f2f207f1b9,ntxv:0,isnm:False|UVIN-7411-OUT;n:type:ShaderForge.SFN_Tex2d,id:5639,x:34109,y:32962,ptovrint:False,ptlb:Texture Mask,ptin:_TextureMask,varname:_TextureMask,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:931a221bc5d8f414aacea73dda5b41f1,ntxv:0,isnm:False|UVIN-9585-OUT;n:type:ShaderForge.SFN_Multiply,id:1240,x:34607,y:32666,varname:node_1240,prsc:2|A-4934-RGB,B-5639-R,C-3772-RGB;n:type:ShaderForge.SFN_Multiply,id:7695,x:34732,y:32891,varname:node_7695,prsc:2|A-4934-R,B-5639-R,C-2522-OUT,D-3772-A;n:type:ShaderForge.SFN_VertexColor,id:3772,x:34138,y:32470,varname:node_3772,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:1439,x:33224,y:32921,ptovrint:False,ptlb:Screen Size,ptin:_ScreenSize,varname:_ScreenSize,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.2;n:type:ShaderForge.SFN_ValueProperty,id:6671,x:33224,y:33074,ptovrint:False,ptlb:Screen Twist,ptin:_ScreenTwist,varname:_ScreenTwist,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.5;n:type:ShaderForge.SFN_Multiply,id:102,x:34863,y:32751,varname:node_102,prsc:2|A-1240-OUT,B-7695-OUT,C-8045-RGB;n:type:ShaderForge.SFN_Step,id:4269,x:34746,y:32507,varname:node_4269,prsc:2|A-7995-OUT,B-1338-OUT;n:type:ShaderForge.SFN_Multiply,id:7995,x:34397,y:32821,varname:node_7995,prsc:2|A-4934-R,B-5639-R;n:type:ShaderForge.SFN_Vector1,id:1338,x:34431,y:32496,varname:node_1338,prsc:2,v1:0.4;n:type:ShaderForge.SFN_OneMinus,id:6796,x:34993,y:32566,varname:node_6796,prsc:2|IN-4269-OUT;n:type:ShaderForge.SFN_Multiply,id:5124,x:35113,y:32809,varname:node_5124,prsc:1|A-6796-OUT,B-3772-A,C-4244-OUT,D-8045-A;n:type:ShaderForge.SFN_Slider,id:4244,x:34782,y:33070,ptovrint:False,ptlb:Opacity,ptin:_Opacity,varname:_Opacity,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.5042735,max:1;n:type:ShaderForge.SFN_Time,id:7247,x:33861,y:32263,varname:node_7247,prsc:1;n:type:ShaderForge.SFN_Slider,id:8583,x:33444,y:32500,ptovrint:False,ptlb:Panner,ptin:_Panner,varname:_Panner,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-1,cur:-0.5443658,max:1;n:type:ShaderForge.SFN_Multiply,id:6677,x:34048,y:32263,varname:node_6677,prsc:2|A-7247-T,B-8583-OUT;n:type:ShaderForge.SFN_Add,id:6835,x:33983,y:32536,varname:node_6835,prsc:2|A-1959-UVOUT,B-6677-OUT;n:type:ShaderForge.SFN_Add,id:9585,x:33704,y:32976,varname:node_9585,prsc:1|A-7310-OUT,B-1959-UVOUT;n:type:ShaderForge.SFN_Color,id:8045,x:34746,y:32299,ptovrint:False,ptlb:Color,ptin:_Color,varname:_Color,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Vector1,id:2522,x:34490,y:33033,varname:node_2522,prsc:2,v1:2;proporder:8657-4934-5639-1439-6671-4244-8583-8045;pass:END;sub:END;*/

Shader "FX Kimi/Fire/Fire particle" {
    Properties {
        _TextureScreen ("Texture Screen", 2D) = "white" {}
        _Texture ("Texture", 2D) = "white" {}
        _TextureMask ("Texture Mask", 2D) = "white" {}
        _ScreenSize ("Screen Size", Float ) = 0.2
        _ScreenTwist ("Screen Twist", Float ) = 0.5
        _Opacity ("Opacity", Range(0, 1)) = 0.5042735
        _Panner ("Panner", Range(-1, 1)) = -0.5443658
        _Color ("Color", Color) = (1,1,1,1)
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
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform sampler2D _TextureScreen; uniform float4 _TextureScreen_ST;
            uniform sampler2D _Texture; uniform float4 _Texture_ST;
            uniform sampler2D _TextureMask; uniform float4 _TextureMask_ST;
            uniform half _ScreenSize;
            uniform half _ScreenTwist;
            uniform half _Opacity;
            uniform half _Panner;
            uniform float4 _Color;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
                float4 projPos : TEXCOORD1;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos( v.vertex );
                o.projPos = ComputeScreenPos (o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                float2 sceneUVs = (i.projPos.xy / i.projPos.w);
                half2 node_3442 = ((sceneUVs * 2 - 1).rg*_ScreenSize);
                half4 _TextureScreen_var = tex2D(_TextureScreen,TRANSFORM_TEX(node_3442, _TextureScreen));
                float2 node_7310 = (_TextureScreen_var.rgb.rg*_ScreenTwist);
                half4 node_7247 = _Time;
                half2 node_7411 = (node_7310+i.uv0+(i.uv0+(node_7247.g*_Panner)));
                half4 _Texture_var = tex2D(_Texture,TRANSFORM_TEX(node_7411, _Texture));
                half2 node_9585 = (node_7310+i.uv0);
                half4 _TextureMask_var = tex2D(_TextureMask,TRANSFORM_TEX(node_9585, _TextureMask));
                half node_5124 = ((1.0 - step((_Texture_var.r*_TextureMask_var.r),0.4))*i.vertexColor.a*_Opacity*_Color.a);
                clip(node_5124 - 0.5);
////// Lighting:
////// Emissive:
                float3 emissive = ((_Texture_var.rgb*_TextureMask_var.r*i.vertexColor.rgb)*(_Texture_var.r*_TextureMask_var.r*2.0*i.vertexColor.a)*_Color.rgb);
                float3 finalColor = emissive;
                return fixed4(finalColor,node_5124);
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
