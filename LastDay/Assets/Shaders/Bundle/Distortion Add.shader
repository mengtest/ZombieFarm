// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:0,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:False,qofs:0,qpre:2,rntp:3,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.1397059,fgcg:0.1397059,fgcb:0.1397059,fgca:1,fgde:0.01,fgrn:0,fgrf:150,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True,fsmp:False;n:type:ShaderForge.SFN_Final,id:8870,x:34455,y:32674,varname:node_8870,prsc:2|emission-7624-OUT,clip-1508-OUT;n:type:ShaderForge.SFN_Tex2d,id:1722,x:33004,y:32866,ptovrint:False,ptlb:D_Tex,ptin:_D_Tex,varname:_D_Tex,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Color,id:4767,x:33568,y:32430,ptovrint:False,ptlb:Color,ptin:_Color,varname:_Color,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Tex2d,id:3600,x:33004,y:33107,ptovrint:False,ptlb:E_Tex,ptin:_E_Tex,varname:_E_Tex,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:107,x:33364,y:33051,varname:node_107,prsc:1|A-1722-R,B-3600-R,C-1696-R;n:type:ShaderForge.SFN_Multiply,id:4038,x:33566,y:32972,varname:node_4038,prsc:2|A-5502-A,B-107-OUT;n:type:ShaderForge.SFN_Multiply,id:3747,x:33759,y:33005,varname:node_3747,prsc:2|A-4038-OUT,B-2692-OUT;n:type:ShaderForge.SFN_ValueProperty,id:2692,x:33576,y:33125,ptovrint:False,ptlb:Power,ptin:_Power,varname:_Power,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:5;n:type:ShaderForge.SFN_VertexColor,id:5502,x:33520,y:32802,varname:node_5502,prsc:2;n:type:ShaderForge.SFN_Multiply,id:1508,x:34021,y:32904,varname:node_1508,prsc:1|A-5502-A,B-3747-OUT,C-4767-A;n:type:ShaderForge.SFN_Multiply,id:1847,x:33253,y:32834,varname:node_1847,prsc:2|A-2328-OUT,B-107-OUT;n:type:ShaderForge.SFN_Multiply,id:5525,x:33862,y:32604,varname:node_5525,prsc:1|A-4767-RGB,B-3070-OUT,C-5502-RGB;n:type:ShaderForge.SFN_ValueProperty,id:794,x:33160,y:32686,ptovrint:False,ptlb:Fresnel,ptin:_Fresnel,varname:_Fresnel,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:4627,x:33392,y:32686,varname:node_4627,prsc:1|A-794-OUT,B-1847-OUT;n:type:ShaderForge.SFN_ValueProperty,id:7904,x:33392,y:32582,ptovrint:False,ptlb:Glow,ptin:_Glow,varname:_Glow,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:6;n:type:ShaderForge.SFN_Vector1,id:2328,x:33117,y:32793,varname:node_2328,prsc:2,v1:1;n:type:ShaderForge.SFN_Tex2d,id:1696,x:33004,y:33356,ptovrint:False,ptlb:M_Tex,ptin:_M_Tex,varname:_M_Tex,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:7624,x:34120,y:32708,varname:node_7624,prsc:2|A-5525-OUT,B-1508-OUT;n:type:ShaderForge.SFN_Subtract,id:3070,x:33623,y:32656,varname:node_3070,prsc:2|A-4627-OUT,B-7904-OUT;proporder:1722-4767-3600-2692-794-7904-1696;pass:END;sub:END;*/

Shader "FX Kimi/Distortion/Distortion Add" {
    Properties {
        _D_Tex ("D_Tex", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _E_Tex ("E_Tex", 2D) = "white" {}
        _Power ("Power", Float ) = 5
        _Fresnel ("Fresnel", Float ) = 1
        _Glow ("Glow", Float ) = 6
        _M_Tex ("M_Tex", 2D) = "white" {}
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
            #pragma multi_compile_fwdbase_fullshadows
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform sampler2D _D_Tex; uniform float4 _D_Tex_ST;
            uniform half4 _Color;
            uniform sampler2D _E_Tex; uniform float4 _E_Tex_ST;
            uniform half _Power;
            uniform half _Fresnel;
            uniform half _Glow;
            uniform sampler2D _M_Tex; uniform float4 _M_Tex_ST;
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
                half4 _D_Tex_var = tex2D(_D_Tex,TRANSFORM_TEX(i.uv0, _D_Tex));
                half4 _E_Tex_var = tex2D(_E_Tex,TRANSFORM_TEX(i.uv0, _E_Tex));
                half4 _M_Tex_var = tex2D(_M_Tex,TRANSFORM_TEX(i.uv0, _M_Tex));
                half node_107 = (_D_Tex_var.r*_E_Tex_var.r*_M_Tex_var.r);
                half node_1508 = (i.vertexColor.a*((i.vertexColor.a*node_107)*_Power)*_Color.a);
                clip(node_1508 - 0.5);
////// Lighting:
////// Emissive:
                float3 emissive = ((_Color.rgb*((_Fresnel*(1.0*node_107))-_Glow)*i.vertexColor.rgb)*node_1508);
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
