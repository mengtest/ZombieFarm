// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:34561,y:33007,varname:node_3138,prsc:2|emission-8649-OUT,alpha-729-OUT;n:type:ShaderForge.SFN_Vector2,id:578,x:32742,y:32850,varname:node_578,prsc:1,v1:1,v2:1;n:type:ShaderForge.SFN_TexCoord,id:6084,x:32742,y:32946,varname:node_6084,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Time,id:6889,x:32742,y:33105,varname:node_6889,prsc:1;n:type:ShaderForge.SFN_Slider,id:1830,x:32637,y:33265,ptovrint:False,ptlb:Panner01 U,ptin:_Panner01U,varname:_Panner01U,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:0,max:5;n:type:ShaderForge.SFN_Slider,id:9529,x:32637,y:33363,ptovrint:False,ptlb:Panner01 V,ptin:_Panner01V,varname:_Panner01V,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:-0.8290596,max:5;n:type:ShaderForge.SFN_Append,id:5384,x:32971,y:33265,varname:node_5384,prsc:2|A-1830-OUT,B-9529-OUT;n:type:ShaderForge.SFN_Multiply,id:263,x:32971,y:33124,varname:node_263,prsc:2|A-6889-T,B-5384-OUT;n:type:ShaderForge.SFN_Add,id:9451,x:32971,y:32946,varname:node_9451,prsc:1|A-1947-OUT,B-263-OUT;n:type:ShaderForge.SFN_Tex2d,id:138,x:33182,y:32946,ptovrint:False,ptlb:Texture01,ptin:_Texture01,varname:_Texture01,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:3ca55052a809f5f49907d814e53043d5,ntxv:0,isnm:False|UVIN-9451-OUT;n:type:ShaderForge.SFN_Tex2dAsset,id:4521,x:33182,y:33147,ptovrint:False,ptlb:Texture Mask,ptin:_TextureMask,varname:_TextureMask,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:d0f3c8f78bdf6c94ebf84bea924ad8fd,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:8266,x:33350,y:33147,varname:node_8266,prsc:1,tex:d0f3c8f78bdf6c94ebf84bea924ad8fd,ntxv:0,isnm:False|TEX-4521-TEX;n:type:ShaderForge.SFN_Subtract,id:9105,x:33535,y:33147,varname:node_9105,prsc:2|A-8266-R,B-5346-OUT;n:type:ShaderForge.SFN_Slider,id:5346,x:33206,y:33342,ptovrint:False,ptlb:Subtract,ptin:_Subtract,varname:_Subtract,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-1,cur:0.8519757,max:2;n:type:ShaderForge.SFN_Add,id:1914,x:33676,y:33019,varname:node_1914,prsc:2|A-4351-OUT,B-9105-OUT;n:type:ShaderForge.SFN_Multiply,id:7402,x:33895,y:33097,varname:node_7402,prsc:2|A-1914-OUT,B-8124-R;n:type:ShaderForge.SFN_Tex2d,id:8124,x:33694,y:33273,varname:node_8124,prsc:1,tex:d0f3c8f78bdf6c94ebf84bea924ad8fd,ntxv:0,isnm:False|TEX-4521-TEX;n:type:ShaderForge.SFN_Tex2d,id:9514,x:33182,y:32733,ptovrint:False,ptlb:Texture02,ptin:_Texture02,varname:_Texture02,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:d941fb94169618741b7305aa71d0d733,ntxv:0,isnm:False|UVIN-2032-OUT;n:type:ShaderForge.SFN_Multiply,id:1947,x:32971,y:32815,varname:node_1947,prsc:2|A-578-OUT,B-6084-UVOUT;n:type:ShaderForge.SFN_Slider,id:2611,x:32634,y:32662,ptovrint:False,ptlb:Panner02 U,ptin:_Panner02U,varname:_Panner02U,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:0,max:5;n:type:ShaderForge.SFN_Slider,id:4731,x:32634,y:32760,ptovrint:False,ptlb:Panner02 V,ptin:_Panner02V,varname:_Panner02V,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:-0.4017092,max:5;n:type:ShaderForge.SFN_Append,id:6830,x:32968,y:32662,varname:node_6830,prsc:2|A-2611-OUT,B-4731-OUT;n:type:ShaderForge.SFN_Multiply,id:1322,x:32968,y:32521,varname:node_1322,prsc:2|A-6889-T,B-6830-OUT;n:type:ShaderForge.SFN_Add,id:2032,x:32968,y:32389,varname:node_2032,prsc:1|A-4120-OUT,B-1322-OUT;n:type:ShaderForge.SFN_Multiply,id:4351,x:33443,y:32863,varname:node_4351,prsc:2|A-9514-R,B-138-R;n:type:ShaderForge.SFN_Vector2,id:8416,x:32744,y:32505,varname:node_8416,prsc:1,v1:1,v2:0.5;n:type:ShaderForge.SFN_Multiply,id:4120,x:32968,y:32266,varname:node_4120,prsc:2|A-8416-OUT,B-6084-UVOUT;n:type:ShaderForge.SFN_Smoothstep,id:6179,x:34043,y:33271,varname:node_6179,prsc:2|A-5407-OUT,B-1685-OUT,V-7402-OUT;n:type:ShaderForge.SFN_Vector1,id:5407,x:33848,y:33271,varname:node_5407,prsc:2,v1:0.2;n:type:ShaderForge.SFN_Slider,id:1685,x:33886,y:33415,ptovrint:False,ptlb:Smoothstep,ptin:_Smoothstep,varname:_Smoothstep,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.6069889,max:1;n:type:ShaderForge.SFN_Color,id:5333,x:34112,y:33108,ptovrint:False,ptlb:Color,ptin:_Color,varname:_Color,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Multiply,id:8649,x:34369,y:33107,varname:node_8649,prsc:2|A-5333-RGB,B-30-RGB;n:type:ShaderForge.SFN_VertexColor,id:30,x:34112,y:32947,varname:node_30,prsc:2;n:type:ShaderForge.SFN_Multiply,id:729,x:34369,y:33267,varname:node_729,prsc:2|A-30-A,B-5333-A,C-6179-OUT;proporder:5333-138-1830-9529-9514-2611-4731-4521-5346-1685;pass:END;sub:END;*/

Shader "FX Kimi/Trail/Trail Blend" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _Texture01 ("Texture01", 2D) = "white" {}
        _Panner01U ("Panner01 U", Range(-5, 5)) = 0
        _Panner01V ("Panner01 V", Range(-5, 5)) = -0.8290596
        _Texture02 ("Texture02", 2D) = "white" {}
        _Panner02U ("Panner02 U", Range(-5, 5)) = 0
        _Panner02V ("Panner02 V", Range(-5, 5)) = -0.4017092
        _TextureMask ("Texture Mask", 2D) = "white" {}
        _Subtract ("Subtract", Range(-1, 2)) = 0.8519757
        _Smoothstep ("Smoothstep", Range(0, 1)) = 0.6069889
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
            uniform half _Panner01U;
            uniform half _Panner01V;
            uniform sampler2D _Texture01; uniform float4 _Texture01_ST;
            uniform sampler2D _TextureMask; uniform float4 _TextureMask_ST;
            uniform half _Subtract;
            uniform sampler2D _Texture02; uniform float4 _Texture02_ST;
            uniform half _Panner02U;
            uniform half _Panner02V;
            uniform half _Smoothstep;
            uniform half4 _Color;
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
                float3 emissive = (_Color.rgb*i.vertexColor.rgb);
                float3 finalColor = emissive;
                half4 node_6889 = _Time;
                half2 node_2032 = ((half2(1,0.5)*i.uv0)+(node_6889.g*float2(_Panner02U,_Panner02V)));
                half4 _Texture02_var = tex2D(_Texture02,TRANSFORM_TEX(node_2032, _Texture02));
                half2 node_9451 = ((half2(1,1)*i.uv0)+(node_6889.g*float2(_Panner01U,_Panner01V)));
                half4 _Texture01_var = tex2D(_Texture01,TRANSFORM_TEX(node_9451, _Texture01));
                half4 node_8266 = tex2D(_TextureMask,TRANSFORM_TEX(i.uv0, _TextureMask));
                half4 node_8124 = tex2D(_TextureMask,TRANSFORM_TEX(i.uv0, _TextureMask));
                return fixed4(finalColor,(i.vertexColor.a*_Color.a*smoothstep( 0.2, _Smoothstep, (((_Texture02_var.r*_Texture01_var.r)+(node_8266.r-_Subtract))*node_8124.r) )));
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
