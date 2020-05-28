// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:32991,y:32710,varname:node_3138,prsc:2|emission-5590-OUT,alpha-147-OUT;n:type:ShaderForge.SFN_Color,id:7241,x:32306,y:32779,ptovrint:False,ptlb:Color,ptin:_Color,varname:_Color,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Tex2d,id:549,x:32306,y:32988,ptovrint:False,ptlb:Texture,ptin:_Texture,varname:_Texture,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:f6d91bb3557099c44b4b1bf89fc29d18,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:5590,x:32683,y:32828,varname:node_5590,prsc:2|A-7241-RGB,B-2952-OUT,C-7471-OUT,D-2373-RGB;n:type:ShaderForge.SFN_Slider,id:7471,x:32149,y:33218,ptovrint:False,ptlb:Glow,ptin:_Glow,varname:_Glow,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1.581196,max:5;n:type:ShaderForge.SFN_VertexColor,id:2373,x:32306,y:32641,varname:node_2373,prsc:2;n:type:ShaderForge.SFN_Multiply,id:147,x:32683,y:32970,varname:node_147,prsc:2|A-7241-A,B-549-A,C-2373-A;n:type:ShaderForge.SFN_Slider,id:4379,x:32213,y:32482,ptovrint:False,ptlb:Strength,ptin:_Strength,varname:_Strength,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:2;n:type:ShaderForge.SFN_Subtract,id:2952,x:32613,y:32558,varname:node_2952,prsc:2|A-549-RGB,B-4379-OUT;proporder:7241-549-7471-4379;pass:END;sub:END;*/

Shader "FX Kimi/Alpha/Alpha Blend" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _Texture ("Texture", 2D) = "white" {}
        _Glow ("Glow", Range(0, 5)) = 1.581196
        _Strength ("Strength", Range(0, 2)) = 0
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
            uniform half _Glow;
            uniform half _Strength;
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
                half4 _Texture_var = tex2D(_Texture,TRANSFORM_TEX(i.uv0, _Texture));
                float3 emissive = (_Color.rgb*(_Texture_var.rgb-_Strength)*_Glow*i.vertexColor.rgb);
                float3 finalColor = emissive;
                return fixed4(finalColor,(_Color.a*_Texture_var.a*i.vertexColor.a));
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
