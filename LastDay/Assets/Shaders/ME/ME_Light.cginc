// NO utf8 BOM here!
#ifndef ME_LIGHT_CGINC
#define ME_LIGHT_CGINC

fixed4 _HColor;
fixed4 _SColor;

#if TOON_RAMP_TEX
	sampler2D _Ramp;
#else
	fixed _RampThreshold;
	fixed _RampSmooth;
#endif

fixed _SpecSmooth;

inline fixed4 RampSmooth(fixed4 fcol, half3 worldNormal, half3 lightDir, half atten)
{
    half ndl = max(0, dot(worldNormal, lightDir) * 0.5 + 0.5);
#if TOON_RAMP_TEX
	half ramp = tex2D(_Ramp, fixed2(ndl, ndl));
#else
    half rampSmooth = _RampSmooth * 0.5;
    half ramp = smoothstep(_RampThreshold - rampSmooth, _RampThreshold + rampSmooth, ndl);
#endif
    _SColor = lerp(_HColor, _SColor, _LightColor0.a / 2);    //Shadows intensity through alpha
    ramp = lerp(_SColor.rgb, _HColor.rgb, ramp);
	//atten = lerp(_SColor.rgb, _HColor.rgb, atten);

    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

    fixed4 c;
    c.rgb = fcol.rgb * ambient + fcol.rgb * ramp * atten;// min(ramp, atten);
    c.a = fcol.a;
    return c;
}

inline fixed4 RampSmoothLight(fixed4 fcol, half3 worldNormal, half3 lightDir, half atten)
{
	fixed4 c = RampSmooth(fcol, worldNormal, lightDir, atten);
	c.rgb *= _LightColor0.rgb;
	return c;
}

inline fixed4 LightingRampSmooth(SurfaceOutput s, half3 lightDir, half atten)
{
    return RampSmoothLight(fixed4(s.Albedo, s.Alpha), s.Normal, lightDir, atten);
}

inline fixed4 LightingRampSmoothSpec(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
{
    fixed ndl = max(0, dot(s.Normal, lightDir) * 0.5 + 0.5);
#if TOON_RAMP_TEX
	half ramp = tex2D(_Ramp, fixed2(ndl, ndl));
#else
    fixed rampSmooth = _RampSmooth * 0.5;
    fixed3 ramp = smoothstep(_RampThreshold - rampSmooth, _RampThreshold + rampSmooth, ndl);
#endif
    _SColor = lerp(_HColor, _SColor, _SColor.a);	//Shadows intensity through alpha
    ramp = lerp(_SColor.rgb, _HColor.rgb, ramp);
    atten = lerp(_SColor.rgb, _HColor.rgb, atten);

    //Specular
    fixed3 h = normalize(lightDir + viewDir);
    fixed ndh = max(0, dot(s.Normal, h));
    half spec = pow(ndh, s.Specular * 128.0) * s.Gloss;
#if _SPEC_TOON
    fixed specSmooth = _SpecSmooth * 0.5;
    spec = smoothstep(0.5 - specSmooth, 0.5 + specSmooth, spec);
#endif
    fixed4 c;
    c.rgb = s.Albedo * _LightColor0.rgb * ramp * min(ramp, atten);;
    c.rgb += _LightColor0.rgb * s.Specular * spec;
    //c.a = s.Alpha + _LightColor0.a * spec;

    return c;
}
#endif