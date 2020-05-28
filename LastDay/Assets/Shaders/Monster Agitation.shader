// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:33172,y:32706,varname:node_3138,prsc:2|diff-1962-OUT,emission-9011-OUT,olwid-3082-OUT,voffset-2864-OUT;n:type:ShaderForge.SFN_Color,id:7241,x:32338,y:32701,ptovrint:False,ptlb:Color,ptin:_Color,varname:_Color,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.4191176,c2:0,c3:0,c4:1;n:type:ShaderForge.SFN_Tex2d,id:3045,x:32338,y:32932,ptovrint:False,ptlb:Texture,ptin:_Texture,varname:_Texture,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:8d385e3b43ddf284892c758acf9edfec,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:9011,x:32551,y:32701,varname:node_9011,prsc:1|A-7241-RGB,B-4466-OUT;n:type:ShaderForge.SFN_Power,id:4466,x:32588,y:32925,varname:node_4466,prsc:1|VAL-3045-R,EXP-3762-OUT;n:type:ShaderForge.SFN_Exp,id:3762,x:32588,y:33101,varname:node_3762,prsc:2,et:1|IN-5866-OUT;n:type:ShaderForge.SFN_Slider,id:9950,x:31992,y:33212,ptovrint:False,ptlb:Strength,ptin:_Strength,varname:_Strength,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:3,max:5;n:type:ShaderForge.SFN_Tex2d,id:2474,x:31805,y:33269,varname:_node_2474,prsc:1,tex:26940a844551b6942ab4ac275966f126,ntxv:0,isnm:False|TEX-1201-TEX;n:type:ShaderForge.SFN_Tex2dAsset,id:1201,x:31614,y:33162,ptovrint:False,ptlb:Noise Texture,ptin:_NoiseTexture,varname:_NoiseTexture,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:26940a844551b6942ab4ac275966f126,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:6588,x:31805,y:33470,varname:_node_6588,prsc:1,tex:26940a844551b6942ab4ac275966f126,ntxv:0,isnm:False|UVIN-3570-OUT,TEX-1201-TEX;n:type:ShaderForge.SFN_TexCoord,id:2850,x:31331,y:33406,varname:node_2850,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Time,id:1105,x:31090,y:33586,varname:node_1105,prsc:1;n:type:ShaderForge.SFN_Slider,id:5196,x:31005,y:33837,ptovrint:False,ptlb:Panner01 U,ptin:_Panner01U,varname:_Panner01U,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:0.1367521,max:5;n:type:ShaderForge.SFN_Slider,id:3825,x:31005,y:33978,ptovrint:False,ptlb:Panner01 V,ptin:_Panner01V,varname:_Panner01V,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:0,max:5;n:type:ShaderForge.SFN_Append,id:9988,x:31330,y:33837,varname:node_9988,prsc:2|A-5196-OUT,B-3825-OUT;n:type:ShaderForge.SFN_Multiply,id:3521,x:31329,y:33586,varname:node_3521,prsc:2|A-1105-T,B-9988-OUT;n:type:ShaderForge.SFN_Add,id:3570,x:31560,y:33586,varname:node_3570,prsc:1|A-2850-UVOUT,B-3521-OUT;n:type:ShaderForge.SFN_Multiply,id:7863,x:32071,y:33353,varname:node_7863,prsc:2|A-2474-R,B-6588-R;n:type:ShaderForge.SFN_Multiply,id:8026,x:32498,y:33290,varname:node_8026,prsc:2|A-4466-OUT,B-7863-OUT;n:type:ShaderForge.SFN_Multiply,id:2864,x:32733,y:33270,varname:node_2864,prsc:2|A-5586-OUT,B-8026-OUT,C-5823-OUT;n:type:ShaderForge.SFN_NormalVector,id:5586,x:32498,y:33412,prsc:2,pt:False;n:type:ShaderForge.SFN_Slider,id:5823,x:32421,y:33620,ptovrint:False,ptlb:Offset,ptin:_Offset,varname:_Offset,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.1538462,max:1;n:type:ShaderForge.SFN_Tex2d,id:5696,x:32332,y:32256,ptovrint:False,ptlb:Diffuse Texture,ptin:_DiffuseTexture,varname:_DiffuseTexture,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:dcc9475865ea3a047b2180ff3b9f9ec6,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:1962,x:32740,y:32267,varname:node_1962,prsc:2|A-1060-OUT,B-5249-OUT;n:type:ShaderForge.SFN_Slider,id:5249,x:32422,y:32155,ptovrint:False,ptlb:Diffuse Glow,ptin:_DiffuseGlow,varname:_DiffuseGlow,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1.717949,max:3;n:type:ShaderForge.SFN_Multiply,id:5866,x:32149,y:33053,varname:node_5866,prsc:2|A-8628-OUT,B-9950-OUT;n:type:ShaderForge.SFN_ConstantClamp,id:8628,x:32149,y:32856,varname:node_8628,prsc:2,min:0.3,max:1|IN-2099-OUT;n:type:ShaderForge.SFN_Slider,id:594,x:31031,y:32616,ptovrint:False,ptlb:Time Speed,ptin:_TimeSpeed,varname:_TimeSpeed,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.7350427,max:2;n:type:ShaderForge.SFN_Tau,id:2005,x:31464,y:32648,varname:node_2005,prsc:2;n:type:ShaderForge.SFN_Multiply,id:5386,x:31431,y:32782,varname:node_5386,prsc:2|A-594-OUT,B-1105-T;n:type:ShaderForge.SFN_Multiply,id:1128,x:31655,y:32644,varname:node_1128,prsc:2|A-2005-OUT,B-5386-OUT,C-594-OUT;n:type:ShaderForge.SFN_Sin,id:2625,x:31850,y:32644,varname:node_2625,prsc:2|IN-1128-OUT;n:type:ShaderForge.SFN_RemapRange,id:2099,x:32032,y:32644,varname:node_2099,prsc:2,frmn:-1,frmx:2,tomn:0,tomx:1|IN-2625-OUT;n:type:ShaderForge.SFN_Power,id:1060,x:32556,y:32293,varname:node_1060,prsc:2|VAL-5696-RGB,EXP-2312-OUT;n:type:ShaderForge.SFN_Exp,id:2312,x:32585,y:32503,varname:node_2312,prsc:2,et:1|IN-8452-OUT;n:type:ShaderForge.SFN_Slider,id:8452,x:32253,y:32503,ptovrint:False,ptlb:Contrast,ptin:_Contrast,varname:_Contrast,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.3461539,max:1;n:type:ShaderForge.SFN_Slider,id:3082,x:32824,y:33025,ptovrint:False,ptlb:Stroke,ptin:_Stroke,varname:_Stroke,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.05982906,max:1;proporder:7241-5249-5696-3045-1201-9950-5196-3825-5823-594-8452-3082;pass:END;sub:END;*/

Shader "FX Kimi/Monster/Monster Agitation" {
    Properties {
        _Color ("Color", Color) = (0.4191176,0,0,1)
        _DiffuseGlow ("Diffuse Glow", Range(0, 3)) = 1.717949
        _DiffuseTexture ("Diffuse Texture", 2D) = "white" {}
        _Texture ("Texture", 2D) = "white" {}
        _NoiseTexture ("Noise Texture", 2D) = "white" {}
        _Strength ("Strength", Range(0, 5)) = 3
        _Panner01U ("Panner01 U", Range(-5, 5)) = 0.1367521
        _Panner01V ("Panner01 V", Range(-5, 5)) = 0
        _Offset ("Offset", Range(0, 1)) = 0.1538462
        _TimeSpeed ("Time Speed", Range(0, 2)) = 0.7350427
        _Contrast ("Contrast", Range(0, 1)) = 0.3461539
        _Stroke ("Stroke", Range(0, 1)) = 0.05982906
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "Outline"
            Tags {
            }
            Cull Front
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform sampler2D _Texture; uniform float4 _Texture_ST;
            uniform half _Strength;
            uniform sampler2D _NoiseTexture; uniform float4 _NoiseTexture_ST;
            uniform half _Panner01U;
            uniform half _Panner01V;
            uniform half _Offset;
            uniform half _TimeSpeed;
            uniform half _Stroke;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                half4 _Texture_var = tex2Dlod(_Texture,float4(TRANSFORM_TEX(o.uv0, _Texture),0.0,0));
                half4 node_1105 = _Time;
                half node_4466 = pow(_Texture_var.r,exp2((clamp((sin((6.28318530718*(_TimeSpeed*node_1105.g)*_TimeSpeed))*0.3333333+0.3333333),0.3,1)*_Strength)));
                half4 _node_2474 = tex2Dlod(_NoiseTexture,float4(TRANSFORM_TEX(o.uv0, _NoiseTexture),0.0,0));
                half2 node_3570 = (o.uv0+(node_1105.g*float2(_Panner01U,_Panner01V)));
                half4 _node_6588 = tex2Dlod(_NoiseTexture,float4(TRANSFORM_TEX(node_3570, _NoiseTexture),0.0,0));
                v.vertex.xyz += (v.normal*(node_4466*(_node_2474.r*_node_6588.r))*_Offset);
                o.pos = UnityObjectToClipPos( float4(v.vertex.xyz + v.normal*_Stroke,1) );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 normalDirection = i.normalDir;
                return fixed4(float3(0,0,0),0);
            }
            ENDCG
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform half4 _Color;
            uniform sampler2D _Texture; uniform float4 _Texture_ST;
            uniform half _Strength;
            uniform sampler2D _NoiseTexture; uniform float4 _NoiseTexture_ST;
            uniform half _Panner01U;
            uniform half _Panner01V;
            uniform half _Offset;
            uniform sampler2D _DiffuseTexture; uniform float4 _DiffuseTexture_ST;
            uniform half _DiffuseGlow;
            uniform half _TimeSpeed;
            uniform half _Contrast;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                LIGHTING_COORDS(3,4)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                half4 _Texture_var = tex2Dlod(_Texture,float4(TRANSFORM_TEX(o.uv0, _Texture),0.0,0));
                half4 node_1105 = _Time;
                half node_4466 = pow(_Texture_var.r,exp2((clamp((sin((6.28318530718*(_TimeSpeed*node_1105.g)*_TimeSpeed))*0.3333333+0.3333333),0.3,1)*_Strength)));
                half4 _node_2474 = tex2Dlod(_NoiseTexture,float4(TRANSFORM_TEX(o.uv0, _NoiseTexture),0.0,0));
                half2 node_3570 = (o.uv0+(node_1105.g*float2(_Panner01U,_Panner01V)));
                half4 _node_6588 = tex2Dlod(_NoiseTexture,float4(TRANSFORM_TEX(node_3570, _NoiseTexture),0.0,0));
                v.vertex.xyz += (v.normal*(node_4466*(_node_2474.r*_node_6588.r))*_Offset);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 normalDirection = i.normalDir;
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
/////// Diffuse:
                float NdotL = max(0.0,dot( normalDirection, lightDirection ));
                float3 directDiffuse = max( 0.0, NdotL) * attenColor;
                float3 indirectDiffuse = float3(0,0,0);
                indirectDiffuse += UNITY_LIGHTMODEL_AMBIENT.rgb; // Ambient Light
                half4 _DiffuseTexture_var = tex2D(_DiffuseTexture,TRANSFORM_TEX(i.uv0, _DiffuseTexture));
                float3 diffuseColor = (pow(_DiffuseTexture_var.rgb,exp2(_Contrast))*_DiffuseGlow);
                float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
////// Emissive:
                half4 _Texture_var = tex2D(_Texture,TRANSFORM_TEX(i.uv0, _Texture));
                half4 node_1105 = _Time;
                half node_4466 = pow(_Texture_var.r,exp2((clamp((sin((6.28318530718*(_TimeSpeed*node_1105.g)*_TimeSpeed))*0.3333333+0.3333333),0.3,1)*_Strength)));
                float3 emissive = (_Color.rgb*node_4466);
/// Final Color:
                float3 finalColor = diffuse + emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
        Pass {
            Name "FORWARD_DELTA"
            Tags {
                "LightMode"="ForwardAdd"
            }
            Blend One One
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDADD
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdadd_fullshadows
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform half4 _Color;
            uniform sampler2D _Texture; uniform float4 _Texture_ST;
            uniform half _Strength;
            uniform sampler2D _NoiseTexture; uniform float4 _NoiseTexture_ST;
            uniform half _Panner01U;
            uniform half _Panner01V;
            uniform half _Offset;
            uniform sampler2D _DiffuseTexture; uniform float4 _DiffuseTexture_ST;
            uniform half _DiffuseGlow;
            uniform half _TimeSpeed;
            uniform half _Contrast;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                LIGHTING_COORDS(3,4)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                half4 _Texture_var = tex2Dlod(_Texture,float4(TRANSFORM_TEX(o.uv0, _Texture),0.0,0));
                half4 node_1105 = _Time;
                half node_4466 = pow(_Texture_var.r,exp2((clamp((sin((6.28318530718*(_TimeSpeed*node_1105.g)*_TimeSpeed))*0.3333333+0.3333333),0.3,1)*_Strength)));
                half4 _node_2474 = tex2Dlod(_NoiseTexture,float4(TRANSFORM_TEX(o.uv0, _NoiseTexture),0.0,0));
                half2 node_3570 = (o.uv0+(node_1105.g*float2(_Panner01U,_Panner01V)));
                half4 _node_6588 = tex2Dlod(_NoiseTexture,float4(TRANSFORM_TEX(node_3570, _NoiseTexture),0.0,0));
                v.vertex.xyz += (v.normal*(node_4466*(_node_2474.r*_node_6588.r))*_Offset);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 normalDirection = i.normalDir;
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                float3 lightColor = _LightColor0.rgb;
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
/////// Diffuse:
                float NdotL = max(0.0,dot( normalDirection, lightDirection ));
                float3 directDiffuse = max( 0.0, NdotL) * attenColor;
                half4 _DiffuseTexture_var = tex2D(_DiffuseTexture,TRANSFORM_TEX(i.uv0, _DiffuseTexture));
                float3 diffuseColor = (pow(_DiffuseTexture_var.rgb,exp2(_Contrast))*_DiffuseGlow);
                float3 diffuse = directDiffuse * diffuseColor;
/// Final Color:
                float3 finalColor = diffuse;
                return fixed4(finalColor * 1,0);
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
