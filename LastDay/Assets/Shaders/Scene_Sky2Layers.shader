// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:6,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:False,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:4013,x:32948,y:32728,varname:node_4013,prsc:2|emission-2731-OUT,alpha-3669-OUT;n:type:ShaderForge.SFN_Color,id:1304,x:32301,y:32422,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_1304,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Tex2d,id:1510,x:32078,y:32543,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:node_1510,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-9138-OUT;n:type:ShaderForge.SFN_Time,id:9169,x:31431,y:32917,varname:node_9169,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:8758,x:31431,y:32821,ptovrint:False,ptlb:U1Speed,ptin:_U1Speed,varname:node_8758,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.05;n:type:ShaderForge.SFN_ValueProperty,id:6785,x:31431,y:33096,ptovrint:False,ptlb:V1Speed,ptin:_V1Speed,varname:_node_8758_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:516,x:31659,y:32967,varname:node_516,prsc:2|A-8758-OUT,B-9169-T;n:type:ShaderForge.SFN_Multiply,id:415,x:31659,y:33107,varname:node_415,prsc:2|A-9169-T,B-6785-OUT;n:type:ShaderForge.SFN_Append,id:2273,x:31830,y:32953,varname:node_2273,prsc:2|A-516-OUT,B-415-OUT;n:type:ShaderForge.SFN_TexCoord,id:9478,x:31407,y:32477,varname:node_9478,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Add,id:9138,x:31807,y:32677,varname:node_9138,prsc:2|A-9478-UVOUT,B-2273-OUT;n:type:ShaderForge.SFN_Tex2d,id:6232,x:32020,y:32710,ptovrint:False,ptlb:MainTex02,ptin:_MainTex02,varname:_node_1510_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-5688-OUT;n:type:ShaderForge.SFN_ValueProperty,id:547,x:31431,y:33320,ptovrint:False,ptlb:U2Speed,ptin:_U2Speed,varname:_USpeed_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.1;n:type:ShaderForge.SFN_ValueProperty,id:5622,x:31431,y:33547,ptovrint:False,ptlb:VSpeed,ptin:_VSpeed,varname:_VSpeed_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:4826,x:31646,y:33448,varname:node_4826,prsc:2|A-547-OUT,B-9169-T;n:type:ShaderForge.SFN_Multiply,id:4744,x:31646,y:33649,varname:node_4744,prsc:2|A-9169-T,B-5622-OUT;n:type:ShaderForge.SFN_Append,id:943,x:31849,y:33558,varname:node_943,prsc:2|A-4826-OUT,B-4744-OUT;n:type:ShaderForge.SFN_Add,id:5688,x:31850,y:33242,varname:node_5688,prsc:2|A-9478-UVOUT,B-943-OUT;n:type:ShaderForge.SFN_Lerp,id:6441,x:32324,y:32741,varname:node_6441,prsc:2|A-1510-RGB,B-6232-RGB,T-6682-OUT;n:type:ShaderForge.SFN_Vector1,id:6682,x:32086,y:33276,varname:node_6682,prsc:2,v1:0.5;n:type:ShaderForge.SFN_ValueProperty,id:595,x:32301,y:32328,ptovrint:False,ptlb:Intensity,ptin:_Intensity,varname:node_595,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:5015,x:32495,y:32495,varname:node_5015,prsc:2|A-595-OUT,B-1304-RGB,C-6441-OUT;n:type:ShaderForge.SFN_ComponentMask,id:1278,x:32306,y:32938,varname:node_1278,prsc:2,cc1:0,cc2:-1,cc3:-1,cc4:-1|IN-226-OUT;n:type:ShaderForge.SFN_Blend,id:226,x:32102,y:32968,varname:node_226,prsc:2,blmd:6,clmp:True|SRC-1510-A,DST-6232-A;n:type:ShaderForge.SFN_Power,id:5274,x:32493,y:32938,varname:node_5274,prsc:2|VAL-1278-OUT,EXP-7292-OUT;n:type:ShaderForge.SFN_Color,id:2474,x:32493,y:32782,ptovrint:False,ptlb:BGColor,ptin:_BGColor,varname:_Color_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.2649222,c2:0.3700036,c3:0.5147059,c4:1;n:type:ShaderForge.SFN_Lerp,id:2731,x:32721,y:32682,varname:node_2731,prsc:2|A-2474-RGB,B-5015-OUT,T-5274-OUT;n:type:ShaderForge.SFN_VertexColor,id:8467,x:32457,y:33187,varname:node_8467,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:7292,x:32306,y:33136,ptovrint:False,ptlb:MaskInstensity,ptin:_MaskInstensity,varname:node_7292,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_ToggleProperty,id:9343,x:32477,y:33093,ptovrint:False,ptlb:Toggie,ptin:_Toggie,varname:node_9343,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False;n:type:ShaderForge.SFN_Add,id:2095,x:32672,y:32979,varname:node_2095,prsc:2|A-5274-OUT,B-9343-OUT;n:type:ShaderForge.SFN_Multiply,id:3669,x:32749,y:33209,varname:node_3669,prsc:2|A-2095-OUT,B-8467-A,C-6688-OUT;n:type:ShaderForge.SFN_Slider,id:6688,x:32457,y:33451,ptovrint:False,ptlb:OpacityIntenisty,ptin:_OpacityIntenisty,varname:node_6688,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;proporder:1510-6232-595-1304-8758-6785-547-5622-2474-7292-9343-6688;pass:END;sub:END;*/

Shader "Shader Forge/Scene_Sky2Layers" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _MainTex02 ("MainTex02", 2D) = "white" {}
        _Intensity ("Intensity", Float ) = 1
        _Color ("Color", Color) = (1,1,1,1)
        _U1Speed ("U1Speed", Float ) = 0.05
        _V1Speed ("V1Speed", Float ) = 0
        _U2Speed ("U2Speed", Float ) = 0.1
        _VSpeed ("VSpeed", Float ) = 0
        _BGColor ("BGColor", Color) = (0.2649222,0.3700036,0.5147059,1)
        _MaskInstensity ("MaskInstensity", Float ) = 1
        [MaterialToggle] _Toggie ("Toggie", Float ) = 0
        _OpacityIntenisty ("OpacityIntenisty", Range(0, 1)) = 1
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
            ZTest Always
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal n3ds wiiu 
            #pragma target 3.0
            uniform float4 _Color;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float _U1Speed;
            uniform float _V1Speed;
            uniform sampler2D _MainTex02; uniform float4 _MainTex02_ST;
            uniform float _U2Speed;
            uniform float _VSpeed;
            uniform float _Intensity;
            uniform float4 _BGColor;
            uniform float _MaskInstensity;
            uniform fixed _Toggie;
            uniform float _OpacityIntenisty;
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
            float4 frag(VertexOutput i) : COLOR {
////// Lighting:
////// Emissive:
                float4 node_9169 = _Time;
                float2 node_9138 = (i.uv0+float2((_U1Speed*node_9169.g),(node_9169.g*_V1Speed)));
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(node_9138, _MainTex));
                float2 node_5688 = (i.uv0+float2((_U2Speed*node_9169.g),(node_9169.g*_VSpeed)));
                float4 _MainTex02_var = tex2D(_MainTex02,TRANSFORM_TEX(node_5688, _MainTex02));
                float node_5274 = pow(saturate((1.0-(1.0-_MainTex_var.a)*(1.0-_MainTex02_var.a))).r,_MaskInstensity);
                float3 emissive = lerp(_BGColor.rgb,(_Intensity*_Color.rgb*lerp(_MainTex_var.rgb,_MainTex02_var.rgb,0.5)),node_5274);
                float3 finalColor = emissive;
                return fixed4(finalColor,((node_5274+_Toggie)*i.vertexColor.a*_OpacityIntenisty));
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
