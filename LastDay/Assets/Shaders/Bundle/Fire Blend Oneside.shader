// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:False,qofs:0,qpre:2,rntp:3,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:34850,y:32628,varname:node_3138,prsc:2|custl-4218-OUT,clip-5339-OUT;n:type:ShaderForge.SFN_Color,id:7241,x:33464,y:32628,ptovrint:False,ptlb:Color Abroad,ptin:_ColorAbroad,varname:_ColorAbroad,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:0.8739352,c3:0.1691176,c4:1;n:type:ShaderForge.SFN_TexCoord,id:9451,x:31950,y:32848,varname:node_9451,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Time,id:1261,x:31950,y:33005,varname:node_1261,prsc:1;n:type:ShaderForge.SFN_Slider,id:645,x:31860,y:33229,ptovrint:False,ptlb:Panner01 U,ptin:_Panner01U,varname:_Panner01U,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:-0.2,max:5;n:type:ShaderForge.SFN_Slider,id:10,x:31860,y:33372,ptovrint:False,ptlb:Panner01 V,ptin:_Panner01V,varname:_Panner01V,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:-0.3418804,max:5;n:type:ShaderForge.SFN_Append,id:8781,x:32189,y:33229,varname:node_8781,prsc:2|A-645-OUT,B-10-OUT;n:type:ShaderForge.SFN_Multiply,id:1478,x:32189,y:33025,varname:node_1478,prsc:2|A-1261-T,B-8781-OUT;n:type:ShaderForge.SFN_Add,id:4585,x:32401,y:33019,varname:node_4585,prsc:1|A-9451-UVOUT,B-1478-OUT;n:type:ShaderForge.SFN_Tex2d,id:7061,x:32581,y:33019,varname:_node_7061,prsc:1,tex:d941fb94169618741b7305aa71d0d733,ntxv:0,isnm:False|UVIN-4585-OUT,TEX-5750-TEX;n:type:ShaderForge.SFN_Tex2d,id:4360,x:32581,y:33268,varname:_node_4360,prsc:1,tex:d941fb94169618741b7305aa71d0d733,ntxv:0,isnm:False|UVIN-5809-OUT,TEX-5750-TEX;n:type:ShaderForge.SFN_Vector2,id:8243,x:31938,y:33541,varname:node_8243,prsc:1,v1:2,v2:1;n:type:ShaderForge.SFN_Slider,id:6899,x:31850,y:33680,ptovrint:False,ptlb:Panner02 U,ptin:_Panner02U,varname:_Panner02U,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:0,max:5;n:type:ShaderForge.SFN_Slider,id:6369,x:31850,y:33823,ptovrint:False,ptlb:Panner02 V,ptin:_Panner02V,varname:_Panner02V,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:-0.5649143,max:5;n:type:ShaderForge.SFN_Append,id:8477,x:32183,y:33680,varname:node_8477,prsc:2|A-6899-OUT,B-6369-OUT;n:type:ShaderForge.SFN_Multiply,id:5957,x:32183,y:33505,varname:node_5957,prsc:2|A-1261-T,B-8477-OUT;n:type:ShaderForge.SFN_Add,id:9095,x:32395,y:33505,varname:node_9095,prsc:2|A-9451-UVOUT,B-5957-OUT;n:type:ShaderForge.SFN_Multiply,id:5809,x:32544,y:33645,varname:node_5809,prsc:1|A-9095-OUT,B-8243-OUT;n:type:ShaderForge.SFN_Add,id:777,x:32771,y:33019,varname:node_777,prsc:2|A-7061-R,B-4360-R;n:type:ShaderForge.SFN_Tex2d,id:4509,x:32860,y:33224,ptovrint:False,ptlb:Texture Mask01,ptin:_TextureMask01,varname:_TextureMask01,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:0a684a7a9e504944984b0bdf37da971e,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:4097,x:32988,y:33019,varname:node_4097,prsc:2|A-777-OUT,B-4509-R,C-2142-OUT;n:type:ShaderForge.SFN_Tex2d,id:5495,x:32798,y:33628,ptovrint:False,ptlb:Texture Mask02,ptin:_TextureMask02,varname:_TextureMask02,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:dbcf7de4ab10d9a47a8080635d2d60fc,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:9644,x:33317,y:33108,varname:node_9644,prsc:1|A-8627-OUT,B-4223-OUT;n:type:ShaderForge.SFN_Slider,id:2996,x:33086,y:33681,ptovrint:False,ptlb:Strength,ptin:_Strength,varname:_Strength,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.1025641,max:1;n:type:ShaderForge.SFN_Vector1,id:2142,x:32751,y:33147,varname:node_2142,prsc:2,v1:5;n:type:ShaderForge.SFN_Step,id:6104,x:33698,y:32852,varname:node_6104,prsc:1|A-4104-OUT,B-9644-OUT;n:type:ShaderForge.SFN_Vector1,id:9343,x:33395,y:33036,varname:node_9343,prsc:1,v1:0.5;n:type:ShaderForge.SFN_Multiply,id:8578,x:33890,y:32719,varname:node_8578,prsc:2|A-7241-RGB,B-6104-OUT;n:type:ShaderForge.SFN_Subtract,id:9637,x:33654,y:33114,varname:node_9637,prsc:2|A-9343-OUT,B-3048-OUT;n:type:ShaderForge.SFN_Step,id:4148,x:33865,y:33053,varname:node_4148,prsc:1|A-9637-OUT,B-9644-OUT;n:type:ShaderForge.SFN_Subtract,id:6016,x:34112,y:32938,varname:node_6016,prsc:2|A-4148-OUT,B-6104-OUT;n:type:ShaderForge.SFN_Add,id:4266,x:34304,y:32758,varname:node_4266,prsc:1|A-8578-OUT,B-2014-OUT;n:type:ShaderForge.SFN_Color,id:8711,x:34076,y:33143,ptovrint:False,ptlb:Color Within,ptin:_ColorWithin,varname:_ColorWithin,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.9926471,c2:0.5014579,c3:0.1240809,c4:1;n:type:ShaderForge.SFN_Multiply,id:2014,x:34309,y:33129,varname:node_2014,prsc:2|A-6016-OUT,B-8711-RGB;n:type:ShaderForge.SFN_Tex2dAsset,id:5750,x:32401,y:33229,ptovrint:False,ptlb:Texture,ptin:_Texture,varname:_Texture,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:d941fb94169618741b7305aa71d0d733,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:4223,x:33112,y:33254,varname:node_4223,prsc:1|A-4097-OUT,B-7493-OUT;n:type:ShaderForge.SFN_Subtract,id:7493,x:32969,y:33434,varname:node_7493,prsc:2|A-5495-R,B-2996-OUT;n:type:ShaderForge.SFN_Slider,id:3048,x:33551,y:33325,ptovrint:False,ptlb:Abroad,ptin:_Abroad,varname:_Abroad,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Slider,id:4104,x:33238,y:32913,ptovrint:False,ptlb:Within,ptin:_Within,varname:_Within,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:5,max:5;n:type:ShaderForge.SFN_VertexColor,id:9615,x:33890,y:32576,varname:node_9615,prsc:2;n:type:ShaderForge.SFN_Multiply,id:4218,x:34577,y:32629,varname:node_4218,prsc:1|A-4266-OUT,B-9615-RGB;n:type:ShaderForge.SFN_Multiply,id:5339,x:34596,y:32896,varname:node_5339,prsc:2|A-9615-A,B-4148-OUT;n:type:ShaderForge.SFN_Subtract,id:8627,x:33317,y:33293,varname:node_8627,prsc:2|A-4223-OUT,B-5422-OUT;n:type:ShaderForge.SFN_Slider,id:5422,x:33112,y:33498,ptovrint:False,ptlb:Subtract,ptin:_Subtract,varname:_Subtract,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.5128205,max:1;proporder:7241-8711-5750-4509-5495-645-10-6899-6369-2996-3048-4104-5422;pass:END;sub:END;*/

Shader "FX Kimi/Fire/Fire Blend Oneside" {
    Properties {
        _ColorAbroad ("Color Abroad", Color) = (1,0.8739352,0.1691176,1)
        _ColorWithin ("Color Within", Color) = (0.9926471,0.5014579,0.1240809,1)
        _Texture ("Texture", 2D) = "white" {}
        _TextureMask01 ("Texture Mask01", 2D) = "white" {}
        _TextureMask02 ("Texture Mask02", 2D) = "white" {}
        _Panner01U ("Panner01 U", Range(-5, 5)) = -0.2
        _Panner01V ("Panner01 V", Range(-5, 5)) = -0.3418804
        _Panner02U ("Panner02 U", Range(-5, 5)) = 0
        _Panner02V ("Panner02 V", Range(-5, 5)) = -0.5649143
        _Strength ("Strength", Range(0, 1)) = 0.1025641
        _Abroad ("Abroad", Range(0, 1)) = 0
        _Within ("Within", Range(0, 5)) = 5
        _Subtract ("Subtract", Range(0, 1)) = 0.5128205
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
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform half4 _ColorAbroad;
            uniform half _Panner01U;
            uniform half _Panner01V;
            uniform half _Panner02U;
            uniform half _Panner02V;
            uniform sampler2D _TextureMask01; uniform float4 _TextureMask01_ST;
            uniform sampler2D _TextureMask02; uniform float4 _TextureMask02_ST;
            uniform half _Strength;
            uniform half4 _ColorWithin;
            uniform sampler2D _Texture; uniform float4 _Texture_ST;
            uniform half _Abroad;
            uniform half _Within;
            uniform half _Subtract;
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
                half4 node_1261 = _Time;
                half2 node_4585 = (i.uv0+(node_1261.g*float2(_Panner01U,_Panner01V)));
                half4 _node_7061 = tex2D(_Texture,TRANSFORM_TEX(node_4585, _Texture));
                half2 node_5809 = ((i.uv0+(node_1261.g*float2(_Panner02U,_Panner02V)))*half2(2,1));
                half4 _node_4360 = tex2D(_Texture,TRANSFORM_TEX(node_5809, _Texture));
                half4 _TextureMask01_var = tex2D(_TextureMask01,TRANSFORM_TEX(i.uv0, _TextureMask01));
                float4 _TextureMask02_var = tex2D(_TextureMask02,TRANSFORM_TEX(i.uv0, _TextureMask02));
                half node_4223 = (((_node_7061.r+_node_4360.r)*_TextureMask01_var.r*5.0)*(_TextureMask02_var.r-_Strength));
                half node_9644 = ((node_4223-_Subtract)*node_4223);
                half node_4148 = step((0.5-_Abroad),node_9644);
                clip((i.vertexColor.a*node_4148) - 0.5);
////// Lighting:
                half node_6104 = step(_Within,node_9644);
                float3 finalColor = (((_ColorAbroad.rgb*node_6104)+((node_4148-node_6104)*_ColorWithin.rgb))*i.vertexColor.rgb);
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
