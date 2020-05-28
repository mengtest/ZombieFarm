// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:False,qofs:0,qpre:2,rntp:3,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0,fgcg:0.6275864,fgcb:1,fgca:1,fgde:0.01,fgrn:45,fgrf:120,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True,fsmp:False;n:type:ShaderForge.SFN_Final,id:2024,x:33226,y:32796,varname:node_2024,prsc:2|emission-1174-OUT,clip-4068-OUT;n:type:ShaderForge.SFN_Tex2d,id:1952,x:32360,y:32746,ptovrint:False,ptlb:Tex_01,ptin:_Tex_01,varname:_Tex_01,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:5695,x:31979,y:33115,ptovrint:False,ptlb:Tex_Mask,ptin:_Tex_Mask,varname:_Tex_Mask,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_VertexColor,id:5149,x:31979,y:32877,varname:node_5149,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:1475,x:31979,y:33030,ptovrint:False,ptlb:Glow,ptin:_Glow,varname:_Glow,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:8657,x:32222,y:32940,varname:node_8657,prsc:2|A-5149-A,B-1475-OUT;n:type:ShaderForge.SFN_If,id:6926,x:32247,y:33113,varname:node_6926,prsc:2|A-8657-OUT,B-5695-R,GT-6096-OUT,EQ-6096-OUT,LT-1129-OUT;n:type:ShaderForge.SFN_Vector1,id:1129,x:31979,y:33379,varname:node_1129,prsc:2,v1:1;n:type:ShaderForge.SFN_Vector1,id:6096,x:31979,y:33307,varname:node_6096,prsc:1,v1:0;n:type:ShaderForge.SFN_OneMinus,id:4127,x:32439,y:33113,varname:node_4127,prsc:2|IN-6926-OUT;n:type:ShaderForge.SFN_Color,id:4,x:32360,y:32530,ptovrint:False,ptlb:Color,ptin:_Color,varname:_Color,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Multiply,id:4549,x:32623,y:32722,varname:node_4549,prsc:2|A-4-RGB,B-1952-RGB;n:type:ShaderForge.SFN_Multiply,id:1174,x:32870,y:32856,varname:node_1174,prsc:2|A-4546-OUT,B-5149-RGB;n:type:ShaderForge.SFN_Multiply,id:2399,x:32673,y:33113,varname:node_2399,prsc:2|A-1952-A,B-4127-OUT;n:type:ShaderForge.SFN_Multiply,id:4068,x:32957,y:33083,varname:node_4068,prsc:2|A-4-A,B-2399-OUT;n:type:ShaderForge.SFN_ValueProperty,id:3958,x:32633,y:32562,ptovrint:False,ptlb:Glow_01,ptin:_Glow_01,varname:_Glow_01,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:2;n:type:ShaderForge.SFN_Multiply,id:4546,x:32870,y:32677,varname:node_4546,prsc:2|A-3958-OUT,B-4549-OUT;proporder:1952-4-5695-1475-3958;pass:END;sub:END;*/

Shader "FX Kimi/Distortion/Distortion Blend" {
    Properties {
        _Tex_01 ("Tex_01", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Tex_Mask ("Tex_Mask", 2D) = "white" {}
        _Glow ("Glow", Float ) = 1
        _Glow_01 ("Glow_01", Float ) = 2
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
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform sampler2D _Tex_01; uniform float4 _Tex_01_ST;
            uniform sampler2D _Tex_Mask; uniform float4 _Tex_Mask_ST;
            uniform half _Glow;
            uniform half4 _Color;
            uniform half _Glow_01;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
                UNITY_FOG_COORDS(1)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                half4 _Tex_01_var = tex2D(_Tex_01,TRANSFORM_TEX(i.uv0, _Tex_01));
                half4 _Tex_Mask_var = tex2D(_Tex_Mask,TRANSFORM_TEX(i.uv0, _Tex_Mask));
                float node_6926_if_leA = step((i.vertexColor.a*_Glow),_Tex_Mask_var.r);
                float node_6926_if_leB = step(_Tex_Mask_var.r,(i.vertexColor.a*_Glow));
                half node_6096 = 0.0;
                clip((_Color.a*(_Tex_01_var.a*(1.0 - lerp((node_6926_if_leA*1.0)+(node_6926_if_leB*node_6096),node_6096,node_6926_if_leA*node_6926_if_leB)))) - 0.5);
////// Lighting:
////// Emissive:
                float3 emissive = ((_Glow_01*(_Color.rgb*_Tex_01_var.rgb))*i.vertexColor.rgb);
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
