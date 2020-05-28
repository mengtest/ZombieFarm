// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:33479,y:32665,varname:node_3138,prsc:2|emission-9438-OUT,alpha-9438-OUT;n:type:ShaderForge.SFN_Color,id:7241,x:32851,y:32706,ptovrint:False,ptlb:Color,ptin:_Color,varname:_Color,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.07843138,c2:0.3921569,c3:0.7843137,c4:1;n:type:ShaderForge.SFN_Tex2d,id:7573,x:32208,y:32848,ptovrint:False,ptlb:Texture,ptin:_Texture,varname:_Texture,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:06dc695b2df649942ad4ad96b75c352d,ntxv:0,isnm:False|UVIN-5925-OUT;n:type:ShaderForge.SFN_Subtract,id:1774,x:32416,y:33039,varname:node_1774,prsc:1|A-4600-R,B-4063-OUT;n:type:ShaderForge.SFN_Slider,id:4063,x:32048,y:33361,ptovrint:False,ptlb:Subtract,ptin:_Subtract,varname:_Subtract,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.8290598,max:2;n:type:ShaderForge.SFN_Add,id:7451,x:32507,y:32872,varname:node_7451,prsc:2|A-7573-R,B-1774-OUT;n:type:ShaderForge.SFN_Tex2dAsset,id:2938,x:32021,y:33039,ptovrint:False,ptlb:Texture Mask,ptin:_TextureMask,varname:_TextureMask,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:17de7def0af0c404598f54bc27349be1,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:580,x:32627,y:33039,varname:node_580,prsc:1,tex:17de7def0af0c404598f54bc27349be1,ntxv:0,isnm:False|TEX-2938-TEX;n:type:ShaderForge.SFN_Multiply,id:5680,x:32851,y:32895,varname:node_5680,prsc:1|A-7451-OUT,B-580-R;n:type:ShaderForge.SFN_Time,id:9250,x:31520,y:32876,varname:node_9250,prsc:1;n:type:ShaderForge.SFN_Slider,id:570,x:31464,y:33099,ptovrint:False,ptlb:Panner U,ptin:_PannerU,varname:_PannerU,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:0,max:5;n:type:ShaderForge.SFN_Slider,id:2172,x:31464,y:33236,ptovrint:False,ptlb:Panner V,ptin:_PannerV,varname:_PannerV,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:0.5,max:5;n:type:ShaderForge.SFN_Append,id:2761,x:31797,y:33099,varname:node_2761,prsc:2|A-570-OUT,B-2172-OUT;n:type:ShaderForge.SFN_Multiply,id:1162,x:31797,y:32897,varname:node_1162,prsc:2|A-9250-T,B-2761-OUT;n:type:ShaderForge.SFN_TexCoord,id:2153,x:31797,y:32745,varname:node_2153,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Vector2,id:6520,x:31797,y:32643,varname:node_6520,prsc:1,v1:2,v2:1;n:type:ShaderForge.SFN_Multiply,id:3847,x:31980,y:32643,varname:node_3847,prsc:2|A-6520-OUT,B-2153-UVOUT;n:type:ShaderForge.SFN_Add,id:5925,x:32021,y:32848,varname:node_5925,prsc:1|A-3847-OUT,B-1162-OUT;n:type:ShaderForge.SFN_Tex2d,id:4600,x:32205,y:33110,varname:node_4600,prsc:1,tex:17de7def0af0c404598f54bc27349be1,ntxv:0,isnm:False|TEX-2938-TEX;n:type:ShaderForge.SFN_Smoothstep,id:9438,x:33185,y:32974,varname:node_9438,prsc:1|A-5317-OUT,B-2195-OUT,V-5680-OUT;n:type:ShaderForge.SFN_Vector1,id:5317,x:32906,y:33127,varname:node_5317,prsc:2,v1:0;n:type:ShaderForge.SFN_Slider,id:2195,x:32798,y:33279,ptovrint:False,ptlb:Smoothstep,ptin:_Smoothstep,varname:_Smoothstep,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.3333333,max:1;proporder:7241-7573-4063-2938-570-2172-2195;pass:END;sub:END;*/

Shader "Shader Forge/Twist Distortion Blend" {
    Properties {
        _Color ("Color", Color) = (0.07843138,0.3921569,0.7843137,1)
        _Texture ("Texture", 2D) = "white" {}
        _Subtract ("Subtract", Range(0, 2)) = 0.8290598
        _TextureMask ("Texture Mask", 2D) = "white" {}
        _PannerU ("Panner U", Range(-5, 5)) = 0
        _PannerV ("Panner V", Range(-5, 5)) = 0.5
        _Smoothstep ("Smoothstep", Range(0, 1)) = 0.3333333
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
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform sampler2D _Texture; uniform float4 _Texture_ST;
            uniform half _Subtract;
            uniform sampler2D _TextureMask; uniform float4 _TextureMask_ST;
            uniform half _PannerU;
            uniform half _PannerV;
            uniform half _Smoothstep;
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
            float4 frag(VertexOutput i) : COLOR {
////// Lighting:
////// Emissive:
                half4 node_9250 = _Time;
                half2 node_5925 = ((half2(2,1)*i.uv0)+(node_9250.g*float2(_PannerU,_PannerV)));
                half4 _Texture_var = tex2D(_Texture,TRANSFORM_TEX(node_5925, _Texture));
                half4 node_4600 = tex2D(_TextureMask,TRANSFORM_TEX(i.uv0, _TextureMask));
                half4 node_580 = tex2D(_TextureMask,TRANSFORM_TEX(i.uv0, _TextureMask));
                half node_9438 = smoothstep( 0.0, _Smoothstep, ((_Texture_var.r+(node_4600.r-_Subtract))*node_580.r) );
                float3 emissive = float3(node_9438,node_9438,node_9438);
                float3 finalColor = emissive;
                return fixed4(finalColor,node_9438);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
