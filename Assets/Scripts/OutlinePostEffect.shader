Shader "Custom/OutlinePostEffect"
{
	Properties
	{
		_MainTex("Main Texture",2D) = "black"{}
		_Delta("Delta", Range(0, 1)) = 0.002
	}
		SubShader
		{
			ZTest Always
			ZWrite Off
			Cull Off
			Pass
			{
				CGPROGRAM

				sampler2D _MainTex;
				sampler2D _CameraDepthTexture;

				//<SamplerName>_TexelSize is a float2 that says how much screen space a texel occupies.
				float2 _MainTex_TexelSize;
				float _Delta;

				#pragma vertex vert_img
				#pragma fragment frag
				#include "UnityCG.cginc"

				float SampleDepth(float2 uv) {
				   float d = tex2D(_CameraDepthTexture, uv).r;
				   float depth = Linear01Depth(d);
				   return depth;
				}

				float sobel(float2 uv)
				{
					float2 delta = float2(_Delta, _Delta);

					float hr = 0;
					float vt = 0;

					hr += SampleDepth(uv + float2(-1.0, -1.0) * delta) * 1.0;
					hr += SampleDepth(uv + float2(1.0, -1.0) * delta) * -1.0;
					hr += SampleDepth(uv + float2(-1.0,  0.0) * delta) * 2.0;
					hr += SampleDepth(uv + float2(1.0,  0.0) * delta) * -2.0;
					hr += SampleDepth(uv + float2(-1.0,  1.0) * delta) * 1.0;
					hr += SampleDepth(uv + float2(1.0,  1.0) * delta) * -1.0;

					vt += SampleDepth(uv + float2(-1.0, -1.0) * delta) * 1.0;
					vt += SampleDepth(uv + float2(0.0, -1.0) * delta) * 2.0;
					vt += SampleDepth(uv + float2(1.0, -1.0) * delta) * 1.0;
					vt += SampleDepth(uv + float2(-1.0,  1.0) * delta) * -1.0;
					vt += SampleDepth(uv + float2(0.0,  1.0) * delta) * -2.0;
					vt += SampleDepth(uv + float2(1.0,  1.0) * delta) * -1.0;

					return sqrt(hr * hr + vt * vt);
				}
				half4 frag(v2f_img i) : COLOR
				{

					float2 adjustedUvs = UnityStereoTransformScreenSpaceTex(i.uv);
					float s = pow(1 - saturate(sobel(adjustedUvs)), 50);
					half4 col = tex2D(_MainTex, adjustedUvs);

					return s * col;
				}

				ENDCG

			}
		}
			//end subshader
}
//end shader