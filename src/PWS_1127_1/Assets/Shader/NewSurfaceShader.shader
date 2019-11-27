Shader "Custom/NewSurfaceShader"
{
	Properties
	{
		_AlbedoTex("Texture", 2D) = "white" {}
	_HeightTex("Texture", 2D) = "white" {}
	_HeightScale("HeightScale", Range(-2.0, 2.0)) = 0.0
		_TessFactor("TessFactor", Range(0.0, 10.0)) = 3.0
		_bTex("bTex", 2D) = "black" {}
	_Length("Length", Range(-2.0, 2.0)) = 0.0
	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
	{
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma hull hull
#pragma domain dom

#include "UnityCG.cginc"
#include "Lighting.cginc"

		struct appdata
	{
		float4 pos : POSITION;
		float2 uv : TEXCOORD0;
		float3 normal : NORMAL;
	};

	struct v2h
	{
		float4 pos : POS;

		float2 uv : TEXCOORD0;
		float3 normal : NORMAL;
	};

	struct h2d_main
	{
		float4 pos : POS;
		float2 uv : TEXCOORD0;
		float3 normal : NORMAL;
	};

	struct h2d_const
	{
		float tess_factor[3] : SV_TessFactor;
		float InsideTessFactor : SV_InsideTessFactor;
	};

	struct d2f
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};

	sampler2D _AlbedoTex;
	sampler2D _HeightTex;
	sampler2D _bTex;
	float4 _AlbedoTex_ST;
	float _HeightScale;
	float _TessFactor;
	float _Length;

	v2h vert(appdata v)
	{
		v2h o = (v2h)0;
		o.pos = v.pos;
		o.uv = v.uv;
		o.normal = v.normal;

		return o;
	}

	h2d_const HSConst(InputPatch<v2h, 3> i)
	{
		h2d_const o = (h2d_const)0;
		o.tess_factor[0] = _TessFactor;
		o.tess_factor[1] = _TessFactor;
		o.tess_factor[2] = _TessFactor;
		o.InsideTessFactor = _TessFactor;

		return o;
	}

	[domain("tri")]
	[partitioning("integer")]
	[outputtopology("triangle_cw")]
	[outputcontrolpoints(3)]
	[patchconstantfunc("HSConst")]
	h2d_main hull(InputPatch<v2h, 3>i, uint id : SV_OutputControlPointID)
	{
		h2d_main o = (h2d_main)0;
		o.pos = i[id].pos;
		o.uv = i[id].uv;
		o.normal = i[id].normal;

		return o;
	}

	[domain("tri")]
	d2f dom(h2d_const hs_const_data, const OutputPatch<h2d_main, 3> i, float3 bary:SV_DomainLocation)
	{
		d2f o = (d2f)0;
		o.uv = i[0].uv * bary.x + i[1].uv * bary.y + i[2].uv * bary.z;
		float3 nrm = i[0].normal * bary.x + i[1].normal * bary.y + i[2].normal * bary.z;
		float3 pos = i[0].pos * bary.x + i[1].pos * bary.y + i[2].pos * bary.z;

		fixed height = tex2Dlod(_HeightTex, float4(o.uv, 0, 0)).x;
		fixed b = tex2Dlod(_bTex, float4(o.uv, 0, 0)).z;
		fixed r = tex2Dlod(_bTex, float4(o.uv, 0, 0)).x;
		pos += nrm * height * _HeightScale;
		pos -= b * _Length * nrm;
		pos += r * _Length * nrm;

		o.pos = UnityObjectToClipPos(float4(pos, 1));
		return o;
	}

	fixed4 frag(v2h i) : SV_Target
	{
		fixed4 col = tex2D(_AlbedoTex, i.uv);

	return col;
	}
		ENDCG
	}
	}
    FallBack "Diffuse"
}
