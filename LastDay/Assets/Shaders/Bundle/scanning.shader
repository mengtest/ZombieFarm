// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:33204,y:32729,varname:node_3138,prsc:2|emission-8165-OUT,alpha-7269-R;n:type:ShaderForge.SFN_Color,id:7241,x:32520,y:32681,ptovrint:False,ptlb:Color,ptin:_Color,varname:_Color,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.07843138,c2:0.3921569,c3:0.7843137,c4:1;n:type:ShaderForge.SFN_TexCoord,id:8363,x:31828,y:33140,varname:node_8363,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Tex2d,id:7269,x:32455,y:32911,ptovrint:False,ptlb:Texture,ptin:_Texture,varname:_Texture,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:931a221bc5d8f414aacea73dda5b41f1,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Sin,id:8470,x:32455,y:33139,varname:node_8470,prsc:2|IN-4265-OUT;n:type:ShaderForge.SFN_RemapRange,id:8362,x:32250,y:33139,varname:node_8362,prsc:2,frmn:0,frmx:1,tomn:0,tomx:3.14|IN-9073-OUT;n:type:ShaderForge.SFN_Subtract,id:6366,x:32717,y:33175,varname:node_6366,prsc:2|A-8470-OUT,B-6703-OUT;n:type:ShaderForge.SFN_Slider,id:6703,x:32321,y:33362,ptovrint:False,ptlb:Scanning Size,ptin:_ScanningSize,varname:_ScanningSize,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-1,cur:0.6153847,max:2;n:type:ShaderForge.SFN_Multiply,id:2740,x:32909,y:33175,varname:node_2740,prsc:1|A-6366-OUT,B-9826-OUT,C-627-OUT;n:type:ShaderForge.SFN_RemapRange,id:9826,x:32717,y:33313,varname:node_9826,prsc:2,frmn:0,frmx:2,tomn:2,tomx:1|IN-6703-OUT;n:type:ShaderForge.SFN_Multiply,id:8165,x:32878,y:32784,varname:node_8165,prsc:2|A-7269-R,B-9174-OUT,C-7241-RGB;n:type:ShaderForge.SFN_Add,id:4265,x:32306,y:33491,varname:node_4265,prsc:2|A-8362-OUT,B-2403-OUT;n:type:ShaderForge.SFN_Slider,id:2403,x:31976,y:33706,ptovrint:False,ptlb:Panner,ptin:_Panner,varname:_Panner,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:-0.08547009,max:5;n:type:ShaderForge.SFN_Clamp,id:9174,x:32878,y:32954,varname:node_9174,prsc:2|IN-2740-OUT,MIN-3377-OUT,MAX-557-OUT;n:type:ShaderForge.SFN_Vector1,id:3377,x:32636,y:33022,varname:node_3377,prsc:2,v1:0.01;n:type:ShaderForge.SFN_Vector1,id:557,x:32643,y:33095,varname:node_557,prsc:2,v1:1;n:type:ShaderForge.SFN_ValueProperty,id:627,x:32717,y:33521,ptovrint:False,ptlb:Glow,ptin:_Glow,varname:_Glow,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:2;n:type:ShaderForge.SFN_Lerp,id:9073,x:32049,y:33190,varname:node_9073,prsc:2|A-8363-U,B-8363-V,T-4078-OUT;n:type:ShaderForge.SFN_Slider,id:1187,x:31734,y:33373,ptovrint:False,ptlb:Angle,ptin:_Angle,varname:_Angle,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:90,max:90;n:type:ShaderForge.SFN_RemapRange,id:4078,x:32088,y:33374,varname:node_4078,prsc:2,frmn:0,frmx:90,tomn:0,tomx:1|IN-1187-OUT;proporder:7241-7269-627-6703-2403-1187;pass:END;sub:END;*/

Shader "FX Kimi/scanning/scanning" {
    Properties {
        _Color ("Color", Color) = (0.07843138,0.3921569,0.7843137,1)
        _Texture ("Texture", 2D) = "white" {}
        _Glow ("Glow", Float ) = 2
        _ScanningSize ("Scanning Size", Range(-1, 2)) = 0.6153847
        _Panner ("Panner", Range(-5, 5)) = -0.08547009
        _Angle ("Angle", Range(0, 90)) = 90
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
            uniform sampler2D _Texture; uniform float4 _Texture_ST;
            uniform half _ScanningSize;
            uniform half _Panner;
            uniform half _Glow;
            uniform half _Angle;
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
////// Lighting:
////// Emissive:
                half4 _Texture_var = tex2D(_Texture,TRANSFORM_TEX(i.uv0, _Texture));
                float3 emissive = (_Texture_var.r*clamp(((sin(((lerp(i.uv0.r,i.uv0.g,(_Angle*0.01111111+0.0))*3.14+0.0)+_Panner))-_ScanningSize)*(_ScanningSize*-0.5+2.0)*_Glow),0.01,1.0)*_Color.rgb);
                float3 finalColor = emissive;
                return fixed4(finalColor,_Texture_var.r);
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
