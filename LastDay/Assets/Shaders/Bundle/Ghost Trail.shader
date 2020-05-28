// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:32785,y:32712,varname:node_3138,prsc:2|emission-3066-OUT,alpha-9709-OUT;n:type:ShaderForge.SFN_Color,id:7241,x:32136,y:32701,ptovrint:False,ptlb:Color,ptin:_Color,varname:_Color,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.6102941,c2:0,c3:0,c4:1;n:type:ShaderForge.SFN_Tex2d,id:1431,x:32136,y:32936,ptovrint:False,ptlb:Texture,ptin:_Texture,varname:_Texture,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:cf3c7913375cc7440ad5b7d53d21ce52,ntxv:0,isnm:False|UVIN-6543-OUT;n:type:ShaderForge.SFN_Add,id:6543,x:31932,y:32936,varname:node_6543,prsc:1|A-1661-OUT,B-601-UVOUT;n:type:ShaderForge.SFN_Multiply,id:1661,x:31691,y:32776,varname:node_1661,prsc:2|A-7030-OUT,B-6891-OUT;n:type:ShaderForge.SFN_TexCoord,id:601,x:30665,y:32960,varname:node_601,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Append,id:6891,x:31497,y:32776,varname:node_6891,prsc:2|A-1820-R,B-1820-R;n:type:ShaderForge.SFN_Tex2d,id:1820,x:31276,y:32759,ptovrint:False,ptlb:Noise Texture,ptin:_NoiseTexture,varname:_NoiseTexture,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:26940a844551b6942ab4ac275966f126,ntxv:0,isnm:False|UVIN-525-OUT;n:type:ShaderForge.SFN_RemapRange,id:7030,x:31497,y:33134,varname:node_7030,prsc:2,frmn:0,frmx:1,tomn:0,tomx:0.1|IN-8652-OUT;n:type:ShaderForge.SFN_RemapRange,id:8652,x:31271,y:33134,varname:node_8652,prsc:1,frmn:0,frmx:1000,tomn:0,tomx:1|IN-9622-OUT;n:type:ShaderForge.SFN_Add,id:6735,x:31065,y:32776,varname:node_6735,prsc:1|A-8652-OUT,B-601-UVOUT;n:type:ShaderForge.SFN_Slider,id:9622,x:30912,y:33133,ptovrint:False,ptlb:Noise,ptin:_Noise,varname:_Noise,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:3,max:3000;n:type:ShaderForge.SFN_Multiply,id:3066,x:32489,y:32833,varname:node_3066,prsc:2|A-1431-RGB,B-7241-RGB,C-6571-RGB;n:type:ShaderForge.SFN_VertexColor,id:6571,x:32136,y:32538,varname:node_6571,prsc:2;n:type:ShaderForge.SFN_Multiply,id:9709,x:32489,y:33032,varname:node_9709,prsc:2|A-6571-A,B-7241-A,C-1431-R,D-8858-OUT;n:type:ShaderForge.SFN_Slider,id:8858,x:32084,y:33235,ptovrint:False,ptlb:Glow,ptin:_Glow,varname:_Glow,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:3,max:3;n:type:ShaderForge.SFN_Multiply,id:525,x:31065,y:32579,varname:node_525,prsc:1|A-6735-OUT,B-601-U;proporder:7241-1431-1820-9622-8858;pass:END;sub:END;*/

Shader "FX Kimi/Trail/Ghost Trail" {
    Properties {
        _Color ("Color", Color) = (0.6102941,0,0,1)
        _Texture ("Texture", 2D) = "white" {}
        _NoiseTexture ("Noise Texture", 2D) = "white" {}
        _Noise ("Noise", Range(0, 3000)) = 3
        _Glow ("Glow", Range(0, 3)) = 3
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
            uniform half4 _Color;
            uniform sampler2D _Texture; uniform float4 _Texture_ST;
            uniform sampler2D _NoiseTexture; uniform float4 _NoiseTexture_ST;
            uniform half _Noise;
            uniform half _Glow;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
////// Lighting:
////// Emissive:
                half node_8652 = (_Noise*0.001+0.0);
                half2 node_525 = ((node_8652+i.uv0)*i.uv0.r);
                half4 _NoiseTexture_var = tex2D(_NoiseTexture,TRANSFORM_TEX(node_525, _NoiseTexture));
                half2 node_6543 = (((node_8652*0.1+0.0)*float2(_NoiseTexture_var.r,_NoiseTexture_var.r))+i.uv0);
                half4 _Texture_var = tex2D(_Texture,TRANSFORM_TEX(node_6543, _Texture));
                float3 emissive = (_Texture_var.rgb*_Color.rgb*i.vertexColor.rgb);
                float3 finalColor = emissive;
                return fixed4(finalColor,(i.vertexColor.a*_Color.a*_Texture_var.r*_Glow));
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
