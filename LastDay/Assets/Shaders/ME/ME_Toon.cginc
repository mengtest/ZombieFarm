// NO utf8 BOM here!
#ifndef ME_TOON_CGINC
#define ME_TOON_CGINC
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"
#include "ME_SimulatePointLight.cginc"

sampler2D _MainTex;
fixed _Cutoff;
sampler2D _SkinTex;
fixed4 _MainTex_ST;
fixed _SkinCut;
fixed4 _HairUV;
fixed4 _HairColor;
fixed _HairSpecular;
fixed _HairShininess;
fixed4 _AtlasUV;
sampler2D _AlphaGridTex;

struct toon_a2v
{
    half4 vertex : POSITION;
    half3 normal : NORMAL;
    half2 texcoord : TEXCOORD0;
    half2 texcoord2 : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct toon_v2f
{
    half4 pos : POSITION;
    half4 uv : TEXCOORD0;
    fixed3 worldNormal : TEXCOORD1;
    fixed3 lightDir : TEXCOORD2;
    fixed3 viewDir : TEXCOORD3;

    // 声明_LightCoord和_ShadowCoord
    LIGHTING_COORDS(4, 5)

#ifdef TOON_TRANSPARENT
	half4 screenUv : TEXCOORD6;
    #ifdef TOON_SIMULATE_POINTLIT
	half3 worldPos : TEXCOORD7;
    #endif
#else
    #ifdef TOON_SIMULATE_POINTLIT
    half3 worldPos : TEXCOORD6;
    #endif
#endif
};

struct toon_unlit_v2f
{
	half4 pos : POSITION;
	half4 uv : TEXCOORD0;
    fixed3 vlight : TEXCOORD1;
#ifdef TOON_TRANSPARENT
    half4 screenUv : TEXCOORD2;
    #ifdef TOON_SIMULATE_POINTLIT
    half3 worldPos : TEXCOORD3;
    #endif
#else
    #ifdef TOON_SIMULATE_POINTLIT
    half3 worldPos : TEXCOORD2;
    #endif
#endif
};

inline float ToonHairClipping(in float2 uv, in float4 clipRect)
{
    float2 inside = step(clipRect.xy, uv) * step(uv, clipRect.zw);
    return inside.x * inside.y;
}

inline half RampSmoothSpec(half3 worldNormal, half3 lightDir, half3 viewDir)
{
    half nh = dot(worldNormal, normalize(lightDir + viewDir));
    //nh = sqrt(1 - nh * nh);
    half spec = pow(saturate(nh), _HairShininess * 128) * _HairSpecular;
    return spec;
}

inline fixed4 ToonColor(half2 uv, half2 uv2, fixed4 color)
{
     // 做UV变换
    uv = _AtlasUV.xy + uv * _AtlasUV.zw;

    fixed4 main = tex2D(_MainTex, uv);
    clip(main.a - _Cutoff);

#ifdef BLEND_SKIN_TEX
    uv2 = _AtlasUV.xy + uv2 * _AtlasUV.zw;
    fixed4 skin = tex2D(_SkinTex, uv2);
    main.rgb = lerp(skin.rgb, main.rgb, step(_SkinCut, main.a) * main.a);
#endif

#if ADD_HAIR_COLOR
    half inside = ToonHairClipping(uv, _HairUV);
    color.rgb = color.rgb * (1 - inside) + _HairColor * inside;
#endif

#ifdef SET_GRAYSCALE
    main.rgb = Luminance(main.rgb * color.rgb);
#else
    main.rgb *= color.rgb;
#endif

    return main;
}

inline fixed4 ToonSkin(half2 uv, half2 uv2, half3 worldPos, fixed4 color)
{
    fixed4 main = ToonColor(uv, uv2, color);
    main.rgb = CircleLighten(worldPos, main, 3.05);
    return main;
}

toon_v2f toon_vert(toon_a2v v)
{
    toon_v2f o;
    UNITY_SETUP_INSTANCE_ID(v);

    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
#ifdef BLEND_SKIN_TEX
    o.uv.zw = TRANSFORM_TEX(v.texcoord2, _MainTex);
#else
    o.uv.zw = half2(0, 0);
#endif
    o.worldNormal = normalize(mul(SCALED_NORMAL, (half3x3)unity_WorldToObject));
    o.lightDir = normalize(mul((half3x3)unity_ObjectToWorld, ObjSpaceLightDir(v.vertex)));
    o.viewDir = normalize(mul((half3x3)unity_ObjectToWorld, ObjSpaceViewDir(v.vertex)));
#ifdef TOON_SIMULATE_POINTLIT
	o.worldPos = mul(unity_ObjectToWorld, v.vertex);
#endif

#ifdef TOON_TRANSPARENT
    half4 screenPos = ComputeScreenPos(o.pos);
    screenPos.xy *= _ScreenParams.xy / 8;//此处不能先除w，会导致插值精度不够
    o.screenUv = screenPos;
#endif

    // 计算_LightCoord和_ShadowCoord
    TRANSFER_VERTEX_TO_FRAGMENT(o);
    return o;
}

inline fixed4 toon_frag(toon_v2f IN, fixed4 color)
{
#ifdef TOON_TRANSPARENT
    half gridAlpha = tex2Dproj(_AlphaGridTex, IN.screenUv).r;
    clip(color.a - gridAlpha);
#endif

#ifdef TOON_SIMULATE_POINTLIT
    return ToonSkin(IN.uv.xy, IN.uv.zw, IN.worldPos, color);
#else
    return ToonColor(IN.uv.xy, IN.uv.zw, color);
#endif
}


toon_unlit_v2f toon_unlit_vert(toon_a2v v)
{
	toon_unlit_v2f o;
	UNITY_SETUP_INSTANCE_ID(v);

    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
#ifdef BLEND_SKIN_TEX
    o.uv.zw = TRANSFORM_TEX(v.texcoord2, _MainTex);
#else
    o.uv.zw = half2(0, 0);
#endif
#ifdef TOON_SIMULATE_POINTLIT
	o.worldPos = mul(unity_ObjectToWorld, v.vertex);
#endif

#ifdef TOON_TRANSPARENT
    half4 screenPos = ComputeScreenPos(o.pos);
    screenPos.xy *= _ScreenParams.xy / 8;//此处不能先除w，会导致插值精度不够
    o.screenUv = screenPos;
#endif

	half3 worldNormal = mul((half3x3)unity_ObjectToWorld, SCALED_NORMAL);
	o.vlight = ShadeSH9 (half4(worldNormal, 1.0));

    return o;
}

inline fixed4 toon_unlit_frag(toon_unlit_v2f IN, fixed4 color)
{
#ifdef TOON_TRANSPARENT
    half gridAlpha = tex2Dproj(_AlphaGridTex, IN.screenUv).r;
    clip(color.a - gridAlpha);
#endif

    fixed4 main = ToonColor(IN.uv.xy, IN.uv.zw, color);
#ifdef TOON_SIMULATE_POINTLIT
    main.rgb = CircleLighten(IN.worldPos, main, 2);
#endif
    return main;
}

#endif