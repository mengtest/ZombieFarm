Shader "ME/MeshShadow"
{
	Properties
	{	
		_ShadowAlpha ("Shadow Alpha", Range(0,1)) = 0.5
		_GroundY ("GroundY", float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		UsePass "Hidden/Toon/MESH SHADOW"
	}
}
