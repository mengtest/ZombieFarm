// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:False,qofs:0,qpre:2,rntp:3,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:33200,y:32711,varname:node_3138,prsc:2|emission-3983-OUT,clip-2002-OUT,voffset-3508-OUT;n:type:ShaderForge.SFN_Color,id:7241,x:32069,y:32704,ptovrint:False,ptlb:WithinColor,ptin:_WithinColor,varname:_WithinColor,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:0.3517241,c3:0,c4:1;n:type:ShaderForge.SFN_Lerp,id:3977,x:32481,y:32904,varname:node_3977,prsc:1|A-9418-RGB,B-7352-OUT,T-7364-OUT;n:type:ShaderForge.SFN_Color,id:9418,x:32252,y:32503,ptovrint:False,ptlb:AbroadColor,ptin:_AbroadColor,varname:_AbroadColor,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.3823529,c2:0.3823529,c3:0.3823529,c4:1;n:type:ShaderForge.SFN_If,id:7364,x:32252,y:32952,varname:node_7364,prsc:2|A-5057-R,B-7368-OUT,GT-321-OUT,EQ-321-OUT,LT-9567-OUT;n:type:ShaderForge.SFN_Tex2d,id:5057,x:31739,y:32848,varname:_Texture,prsc:1,tex:ba8df427858282b429a586e55b1cbd92,ntxv:0,isnm:False|TEX-5961-TEX;n:type:ShaderForge.SFN_Tex2d,id:8198,x:31747,y:33178,varname:_node_8198,prsc:1,tex:ba8df427858282b429a586e55b1cbd92,ntxv:0,isnm:False|TEX-5961-TEX;n:type:ShaderForge.SFN_Vector1,id:321,x:31992,y:32994,varname:node_321,prsc:1,v1:0;n:type:ShaderForge.SFN_Vector1,id:9567,x:31868,y:33123,varname:node_9567,prsc:1,v1:1;n:type:ShaderForge.SFN_If,id:2002,x:32250,y:33229,varname:node_2002,prsc:2|A-5057-R,B-317-OUT,GT-4146-OUT,EQ-4146-OUT,LT-4714-OUT;n:type:ShaderForge.SFN_Multiply,id:3508,x:32250,y:33371,varname:node_3508,prsc:2|A-8198-R,B-1352-OUT,C-7368-OUT,D-7768-OUT;n:type:ShaderForge.SFN_NormalVector,id:1352,x:32002,y:33441,prsc:2,pt:False;n:type:ShaderForge.SFN_ValueProperty,id:7768,x:31483,y:33719,ptovrint:False,ptlb:Offset,ptin:_Offset,varname:_Offset,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Tex2dAsset,id:5961,x:31374,y:32866,ptovrint:False,ptlb:Texture Cells,ptin:_TextureCells,varname:_TextureCells,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:ba8df427858282b429a586e55b1cbd92,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Slider,id:317,x:31326,y:33322,ptovrint:False,ptlb:Strength,ptin:_Strength,varname:_Strength,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.4102564,max:3;n:type:ShaderForge.SFN_Slider,id:7368,x:31326,y:33545,ptovrint:False,ptlb:Contrast,ptin:_Contrast,varname:_Contrast,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.8205128,max:3;n:type:ShaderForge.SFN_Multiply,id:7352,x:32309,y:32729,varname:node_7352,prsc:2|A-6405-OUT,B-7241-RGB;n:type:ShaderForge.SFN_ValueProperty,id:6405,x:32069,y:32573,ptovrint:False,ptlb:Glow,ptin:_Glow,varname:_Glow,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:2;n:type:ShaderForge.SFN_Vector1,id:4146,x:32049,y:33229,varname:node_4146,prsc:1,v1:0;n:type:ShaderForge.SFN_Vector1,id:4714,x:32049,y:33342,varname:node_4714,prsc:2,v1:1;n:type:ShaderForge.SFN_Step,id:9829,x:32414,y:33102,varname:node_9829,prsc:2|A-5057-R,B-6635-OUT;n:type:ShaderForge.SFN_OneMinus,id:5990,x:32626,y:33102,varname:node_5990,prsc:2|IN-9829-OUT;n:type:ShaderForge.SFN_Add,id:4205,x:32842,y:33077,varname:node_4205,prsc:2|A-5990-OUT,B-3608-RGB;n:type:ShaderForge.SFN_Color,id:3608,x:32603,y:33292,ptovrint:False,ptlb:ShadowColor,ptin:_ShadowColor,varname:_ShadowColor,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.75,c2:0.6727941,c3:0.6727941,c4:1;n:type:ShaderForge.SFN_Multiply,id:3983,x:32969,y:32858,varname:node_3983,prsc:2|A-3977-OUT,B-6088-OUT;n:type:ShaderForge.SFN_Slider,id:6635,x:32066,y:33130,ptovrint:False,ptlb:Shadow,ptin:_Shadow,varname:_Shadow,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.3504274,max:1;n:type:ShaderForge.SFN_Slider,id:4900,x:31197,y:34029,ptovrint:False,ptlb:node_5196_copy,ptin:_node_5196_copy,varname:_node_5196_copy,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:0.1367521,max:5;n:type:ShaderForge.SFN_Slider,id:9351,x:31197,y:34170,ptovrint:False,ptlb:node_3825_copy,ptin:_node_3825_copy,varname:_node_3825_copy,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:0,max:5;n:type:ShaderForge.SFN_Append,id:7042,x:31522,y:34029,varname:node_7042,prsc:2|A-4900-OUT,B-9351-OUT;n:type:ShaderForge.SFN_Multiply,id:6088,x:33011,y:33113,varname:node_6088,prsc:2|A-4205-OUT,B-6476-OUT;n:type:ShaderForge.SFN_Vector1,id:6476,x:32813,y:33370,varname:node_6476,prsc:2,v1:0.5;proporder:7241-9418-3608-5961-7768-6405-317-7368-6635;pass:END;sub:END;*/

Shader "FX Kimi/Blast/Blast Blend" {
    Properties {
        _WithinColor ("WithinColor", Color) = (1,0.3517241,0,1)
        _AbroadColor ("AbroadColor", Color) = (0.3823529,0.3823529,0.3823529,1)
        _ShadowColor ("ShadowColor", Color) = (0.75,0.6727941,0.6727941,1)
        _TextureCells ("Texture Cells", 2D) = "white" {}
        _Offset ("Offset", Float ) = 1
        _Glow ("Glow", Float ) = 2
        _Strength ("Strength", Range(0, 3)) = 0.4102564
        _Contrast ("Contrast", Range(0, 3)) = 0.8205128
        _Shadow ("Shadow", Range(0, 1)) = 0.3504274
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
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform half4 _WithinColor;
            uniform half4 _AbroadColor;
            uniform half _Offset;
            uniform sampler2D _TextureCells; uniform float4 _TextureCells_ST;
            uniform half _Strength;
            uniform half _Contrast;
            uniform half _Glow;
            uniform float4 _ShadowColor;
            uniform half _Shadow;
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
                half4 _node_8198 = tex2Dlod(_TextureCells,float4(TRANSFORM_TEX(o.uv0, _TextureCells),0.0,0));
                v.vertex.xyz += (_node_8198.r*v.normal*_Contrast*_Offset);
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
                half4 _Texture = tex2D(_TextureCells,TRANSFORM_TEX(i.uv0, _TextureCells));
                float node_2002_if_leA = step(_Texture.r,_Strength);
                float node_2002_if_leB = step(_Strength,_Texture.r);
                half node_4146 = 0.0;
                clip(lerp((node_2002_if_leA*1.0)+(node_2002_if_leB*node_4146),node_4146,node_2002_if_leA*node_2002_if_leB) - 0.5);
////// Lighting:
////// Emissive:
                float node_7364_if_leA = step(_Texture.r,_Contrast);
                float node_7364_if_leB = step(_Contrast,_Texture.r);
                half node_321 = 0.0;
                float3 emissive = (lerp(_AbroadColor.rgb,(_Glow*_WithinColor.rgb),lerp((node_7364_if_leA*1.0)+(node_7364_if_leB*node_321),node_321,node_7364_if_leA*node_7364_if_leB))*(((1.0 - step(_Texture.r,_Shadow))+_ShadowColor.rgb)*0.5));
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
