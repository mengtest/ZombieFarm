// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:False,qofs:0,qpre:2,rntp:3,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:34401,y:32663,varname:node_3138,prsc:2|custl-7407-OUT,clip-5974-OUT,voffset-6934-OUT;n:type:ShaderForge.SFN_Color,id:7241,x:31933,y:32685,ptovrint:False,ptlb:Color01,ptin:_Color01,varname:_Color01,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.07843138,c2:0.3921569,c3:0.7843137,c4:1;n:type:ShaderForge.SFN_TexCoord,id:7645,x:31381,y:32750,varname:node_7645,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Time,id:1985,x:31381,y:32910,varname:node_1985,prsc:1;n:type:ShaderForge.SFN_Slider,id:5738,x:31224,y:33060,ptovrint:False,ptlb:Panner01 U,ptin:_Panner01U,varname:_Panner01U,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:-0.5,max:5;n:type:ShaderForge.SFN_Slider,id:9030,x:31224,y:33160,ptovrint:False,ptlb:Panner01 V,ptin:_Panner01V,varname:_Panner01V,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:0,max:5;n:type:ShaderForge.SFN_Append,id:3156,x:31557,y:33060,varname:node_3156,prsc:2|A-5738-OUT,B-9030-OUT;n:type:ShaderForge.SFN_Multiply,id:8664,x:31557,y:32920,varname:node_8664,prsc:2|A-1985-T,B-3156-OUT;n:type:ShaderForge.SFN_Add,id:7185,x:31752,y:32920,varname:node_7185,prsc:1|A-7645-UVOUT,B-8664-OUT;n:type:ShaderForge.SFN_Tex2d,id:6779,x:31933,y:32920,ptovrint:False,ptlb:Texture Panner01,ptin:_TexturePanner01,varname:_TexturePanner01,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-7185-OUT;n:type:ShaderForge.SFN_Multiply,id:6924,x:32128,y:32920,varname:node_6924,prsc:1|A-6779-R,B-1821-OUT;n:type:ShaderForge.SFN_Slider,id:1821,x:31775,y:33131,ptovrint:False,ptlb:Offset Strength01,ptin:_OffsetStrength01,varname:_OffsetStrength01,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.1367521,max:1;n:type:ShaderForge.SFN_Slider,id:2057,x:31223,y:33400,ptovrint:False,ptlb:Panner02 U,ptin:_Panner02U,varname:_Panner02U,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:-1,max:5;n:type:ShaderForge.SFN_Slider,id:7819,x:31223,y:33500,ptovrint:False,ptlb:Panner02 V,ptin:_Panner02V,varname:_Panner02V,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:0,max:5;n:type:ShaderForge.SFN_Append,id:9451,x:31556,y:33400,varname:node_9451,prsc:2|A-2057-OUT,B-7819-OUT;n:type:ShaderForge.SFN_Multiply,id:4157,x:31556,y:33260,varname:node_4157,prsc:2|A-1985-T,B-9451-OUT;n:type:ShaderForge.SFN_Add,id:2276,x:31751,y:33260,varname:node_2276,prsc:1|A-7645-UVOUT,B-4157-OUT;n:type:ShaderForge.SFN_Tex2d,id:7179,x:31932,y:33260,ptovrint:False,ptlb:Texture Panner02,ptin:_TexturePanner02,varname:_TexturePanner02,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-2276-OUT;n:type:ShaderForge.SFN_Multiply,id:4915,x:32127,y:33260,varname:node_4915,prsc:1|A-7179-R,B-349-OUT;n:type:ShaderForge.SFN_Slider,id:349,x:31775,y:33448,ptovrint:False,ptlb:Offset Strength02,ptin:_OffsetStrength02,varname:_OffsetStrength02,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.5043235,max:1;n:type:ShaderForge.SFN_Add,id:6015,x:32355,y:33106,varname:node_6015,prsc:1|A-6924-OUT,B-4915-OUT;n:type:ShaderForge.SFN_Multiply,id:6934,x:32781,y:33106,varname:node_6934,prsc:2|A-2823-OUT,B-8486-OUT;n:type:ShaderForge.SFN_NormalVector,id:8486,x:32359,y:33482,prsc:2,pt:False;n:type:ShaderForge.SFN_Tex2d,id:5090,x:32359,y:33310,ptovrint:False,ptlb:Texture Offset,ptin:_TextureOffset,varname:_TextureOffset,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:2823,x:32578,y:33106,varname:node_2823,prsc:2|A-6015-OUT,B-5090-R;n:type:ShaderForge.SFN_Step,id:8947,x:32621,y:32823,varname:node_8947,prsc:1|A-6924-OUT,B-4915-OUT;n:type:ShaderForge.SFN_Tex2d,id:1479,x:33138,y:32986,ptovrint:False,ptlb:Texture Mask,ptin:_TextureMask,varname:_TextureMask,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:5974,x:33549,y:32838,varname:node_5974,prsc:1|A-6015-OUT,B-1479-R,C-288-OUT;n:type:ShaderForge.SFN_ValueProperty,id:288,x:33367,y:33057,ptovrint:False,ptlb:Opacity,ptin:_Opacity,varname:_Opacity,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:2;n:type:ShaderForge.SFN_Multiply,id:5667,x:32128,y:32752,varname:node_5667,prsc:2|A-7241-RGB,B-6779-R;n:type:ShaderForge.SFN_Add,id:6043,x:33262,y:32674,varname:node_6043,prsc:2|A-5667-OUT,B-8947-OUT;n:type:ShaderForge.SFN_Multiply,id:7407,x:33582,y:32583,varname:node_7407,prsc:1|A-2664-OUT,B-6043-OUT,C-9547-RGB;n:type:ShaderForge.SFN_Slider,id:2664,x:33094,y:32449,ptovrint:False,ptlb:Glow,ptin:_Glow,varname:_Glow,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1.029034,max:5;n:type:ShaderForge.SFN_Color,id:9547,x:33582,y:32381,ptovrint:False,ptlb:Color02,ptin:_Color02,varname:_Color02,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.6617647,c2:0,c3:0,c4:1;proporder:7241-6779-5738-9030-1821-7179-2057-7819-349-5090-1479-2664-288-9547;pass:END;sub:END;*/

Shader "FX Kimi/Liquid/Liquid Distortion Bleeding Ground" {
    Properties {
        _Color01 ("Color01", Color) = (0.07843138,0.3921569,0.7843137,1)
        _TexturePanner01 ("Texture Panner01", 2D) = "white" {}
        _Panner01U ("Panner01 U", Range(-5, 5)) = -0.5
        _Panner01V ("Panner01 V", Range(-5, 5)) = 0
        _OffsetStrength01 ("Offset Strength01", Range(0, 1)) = 0.1367521
        _TexturePanner02 ("Texture Panner02", 2D) = "white" {}
        _Panner02U ("Panner02 U", Range(-5, 5)) = -1
        _Panner02V ("Panner02 V", Range(-5, 5)) = 0
        _OffsetStrength02 ("Offset Strength02", Range(0, 1)) = 0.5043235
        _TextureOffset ("Texture Offset", 2D) = "white" {}
        _TextureMask ("Texture Mask", 2D) = "white" {}
        _Glow ("Glow", Range(0, 5)) = 1.029034
        _Opacity ("Opacity", Float ) = 2
        _Color02 ("Color02", Color) = (0.6617647,0,0,1)
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
            Cull Off
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform half4 _Color01;
            uniform half _Panner01U;
            uniform half _Panner01V;
            uniform sampler2D _TexturePanner01; uniform float4 _TexturePanner01_ST;
            uniform half _OffsetStrength01;
            uniform half _Panner02U;
            uniform half _Panner02V;
            uniform sampler2D _TexturePanner02; uniform float4 _TexturePanner02_ST;
            uniform half _OffsetStrength02;
            uniform sampler2D _TextureOffset; uniform float4 _TextureOffset_ST;
            uniform sampler2D _TextureMask; uniform float4 _TextureMask_ST;
            uniform half _Opacity;
            uniform half _Glow;
            uniform half4 _Color02;
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
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                half4 node_1985 = _Time;
                half2 node_7185 = (o.uv0+(node_1985.g*float2(_Panner01U,_Panner01V)));
                half4 _TexturePanner01_var = tex2Dlod(_TexturePanner01,float4(TRANSFORM_TEX(node_7185, _TexturePanner01),0.0,0));
                half node_6924 = (_TexturePanner01_var.r*_OffsetStrength01);
                half2 node_2276 = (o.uv0+(node_1985.g*float2(_Panner02U,_Panner02V)));
                half4 _TexturePanner02_var = tex2Dlod(_TexturePanner02,float4(TRANSFORM_TEX(node_2276, _TexturePanner02),0.0,0));
                half node_4915 = (_TexturePanner02_var.r*_OffsetStrength02);
                half node_6015 = (node_6924+node_4915);
                half4 _TextureOffset_var = tex2Dlod(_TextureOffset,float4(TRANSFORM_TEX(o.uv0, _TextureOffset),0.0,0));
                v.vertex.xyz += ((node_6015*_TextureOffset_var.r)*v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                half4 node_1985 = _Time;
                half2 node_7185 = (i.uv0+(node_1985.g*float2(_Panner01U,_Panner01V)));
                half4 _TexturePanner01_var = tex2D(_TexturePanner01,TRANSFORM_TEX(node_7185, _TexturePanner01));
                half node_6924 = (_TexturePanner01_var.r*_OffsetStrength01);
                half2 node_2276 = (i.uv0+(node_1985.g*float2(_Panner02U,_Panner02V)));
                half4 _TexturePanner02_var = tex2D(_TexturePanner02,TRANSFORM_TEX(node_2276, _TexturePanner02));
                half node_4915 = (_TexturePanner02_var.r*_OffsetStrength02);
                half node_6015 = (node_6924+node_4915);
                half4 _TextureMask_var = tex2D(_TextureMask,TRANSFORM_TEX(i.uv0, _TextureMask));
                clip((node_6015*_TextureMask_var.r*_Opacity) - 0.5);
////// Lighting:
                float3 finalColor = (_Glow*((_Color01.rgb*_TexturePanner01_var.r)+step(node_6924,node_4915))*_Color02.rgb);
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
