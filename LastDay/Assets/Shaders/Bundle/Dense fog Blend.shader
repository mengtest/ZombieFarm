// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:True,hqlp:False,rprd:True,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:6,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:False,igpj:True,qofs:1,qpre:4,rntp:5,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0,fgcg:0.01568628,fgcb:0.06666667,fgca:1,fgde:0.01,fgrn:0,fgrf:110,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True,fsmp:False;n:type:ShaderForge.SFN_Final,id:2865,x:34400,y:33090,varname:node_2865,prsc:2|emission-8608-OUT,alpha-1060-OUT;n:type:ShaderForge.SFN_TexCoord,id:6671,x:31480,y:33199,varname:node_6671,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Tex2d,id:4596,x:31885,y:33101,varname:_Texture,prsc:1,tex:75324f008b2082845895ef633799d57f,ntxv:0,isnm:False|UVIN-5731-OUT,TEX-1586-TEX;n:type:ShaderForge.SFN_RemapRange,id:7358,x:32877,y:33062,varname:node_7358,prsc:1,frmn:0,frmx:1,tomn:-15,tomx:15|IN-291-OUT;n:type:ShaderForge.SFN_Tex2dAsset,id:1586,x:31700,y:33241,ptovrint:False,ptlb:Texture01,ptin:_Texture01,varname:_Texture01,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:75324f008b2082845895ef633799d57f,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:7009,x:31885,y:33319,varname:_node_7009,prsc:1,tex:75324f008b2082845895ef633799d57f,ntxv:0,isnm:False|UVIN-3901-OUT,TEX-1586-TEX;n:type:ShaderForge.SFN_Time,id:7126,x:31280,y:33176,varname:node_7126,prsc:1;n:type:ShaderForge.SFN_Slider,id:5427,x:30941,y:33143,ptovrint:False,ptlb:V Panner,ptin:_VPanner,varname:_VPanner,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:0.1,max:5;n:type:ShaderForge.SFN_Slider,id:9278,x:30941,y:33011,ptovrint:False,ptlb:U Panner,ptin:_UPanner,varname:_UPanner,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:0.05,max:5;n:type:ShaderForge.SFN_Append,id:31,x:31280,y:33011,varname:node_31,prsc:2|A-9278-OUT,B-5427-OUT;n:type:ShaderForge.SFN_Multiply,id:3459,x:31480,y:33011,varname:node_3459,prsc:2|A-31-OUT,B-7126-T;n:type:ShaderForge.SFN_Add,id:5731,x:31700,y:33011,varname:node_5731,prsc:1|A-3459-OUT,B-6671-UVOUT;n:type:ShaderForge.SFN_Slider,id:9401,x:30941,y:33583,ptovrint:False,ptlb:V Panner2,ptin:_VPanner2,varname:_VPanner2,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:-0.05,max:5;n:type:ShaderForge.SFN_Slider,id:4229,x:30941,y:33450,ptovrint:False,ptlb:U Panner2,ptin:_UPanner2,varname:_UPanner2,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:-0.05,max:5;n:type:ShaderForge.SFN_Append,id:2148,x:31280,y:33450,varname:node_2148,prsc:2|A-4229-OUT,B-9401-OUT;n:type:ShaderForge.SFN_Multiply,id:5681,x:31480,y:33450,varname:node_5681,prsc:2|A-2148-OUT,B-7126-T;n:type:ShaderForge.SFN_Add,id:3901,x:31700,y:33450,varname:node_3901,prsc:1|A-5681-OUT,B-6671-UVOUT;n:type:ShaderForge.SFN_Slider,id:3574,x:31169,y:32821,ptovrint:False,ptlb:Dense fog size,ptin:_Densefogsize,varname:_Densefogsize,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.1679724,max:1;n:type:ShaderForge.SFN_OneMinus,id:6473,x:31503,y:32821,varname:node_6473,prsc:2|IN-3574-OUT;n:type:ShaderForge.SFN_RemapRange,id:457,x:31684,y:32803,varname:node_457,prsc:1,frmn:0,frmx:1,tomn:-0.45,tomx:0.45|IN-6473-OUT;n:type:ShaderForge.SFN_Add,id:4979,x:32149,y:32997,varname:node_4979,prsc:2|A-457-OUT,B-4596-R;n:type:ShaderForge.SFN_Add,id:5263,x:32149,y:33206,varname:node_5263,prsc:2|A-457-OUT,B-7009-R;n:type:ShaderForge.SFN_Multiply,id:291,x:32354,y:33094,varname:node_291,prsc:1|A-4979-OUT,B-5263-OUT;n:type:ShaderForge.SFN_Clamp01,id:9437,x:33195,y:33192,varname:node_9437,prsc:2|IN-5421-OUT;n:type:ShaderForge.SFN_Color,id:7803,x:33195,y:32992,ptovrint:False,ptlb:Color,ptin:_Color,varname:_Color,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.4883366,c2:0,c3:0.6617647,c4:1;n:type:ShaderForge.SFN_Add,id:3493,x:33519,y:33131,varname:node_3493,prsc:1|A-7803-RGB,B-9437-OUT;n:type:ShaderForge.SFN_Color,id:5042,x:32354,y:32858,ptovrint:False,ptlb:Color2,ptin:_Color2,varname:_Color2,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.03194726,c2:0,c3:0.1323529,c4:1;n:type:ShaderForge.SFN_Multiply,id:7575,x:32625,y:32905,varname:node_7575,prsc:2|A-5042-RGB,B-291-OUT;n:type:ShaderForge.SFN_Multiply,id:5421,x:33009,y:32855,varname:node_5421,prsc:2|A-7358-OUT,B-7575-OUT;n:type:ShaderForge.SFN_Clamp01,id:246,x:33769,y:33350,varname:node_246,prsc:2|IN-7358-OUT;n:type:ShaderForge.SFN_Multiply,id:8608,x:33795,y:33022,varname:node_8608,prsc:2|A-6016-OUT,B-3493-OUT;n:type:ShaderForge.SFN_ValueProperty,id:6016,x:33536,y:33014,ptovrint:False,ptlb:Alpha,ptin:_Alpha,varname:_Alpha,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.5;n:type:ShaderForge.SFN_Multiply,id:1060,x:34160,y:33319,varname:node_1060,prsc:2|A-246-OUT,B-4414-R,C-8194-OUT,D-7803-A,E-5042-A;n:type:ShaderForge.SFN_Tex2d,id:4414,x:33769,y:33538,ptovrint:False,ptlb:Mask Texture,ptin:_MaskTexture,varname:_MaskTexture,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:c3be11de4aa1301409dc5b1ea3228b81,ntxv:0,isnm:False;n:type:ShaderForge.SFN_ValueProperty,id:8194,x:33769,y:33212,ptovrint:False,ptlb:Opacity,ptin:_Opacity,varname:_Opacity,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.5;proporder:1586-4414-5427-9278-9401-4229-3574-7803-5042-6016-8194;pass:END;sub:END;*/

Shader "FX Kimi/Fog/Dense fog Blend" {
    Properties {
        _Texture01 ("Texture01", 2D) = "white" {}
        _MaskTexture ("Mask Texture", 2D) = "white" {}
        _VPanner ("V Panner", Range(-5, 5)) = 0.1
        _UPanner ("U Panner", Range(-5, 5)) = 0.05
        _VPanner2 ("V Panner2", Range(-5, 5)) = -0.05
        _UPanner2 ("U Panner2", Range(-5, 5)) = -0.05
        _Densefogsize ("Dense fog size", Range(0, 1)) = 0.1679724
        _Color ("Color", Color) = (0.4883366,0,0.6617647,1)
        _Color2 ("Color2", Color) = (0.03194726,0,0.1323529,1)
        _Alpha ("Alpha", Float ) = 0.5
        _Opacity ("Opacity", Float ) = 0.5
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Overlay+1"
            "RenderType"="Overlay"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZTest Always
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #define _GLOSSYENV 1
            #include "UnityCG.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform sampler2D _Texture01; uniform float4 _Texture01_ST;
            uniform half _VPanner;
            uniform half _UPanner;
            uniform half _VPanner2;
            uniform half _UPanner2;
            uniform half _Densefogsize;
            uniform half4 _Color;
            uniform half4 _Color2;
            uniform half _Alpha;
            uniform sampler2D _MaskTexture; uniform float4 _MaskTexture_ST;
            uniform float _Opacity;
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
                half node_457 = ((1.0 - _Densefogsize)*0.9+-0.45);
                half4 node_7126 = _Time;
                half2 node_5731 = ((float2(_UPanner,_VPanner)*node_7126.g)+i.uv0);
                half4 _Texture = tex2D(_Texture01,TRANSFORM_TEX(node_5731, _Texture01));
                half2 node_3901 = ((float2(_UPanner2,_VPanner2)*node_7126.g)+i.uv0);
                half4 _node_7009 = tex2D(_Texture01,TRANSFORM_TEX(node_3901, _Texture01));
                half node_291 = ((node_457+_Texture.r)*(node_457+_node_7009.r));
                half node_7358 = (node_291*30.0+-15.0);
                float3 emissive = (_Alpha*(_Color.rgb+saturate((node_7358*(_Color2.rgb*node_291)))));
                float3 finalColor = emissive;
                float4 _MaskTexture_var = tex2D(_MaskTexture,TRANSFORM_TEX(i.uv0, _MaskTexture));
                return fixed4(finalColor,(saturate(node_7358)*_MaskTexture_var.r*_Opacity*_Color.a*_Color2.a));
            }
            ENDCG
        }
        Pass {
            Name "Meta"
            Tags {
                "LightMode"="Meta"
            }
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_META 1
            #define _GLOSSYENV 1
            #include "UnityCG.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #include "UnityMetaPass.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform sampler2D _Texture01; uniform float4 _Texture01_ST;
            uniform half _VPanner;
            uniform half _UPanner;
            uniform half _VPanner2;
            uniform half _UPanner2;
            uniform half _Densefogsize;
            uniform half4 _Color;
            uniform half4 _Color2;
            uniform half _Alpha;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
                float2 texcoord2 : TEXCOORD2;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityMetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST, unity_DynamicLightmapST );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : SV_Target {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                UnityMetaInput o;
                UNITY_INITIALIZE_OUTPUT( UnityMetaInput, o );
                
                half node_457 = ((1.0 - _Densefogsize)*0.9+-0.45);
                half4 node_7126 = _Time;
                half2 node_5731 = ((float2(_UPanner,_VPanner)*node_7126.g)+i.uv0);
                half4 _Texture = tex2D(_Texture01,TRANSFORM_TEX(node_5731, _Texture01));
                half2 node_3901 = ((float2(_UPanner2,_VPanner2)*node_7126.g)+i.uv0);
                half4 _node_7009 = tex2D(_Texture01,TRANSFORM_TEX(node_3901, _Texture01));
                half node_291 = ((node_457+_Texture.r)*(node_457+_node_7009.r));
                half node_7358 = (node_291*30.0+-15.0);
                o.Emission = (_Alpha*(_Color.rgb+saturate((node_7358*(_Color2.rgb*node_291)))));
                
                float3 diffColor = float3(0,0,0);
                o.Albedo = diffColor;
                
                return UnityMetaFragment( o );
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
