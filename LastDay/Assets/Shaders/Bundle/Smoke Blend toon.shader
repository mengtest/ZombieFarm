// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:False,qofs:0,qpre:2,rntp:3,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.007843138,fgcg:0.0509804,fgcb:0.1058824,fgca:1,fgde:0.01,fgrn:0,fgrf:150,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:37056,y:32390,varname:node_3138,prsc:2|emission-2889-OUT,clip-2723-OUT;n:type:ShaderForge.SFN_Color,id:5994,x:35618,y:32052,ptovrint:False,ptlb:Color,ptin:_Color,varname:_Color,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Tex2d,id:6928,x:35097,y:32865,ptovrint:False,ptlb:E_Tex,ptin:_E_Tex,varname:_E_Tex,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-945-UVOUT;n:type:ShaderForge.SFN_Multiply,id:2889,x:36539,y:32349,varname:node_2889,prsc:2|A-5526-OUT,B-8788-OUT,C-1367-OUT,D-7428-OUT;n:type:ShaderForge.SFN_Power,id:8788,x:36106,y:32269,varname:node_8788,prsc:2|VAL-7428-OUT,EXP-6115-OUT;n:type:ShaderForge.SFN_Tex2d,id:2873,x:36210,y:33130,ptovrint:False,ptlb:M_Tex,ptin:_M_Tex,varname:_M_Tex,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-2630-UVOUT;n:type:ShaderForge.SFN_VertexColor,id:5684,x:35581,y:32234,varname:node_5684,prsc:2;n:type:ShaderForge.SFN_Rotator,id:945,x:34894,y:32865,varname:node_945,prsc:1|UVIN-4405-UVOUT,SPD-1627-OUT;n:type:ShaderForge.SFN_ValueProperty,id:1627,x:34649,y:33049,ptovrint:False,ptlb:E_Rotator_Speed,ptin:_E_Rotator_Speed,varname:_E_Rotator_Speed,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.5;n:type:ShaderForge.SFN_TexCoord,id:4405,x:34648,y:32865,varname:node_4405,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Multiply,id:8808,x:35284,y:32865,varname:node_8808,prsc:2|A-6928-R,B-5830-OUT;n:type:ShaderForge.SFN_ValueProperty,id:5830,x:35097,y:33070,ptovrint:False,ptlb:High light,ptin:_Highlight,varname:_Highlight,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_OneMinus,id:8488,x:35475,y:32865,varname:node_8488,prsc:2|IN-8808-OUT;n:type:ShaderForge.SFN_NormalVector,id:121,x:34151,y:32548,prsc:2,pt:False;n:type:ShaderForge.SFN_Dot,id:3133,x:34362,y:32424,varname:node_3133,prsc:2,dt:1|A-8300-OUT,B-121-OUT;n:type:ShaderForge.SFN_Multiply,id:9977,x:34581,y:32424,varname:node_9977,prsc:2|A-3133-OUT,B-340-OUT;n:type:ShaderForge.SFN_Divide,id:8752,x:34865,y:32525,varname:node_8752,prsc:2|A-9977-OUT,B-340-OUT;n:type:ShaderForge.SFN_Add,id:1927,x:35055,y:32690,varname:node_1927,prsc:2|A-8752-OUT,B-1788-OUT;n:type:ShaderForge.SFN_Clamp01,id:795,x:35253,y:32690,varname:node_795,prsc:2|IN-1927-OUT;n:type:ShaderForge.SFN_ViewVector,id:8300,x:34151,y:32408,varname:node_8300,prsc:2;n:type:ShaderForge.SFN_If,id:715,x:35640,y:32456,varname:node_715,prsc:2|A-5684-A,B-795-OUT,GT-8488-OUT,EQ-2151-OUT,LT-9970-OUT;n:type:ShaderForge.SFN_Vector1,id:9970,x:35433,y:32580,varname:node_9970,prsc:2,v1:0;n:type:ShaderForge.SFN_Vector1,id:2151,x:35433,y:32520,varname:node_2151,prsc:2,v1:1;n:type:ShaderForge.SFN_Multiply,id:2723,x:36604,y:32572,varname:node_2723,prsc:2|A-5684-A,B-4186-OUT,C-8619-OUT,D-5994-A;n:type:ShaderForge.SFN_If,id:8619,x:36419,y:32789,varname:node_8619,prsc:2|A-856-OUT,B-2873-R,GT-8146-OUT,EQ-8146-OUT,LT-6996-OUT;n:type:ShaderForge.SFN_ValueProperty,id:2700,x:35702,y:32865,ptovrint:False,ptlb:Opacity,ptin:_Opacity,varname:_Opacity,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:856,x:35913,y:32739,varname:node_856,prsc:2|A-5684-A,B-2700-OUT;n:type:ShaderForge.SFN_Vector1,id:6996,x:35890,y:32982,varname:node_6996,prsc:2,v1:0;n:type:ShaderForge.SFN_Vector1,id:8146,x:35890,y:32907,varname:node_8146,prsc:1,v1:1;n:type:ShaderForge.SFN_Rotator,id:2630,x:35924,y:33239,varname:node_2630,prsc:1|UVIN-1610-UVOUT,SPD-6272-OUT;n:type:ShaderForge.SFN_ValueProperty,id:6272,x:35679,y:33423,ptovrint:False,ptlb:M_Rotator_Speed,ptin:_M_Rotator_Speed,varname:_M_Rotator_Speed,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_TexCoord,id:1610,x:35678,y:33239,varname:node_1610,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Multiply,id:1367,x:35953,y:32118,varname:node_1367,prsc:2|A-5684-RGB,B-5994-RGB;n:type:ShaderForge.SFN_Lerp,id:7428,x:36089,y:32529,varname:node_7428,prsc:1|A-715-OUT,B-2473-OUT,T-5648-OUT;n:type:ShaderForge.SFN_ValueProperty,id:2473,x:35777,y:32585,ptovrint:False,ptlb:Lerp_01,ptin:_Lerp_01,varname:_Lerp_01,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_ValueProperty,id:5648,x:35702,y:32714,ptovrint:False,ptlb:Lerp_02,ptin:_Lerp_02,varname:_Lerp_02,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Color,id:2413,x:32565,y:32730,ptovrint:False,ptlb:Color_copy,ptin:_Color_copy,varname:_Color_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.07843138,c2:0.3921569,c3:0.7843137,c4:1;n:type:ShaderForge.SFN_NormalVector,id:672,x:32748,y:33113,prsc:2,pt:False;n:type:ShaderForge.SFN_Slider,id:3941,x:32626,y:33294,ptovrint:False,ptlb:node_9535,ptin:_node_9535,varname:_node_9535,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Multiply,id:1076,x:32957,y:33113,varname:node_1076,prsc:2|A-672-OUT,B-3941-OUT,C-343-OUT;n:type:ShaderForge.SFN_TexCoord,id:7678,x:31674,y:33000,varname:node_7678,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Time,id:7912,x:31674,y:33161,varname:node_7912,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:4887,x:31686,y:33362,ptovrint:False,ptlb:node_2702,ptin:_node_2702,varname:_node_2702,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.2;n:type:ShaderForge.SFN_Multiply,id:7416,x:31874,y:33161,varname:node_7416,prsc:2|A-7912-T,B-4887-OUT;n:type:ShaderForge.SFN_ComponentMask,id:387,x:31874,y:33000,varname:node_387,prsc:2,cc1:0,cc2:-1,cc3:-1,cc4:-1|IN-2985-R;n:type:ShaderForge.SFN_Add,id:9741,x:32075,y:33000,varname:node_9741,prsc:2|A-387-OUT,B-7416-OUT;n:type:ShaderForge.SFN_Tau,id:733,x:32108,y:33136,varname:node_733,prsc:2;n:type:ShaderForge.SFN_Multiply,id:2529,x:32314,y:32960,varname:node_2529,prsc:2|A-9753-OUT,B-9741-OUT,C-733-OUT;n:type:ShaderForge.SFN_ValueProperty,id:9753,x:32075,y:32927,ptovrint:False,ptlb:node_6484,ptin:_node_6484,varname:_node_6484,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:2;n:type:ShaderForge.SFN_Sin,id:7667,x:32490,y:32960,varname:node_7667,prsc:2|IN-2529-OUT;n:type:ShaderForge.SFN_RemapRange,id:3540,x:32697,y:32960,varname:node_3540,prsc:2,frmn:-1,frmx:1,tomn:0,tomx:1|IN-7667-OUT;n:type:ShaderForge.SFN_Clamp01,id:343,x:32892,y:32960,varname:node_343,prsc:2|IN-3540-OUT;n:type:ShaderForge.SFN_Tex2d,id:4862,x:32892,y:32786,ptovrint:False,ptlb:node_2200,ptin:_node_2200,varname:_node_2200,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:4942,x:33158,y:32856,varname:node_4942,prsc:2|A-4862-R,B-343-OUT;n:type:ShaderForge.SFN_Tex2d,id:2985,x:31674,y:32812,ptovrint:False,ptlb:node_7276,ptin:_node_7276,varname:_node_7276,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Vector1,id:340,x:34593,y:32754,varname:node_340,prsc:1,v1:2;n:type:ShaderForge.SFN_Vector1,id:4186,x:36275,y:32685,varname:node_4186,prsc:2,v1:30;n:type:ShaderForge.SFN_Vector1,id:6115,x:35898,y:32478,varname:node_6115,prsc:2,v1:2.4;n:type:ShaderForge.SFN_Vector1,id:5526,x:36392,y:32276,varname:node_5526,prsc:2,v1:25;n:type:ShaderForge.SFN_Vector1,id:1788,x:34848,y:32778,varname:node_1788,prsc:2,v1:-0.15;proporder:5994-6928-2873-1627-5830-2700-6272-2473-5648;pass:END;sub:END;*/

Shader "FX Kimi/Smoke/Smoke Blend toon" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _E_Tex ("E_Tex", 2D) = "white" {}
        _M_Tex ("M_Tex", 2D) = "white" {}
        _E_Rotator_Speed ("E_Rotator_Speed", Float ) = 0.5
        _Highlight ("High light", Float ) = 1
        _Opacity ("Opacity", Float ) = 1
        _M_Rotator_Speed ("M_Rotator_Speed", Float ) = 1
        _Lerp_01 ("Lerp_01", Float ) = 1
        _Lerp_02 ("Lerp_02", Float ) = 0
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
            uniform half4 _Color;
            uniform sampler2D _E_Tex; uniform float4 _E_Tex_ST;
            uniform sampler2D _M_Tex; uniform float4 _M_Tex_ST;
            uniform half _E_Rotator_Speed;
            uniform half _Highlight;
            uniform half _Opacity;
            uniform half _M_Rotator_Speed;
            uniform half _Lerp_01;
            uniform half _Lerp_02;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float4 node_499 = _Time;
                float node_2630_ang = node_499.g;
                float node_2630_spd = _M_Rotator_Speed;
                float node_2630_cos = cos(node_2630_spd*node_2630_ang);
                float node_2630_sin = sin(node_2630_spd*node_2630_ang);
                float2 node_2630_piv = float2(0.5,0.5);
                half2 node_2630 = (mul(i.uv0-node_2630_piv,float2x2( node_2630_cos, -node_2630_sin, node_2630_sin, node_2630_cos))+node_2630_piv);
                half4 _M_Tex_var = tex2D(_M_Tex,TRANSFORM_TEX(node_2630, _M_Tex));
                float node_8619_if_leA = step((i.vertexColor.a*_Opacity),_M_Tex_var.r);
                float node_8619_if_leB = step(_M_Tex_var.r,(i.vertexColor.a*_Opacity));
                half node_8146 = 1.0;
                clip((i.vertexColor.a*30.0*lerp((node_8619_if_leA*0.0)+(node_8619_if_leB*node_8146),node_8146,node_8619_if_leA*node_8619_if_leB)*_Color.a) - 0.5);
////// Lighting:
////// Emissive:
                half node_340 = 2.0;
                float node_715_if_leA = step(i.vertexColor.a,saturate((((max(0,dot(viewDirection,i.normalDir))*node_340)/node_340)+(-0.15))));
                float node_715_if_leB = step(saturate((((max(0,dot(viewDirection,i.normalDir))*node_340)/node_340)+(-0.15))),i.vertexColor.a);
                float node_945_ang = node_499.g;
                float node_945_spd = _E_Rotator_Speed;
                float node_945_cos = cos(node_945_spd*node_945_ang);
                float node_945_sin = sin(node_945_spd*node_945_ang);
                float2 node_945_piv = float2(0.5,0.5);
                half2 node_945 = (mul(i.uv0-node_945_piv,float2x2( node_945_cos, -node_945_sin, node_945_sin, node_945_cos))+node_945_piv);
                half4 _E_Tex_var = tex2D(_E_Tex,TRANSFORM_TEX(node_945, _E_Tex));
                half node_7428 = lerp(lerp((node_715_if_leA*0.0)+(node_715_if_leB*(1.0 - (_E_Tex_var.r*_Highlight))),1.0,node_715_if_leA*node_715_if_leB),_Lerp_01,_Lerp_02);
                float3 emissive = (25.0*pow(node_7428,2.4)*(i.vertexColor.rgb*_Color.rgb)*node_7428);
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
