// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:33418,y:32680,varname:node_3138,prsc:2|emission-3098-OUT,alpha-9794-A,clip-9045-OUT;n:type:ShaderForge.SFN_Color,id:7241,x:32386,y:32554,ptovrint:False,ptlb:Color,ptin:_Color,varname:_Color,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_TexCoord,id:6139,x:32065,y:32876,varname:node_6139,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Slider,id:6560,x:31987,y:33138,ptovrint:False,ptlb:Distortion,ptin:_Distortion,varname:_Distortion,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-1,cur:0.2136752,max:1;n:type:ShaderForge.SFN_Add,id:2570,x:32335,y:33057,varname:node_2570,prsc:1|A-6139-V,B-6560-OUT;n:type:ShaderForge.SFN_Tex2d,id:9794,x:32386,y:32777,ptovrint:False,ptlb:Texture,ptin:_Texture,varname:_Texture,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:3098,x:32730,y:32791,varname:node_3098,prsc:2|A-7241-RGB,B-9794-RGB;n:type:ShaderForge.SFN_Multiply,id:2679,x:32601,y:33029,varname:node_2679,prsc:2|A-9794-A,B-2570-OUT;n:type:ShaderForge.SFN_Tex2d,id:4485,x:32498,y:33290,varname:_node_4485,prsc:1,tex:1d2238e03a8db334f8877f1566722d80,ntxv:0,isnm:False|UVIN-823-OUT,TEX-9134-TEX;n:type:ShaderForge.SFN_Time,id:18,x:31523,y:33180,varname:node_18,prsc:1;n:type:ShaderForge.SFN_Multiply,id:6659,x:31903,y:33278,varname:node_6659,prsc:1|A-18-T,B-6408-OUT;n:type:ShaderForge.SFN_Slider,id:3362,x:31367,y:33381,ptovrint:False,ptlb:Panner U1,ptin:_PannerU1,varname:_PannerU1,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:0,max:5;n:type:ShaderForge.SFN_Tex2d,id:560,x:32387,y:33714,ptovrint:False,ptlb:Texture Mask,ptin:_TextureMask,varname:_TextureMask,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:94cf1221d4e5cee49b308ce2a1713532,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Subtract,id:6000,x:32650,y:33715,varname:node_6000,prsc:2|A-560-R,B-6009-OUT;n:type:ShaderForge.SFN_Slider,id:6009,x:32294,y:33965,ptovrint:False,ptlb:Gradual,ptin:_Gradual,varname:_Gradual,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-1,cur:0.4529915,max:1;n:type:ShaderForge.SFN_Add,id:9913,x:32823,y:33236,varname:node_9913,prsc:2|A-5020-OUT,B-5214-OUT;n:type:ShaderForge.SFN_Multiply,id:9045,x:33018,y:33061,varname:node_9045,prsc:2|A-2679-OUT,B-9913-OUT;n:type:ShaderForge.SFN_OneMinus,id:5214,x:32874,y:33695,varname:node_5214,prsc:2|IN-6000-OUT;n:type:ShaderForge.SFN_Tex2dAsset,id:9134,x:32221,y:33552,ptovrint:False,ptlb:Texture UV,ptin:_TextureUV,varname:_TextureUV,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:1d2238e03a8db334f8877f1566722d80,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:6449,x:32498,y:33499,varname:_node_6449,prsc:1,tex:1d2238e03a8db334f8877f1566722d80,ntxv:0,isnm:False|UVIN-7255-OUT,TEX-9134-TEX;n:type:ShaderForge.SFN_Slider,id:1283,x:31366,y:33536,ptovrint:False,ptlb:Panner V1,ptin:_PannerV1,varname:_PannerV1,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:0.2,max:5;n:type:ShaderForge.SFN_Append,id:6408,x:31699,y:33381,varname:node_6408,prsc:2|A-3362-OUT,B-1283-OUT;n:type:ShaderForge.SFN_Add,id:823,x:32197,y:33345,varname:node_823,prsc:1|A-6659-OUT,B-6139-UVOUT;n:type:ShaderForge.SFN_Slider,id:7875,x:31365,y:33772,ptovrint:False,ptlb:Panner U2,ptin:_PannerU2,varname:_PannerU2,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:0,max:5;n:type:ShaderForge.SFN_Slider,id:8413,x:31365,y:33924,ptovrint:False,ptlb:Panner V2,ptin:_PannerV2,varname:_PannerV2,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:0.2,max:5;n:type:ShaderForge.SFN_Append,id:5052,x:31719,y:33770,varname:node_5052,prsc:2|A-7875-OUT,B-8413-OUT;n:type:ShaderForge.SFN_Multiply,id:1433,x:31957,y:33704,varname:node_1433,prsc:2|A-18-T,B-5052-OUT;n:type:ShaderForge.SFN_Add,id:7255,x:32176,y:33746,varname:node_7255,prsc:2|A-6139-UVOUT,B-1433-OUT;n:type:ShaderForge.SFN_Multiply,id:5020,x:32753,y:33482,varname:node_5020,prsc:2|A-4485-R,B-6449-R;proporder:7241-9794-560-9134-6560-6009-3362-1283-7875-8413;pass:END;sub:END;*/

Shader "FX Kimi/Distortion/Directional dissolving Add" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _Texture ("Texture", 2D) = "white" {}
        _TextureMask ("Texture Mask", 2D) = "white" {}
        _TextureUV ("Texture UV", 2D) = "white" {}
        _Distortion ("Distortion", Range(-1, 1)) = 0.2136752
        _Gradual ("Gradual", Range(-1, 1)) = 0.4529915
        _PannerU1 ("Panner U1", Range(-5, 5)) = 0
        _PannerV1 ("Panner V1", Range(-5, 5)) = 0.2
        _PannerU2 ("Panner U2", Range(-5, 5)) = 0
        _PannerV2 ("Panner V2", Range(-5, 5)) = 0.2
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
            Blend One One
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
            uniform half _Distortion;
            uniform sampler2D _Texture; uniform float4 _Texture_ST;
            uniform half _PannerU1;
            uniform sampler2D _TextureMask; uniform float4 _TextureMask_ST;
            uniform float _Gradual;
            uniform sampler2D _TextureUV; uniform float4 _TextureUV_ST;
            uniform half _PannerV1;
            uniform half _PannerU2;
            uniform half _PannerV2;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                half4 _Texture_var = tex2D(_Texture,TRANSFORM_TEX(i.uv0, _Texture));
                half4 node_18 = _Time;
                half2 node_823 = ((node_18.g*float2(_PannerU1,_PannerV1))+i.uv0);
                half4 _node_4485 = tex2D(_TextureUV,TRANSFORM_TEX(node_823, _TextureUV));
                float2 node_7255 = (i.uv0+(node_18.g*float2(_PannerU2,_PannerV2)));
                half4 _node_6449 = tex2D(_TextureUV,TRANSFORM_TEX(node_7255, _TextureUV));
                half4 _TextureMask_var = tex2D(_TextureMask,TRANSFORM_TEX(i.uv0, _TextureMask));
                clip(((_Texture_var.a*(i.uv0.g+_Distortion))*((_node_4485.r*_node_6449.r)+(1.0 - (_TextureMask_var.r-_Gradual)))) - 0.5);
////// Lighting:
////// Emissive:
                float3 emissive = (_Color.rgb*_Texture_var.rgb);
                float3 finalColor = emissive;
                return fixed4(finalColor,_Texture_var.a);
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
