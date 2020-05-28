// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:33808,y:32669,varname:node_3138,prsc:2|emission-2672-OUT;n:type:ShaderForge.SFN_Color,id:7241,x:32471,y:32739,ptovrint:False,ptlb:Color,ptin:_Color,varname:_Color,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.07843138,c2:0.3921569,c3:0.7843137,c4:1;n:type:ShaderForge.SFN_Tex2d,id:2922,x:32471,y:32957,ptovrint:False,ptlb:Texture,ptin:_Texture,varname:_Texture,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:044af18e6867b9b40bf42ba7e74e6fd9,ntxv:0,isnm:False|UVIN-7764-UVOUT;n:type:ShaderForge.SFN_TexCoord,id:832,x:31081,y:32952,varname:node_832,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Rotator,id:5636,x:31277,y:32952,varname:node_5636,prsc:1|UVIN-832-UVOUT,ANG-6793-OUT;n:type:ShaderForge.SFN_Pi,id:8797,x:31112,y:33260,varname:node_8797,prsc:2;n:type:ShaderForge.SFN_UVTile,id:7764,x:32244,y:32957,varname:node_7764,prsc:1|UVIN-1855-OUT,WDT-4509-X,HGT-9976-OUT,TILE-737-OUT;n:type:ShaderForge.SFN_RemapRange,id:5150,x:31079,y:33102,varname:node_5150,prsc:2,frmn:0,frmx:360,tomn:0,tomx:2|IN-310-OUT;n:type:ShaderForge.SFN_Slider,id:310,x:30723,y:33102,ptovrint:False,ptlb:Rotation,ptin:_Rotation,varname:_Rotation,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:360;n:type:ShaderForge.SFN_Multiply,id:6793,x:31277,y:33102,varname:node_6793,prsc:2|A-5150-OUT,B-8797-OUT;n:type:ShaderForge.SFN_ComponentMask,id:4111,x:31464,y:32952,varname:node_4111,prsc:1,cc1:0,cc2:1,cc3:-1,cc4:-1|IN-5636-UVOUT;n:type:ShaderForge.SFN_Append,id:1855,x:31874,y:32955,varname:node_1855,prsc:2|A-4111-R,B-3770-OUT;n:type:ShaderForge.SFN_OneMinus,id:3770,x:31648,y:32955,varname:node_3770,prsc:2|IN-4111-G;n:type:ShaderForge.SFN_Negate,id:9976,x:32059,y:33100,varname:node_9976,prsc:2|IN-4509-Y;n:type:ShaderForge.SFN_Slider,id:9585,x:31717,y:33265,ptovrint:False,ptlb:UV Tile,ptin:_UVTile,varname:_UVTile,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:14.76923,max:64;n:type:ShaderForge.SFN_Trunc,id:737,x:32244,y:33100,varname:node_737,prsc:1|IN-7316-OUT;n:type:ShaderForge.SFN_Vector4Property,id:4509,x:31874,y:33100,ptovrint:False,ptlb:UV Count,ptin:_UVCount,varname:_UVCount,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:2,v2:2,v3:0,v4:0;n:type:ShaderForge.SFN_Time,id:891,x:31885,y:33343,varname:node_891,prsc:1;n:type:ShaderForge.SFN_Multiply,id:4368,x:32059,y:33343,varname:node_4368,prsc:2|A-196-OUT,B-891-T;n:type:ShaderForge.SFN_Slider,id:196,x:31746,y:33492,ptovrint:False,ptlb:Tile Speed,ptin:_TileSpeed,varname:_TileSpeed,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:50;n:type:ShaderForge.SFN_SwitchProperty,id:7316,x:32244,y:33269,ptovrint:False,ptlb:Tile Switch,ptin:_TileSwitch,varname:_TileSwitch,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:True|A-9585-OUT,B-4368-OUT;n:type:ShaderForge.SFN_Multiply,id:2830,x:32680,y:32789,varname:node_2830,prsc:2|A-7241-RGB,B-2922-R,C-5981-RGB;n:type:ShaderForge.SFN_VertexColor,id:5981,x:32471,y:33151,varname:node_5981,prsc:2;n:type:ShaderForge.SFN_Tex2d,id:6185,x:32471,y:33282,ptovrint:False,ptlb:Texture Distort,ptin:_TextureDistort,varname:_TextureDistort,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:96b250a9d106f0b4285a65a74275769e,ntxv:0,isnm:False|UVIN-8744-OUT;n:type:ShaderForge.SFN_Multiply,id:5160,x:33331,y:32906,varname:node_5160,prsc:2|A-2830-OUT,B-4498-OUT;n:type:ShaderForge.SFN_Power,id:9319,x:32735,y:33287,varname:node_9319,prsc:2|VAL-6185-R,EXP-7421-OUT;n:type:ShaderForge.SFN_Exp,id:7421,x:32735,y:33422,varname:node_7421,prsc:2,et:1|IN-5579-OUT;n:type:ShaderForge.SFN_Slider,id:5579,x:32359,y:33535,ptovrint:False,ptlb:Subtract,ptin:_Subtract,varname:_Subtract,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:5;n:type:ShaderForge.SFN_Multiply,id:4095,x:32960,y:33287,varname:node_4095,prsc:2|A-2922-R,B-9319-OUT;n:type:ShaderForge.SFN_Multiply,id:781,x:33169,y:33287,varname:node_781,prsc:2|A-4095-OUT,B-8898-OUT;n:type:ShaderForge.SFN_Slider,id:8898,x:32895,y:33496,ptovrint:False,ptlb:Strength,ptin:_Strength,varname:_Strength,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:2.111111,max:10;n:type:ShaderForge.SFN_Step,id:4261,x:33419,y:33277,varname:node_4261,prsc:2|A-781-OUT,B-1580-OUT;n:type:ShaderForge.SFN_Vector1,id:1580,x:33289,y:33461,varname:node_1580,prsc:2,v1:0.3;n:type:ShaderForge.SFN_OneMinus,id:2141,x:33603,y:33277,varname:node_2141,prsc:2|IN-4261-OUT;n:type:ShaderForge.SFN_Clamp01,id:4498,x:33781,y:33277,varname:node_4498,prsc:1|IN-2141-OUT;n:type:ShaderForge.SFN_Slider,id:7803,x:31748,y:33616,ptovrint:False,ptlb:Panner U,ptin:_PannerU,varname:_PannerU,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:-0.4076496,max:5;n:type:ShaderForge.SFN_Slider,id:8686,x:31748,y:33715,ptovrint:False,ptlb:Panner V,ptin:_PannerV,varname:_PannerV,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:0,max:5;n:type:ShaderForge.SFN_Append,id:1615,x:32078,y:33616,varname:node_1615,prsc:2|A-7803-OUT,B-8686-OUT;n:type:ShaderForge.SFN_Multiply,id:4910,x:32078,y:33489,varname:node_4910,prsc:2|A-891-T,B-1615-OUT;n:type:ShaderForge.SFN_Add,id:8744,x:32244,y:33489,varname:node_8744,prsc:1|A-832-UVOUT,B-4910-OUT;n:type:ShaderForge.SFN_Multiply,id:2672,x:33535,y:33047,varname:node_2672,prsc:2|A-7241-A,B-4498-OUT,C-5981-A,D-5160-OUT;proporder:7241-2922-6185-310-9585-4509-196-7316-5579-8898-7803-8686;pass:END;sub:END;*/

Shader "FX Kimi/Sequence/Sequence UV Add Distortion" {
    Properties {
        _Color ("Color", Color) = (0.07843138,0.3921569,0.7843137,1)
        _Texture ("Texture", 2D) = "white" {}
        _TextureDistort ("Texture Distort", 2D) = "white" {}
        _Rotation ("Rotation", Range(0, 360)) = 0
        _UVTile ("UV Tile", Range(0, 64)) = 14.76923
        _UVCount ("UV Count", Vector) = (2,2,0,0)
        _TileSpeed ("Tile Speed", Range(0, 50)) = 0
        [MaterialToggle] _TileSwitch ("Tile Switch", Float ) = 0
        _Subtract ("Subtract", Range(0, 5)) = 0
        _Strength ("Strength", Range(0, 10)) = 2.111111
        _PannerU ("Panner U", Range(-5, 5)) = -0.4076496
        _PannerV ("Panner V", Range(-5, 5)) = 0
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
            Blend One One
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
            uniform half4 _Color;
            uniform sampler2D _Texture; uniform float4 _Texture_ST;
            uniform half _Rotation;
            uniform half _UVTile;
            uniform half4 _UVCount;
            uniform half _TileSpeed;
            uniform fixed _TileSwitch;
            uniform sampler2D _TextureDistort; uniform float4 _TextureDistort_ST;
            uniform half _Subtract;
            uniform half _Strength;
            uniform half _PannerU;
            uniform half _PannerV;
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
                half4 node_891 = _Time;
                half node_737 = trunc(lerp( _UVTile, (_TileSpeed*node_891.g), _TileSwitch ));
                float2 node_7764_tc_rcp = float2(1.0,1.0)/float2( _UVCount.r, (-1*_UVCount.g) );
                float node_7764_ty = floor(node_737 * node_7764_tc_rcp.x);
                float node_7764_tx = node_737 - _UVCount.r * node_7764_ty;
                float node_5636_ang = ((_Rotation*0.005555556+0.0)*3.141592654);
                float node_5636_spd = 1.0;
                float node_5636_cos = cos(node_5636_spd*node_5636_ang);
                float node_5636_sin = sin(node_5636_spd*node_5636_ang);
                float2 node_5636_piv = float2(0.5,0.5);
                half2 node_5636 = (mul(i.uv0-node_5636_piv,float2x2( node_5636_cos, -node_5636_sin, node_5636_sin, node_5636_cos))+node_5636_piv);
                half2 node_4111 = node_5636.rg;
                half2 node_7764 = (float2(node_4111.r,(1.0 - node_4111.g)) + float2(node_7764_tx, node_7764_ty)) * node_7764_tc_rcp;
                half4 _Texture_var = tex2D(_Texture,TRANSFORM_TEX(node_7764, _Texture));
                half2 node_8744 = (i.uv0+(node_891.g*float2(_PannerU,_PannerV)));
                half4 _TextureDistort_var = tex2D(_TextureDistort,TRANSFORM_TEX(node_8744, _TextureDistort));
                half node_4498 = saturate((1.0 - step(((_Texture_var.r*pow(_TextureDistort_var.r,exp2(_Subtract)))*_Strength),0.3)));
                float3 emissive = (_Color.a*node_4498*i.vertexColor.a*((_Color.rgb*_Texture_var.r*i.vertexColor.rgb)*node_4498));
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
