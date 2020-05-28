// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True,fsmp:False;n:type:ShaderForge.SFN_Final,id:9361,x:34497,y:32628,varname:node_9361,prsc:2|emission-2449-OUT,alpha-5214-OUT;n:type:ShaderForge.SFN_Color,id:24,x:32631,y:32710,ptovrint:False,ptlb:Color,ptin:_Color,varname:_Color,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.4852941,c2:0.03568339,c3:0.03568339,c4:1;n:type:ShaderForge.SFN_Multiply,id:2449,x:33181,y:32738,varname:node_2449,prsc:2|A-24-RGB,B-8361-OUT,C-3194-OUT,D-1693-RGB;n:type:ShaderForge.SFN_Step,id:8361,x:32902,y:32961,varname:node_8361,prsc:2|A-1744-OUT,B-3710-OUT;n:type:ShaderForge.SFN_Subtract,id:3710,x:32476,y:33147,varname:node_3710,prsc:2|A-5113-A,B-9348-OUT;n:type:ShaderForge.SFN_Slider,id:9348,x:32075,y:33430,ptovrint:False,ptlb:Subtract,ptin:_Subtract,varname:_Subtract,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-0.5,cur:-0.08974359,max:1;n:type:ShaderForge.SFN_Tex2d,id:5113,x:32134,y:32949,ptovrint:False,ptlb:Smoothstep Tex,ptin:_SmoothstepTex,varname:_SmoothstepTex,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:0668d81508782e34e93138a9cc8ee220,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Smoothstep,id:1868,x:33179,y:33148,varname:node_1868,prsc:1|A-2863-OUT,B-3696-OUT,V-3710-OUT;n:type:ShaderForge.SFN_Vector1,id:2863,x:32902,y:33112,varname:node_2863,prsc:2,v1:0.1;n:type:ShaderForge.SFN_Slider,id:3696,x:32634,y:33327,ptovrint:False,ptlb:Smoothstep,ptin:_Smoothstep,varname:_Smoothstep,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.3589744,max:1;n:type:ShaderForge.SFN_Slider,id:1744,x:32476,y:32961,ptovrint:False,ptlb:Step,ptin:_Step,varname:_Step,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.2735043,max:1;n:type:ShaderForge.SFN_ValueProperty,id:3194,x:32902,y:32860,ptovrint:False,ptlb:Glow,ptin:_Glow,varname:_Glow,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_VertexColor,id:1693,x:33181,y:32562,varname:node_1693,prsc:2;n:type:ShaderForge.SFN_Multiply,id:5214,x:33661,y:32872,varname:node_5214,prsc:1|A-1693-A,B-1868-OUT,C-24-A,D-5113-A;proporder:24-9348-5113-3696-1744-3194;pass:END;sub:END;*/

Shader "FX Kimi/Distortion/Distortion Smoothstep" {
    Properties {
        _Color ("Color", Color) = (0.4852941,0.03568339,0.03568339,1)
        _Subtract ("Subtract", Range(-0.5, 1)) = -0.08974359
        _SmoothstepTex ("Smoothstep Tex", 2D) = "white" {}
        _Smoothstep ("Smoothstep", Range(0, 1)) = 0.3589744
        _Step ("Step", Range(0, 1)) = 0.2735043
        _Glow ("Glow", Float ) = 1
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
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform half4 _Color;
            uniform half _Subtract;
            uniform sampler2D _SmoothstepTex; uniform float4 _SmoothstepTex_ST;
            uniform half _Smoothstep;
            uniform half _Step;
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
////// Lighting:
////// Emissive:
                half4 _SmoothstepTex_var = tex2D(_SmoothstepTex,TRANSFORM_TEX(i.uv0, _SmoothstepTex));
                float node_3710 = (_SmoothstepTex_var.a-_Subtract);
                float3 emissive = (_Color.rgb*step(_Step,node_3710)*_Glow*i.vertexColor.rgb);
                float3 finalColor = emissive;
                fixed4 finalRGBA = fixed4(finalColor,(i.vertexColor.a*smoothstep( 0.1, _Smoothstep, node_3710 )*_Color.a*_SmoothstepTex_var.a));
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
