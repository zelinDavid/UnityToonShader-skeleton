Shader "Roystan/Toon"
{
	
	Properties
	{
		_Color("Color", Color) = (0.5, 0.65, 1, 1)
		_MainTex("Main Texture", 2D) = "white" {}	
		[HRD]
		_AmbientColor("Color",Color) =(0.4,0.4,0.4,1)
		[HDR]
		_SpecularColor("Specular Color", Color) = (0.9,0.9,0.9,1)
		_Glossiness("Glossiness", Float) = 32
	}
	SubShader
	{
		Pass
		{
			Tags{
				"LightMode"="ForwardBase"
				"PassFlags"="OnlyDirectional"
			}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float3 normal:NORMAL;
				float4 vertex : POSITION;				
				float4 uv : TEXCOORD0;
			};

			struct v2f
			{
				float3 worldNormal:NORMAL;
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 viewDir : TEXCOORD1;

			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Glossiness;
			float4 _SpecularColor;

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = WorldSpaceViewDir(v.vertex);

				return o;
			}
			
			float4 _Color;
			float4 _AmbientColor;
			float4 frag (v2f i) : SV_Target
			{
				float3  ndotL = normalize(i.worldNormal);
				float lightIntensity = dot(_WorldSpaceLightPos0,ndotL);
				lightIntensity = smoothstep(0,0.05,lightIntensity);
				float4 light = lightIntensity * _LightColor0;
				
				float3 viewDir = normalize(i.viewDir);
				float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);

				float NdotH = dot(ndotL, halfVector);
				float specularIntensity = pow(NdotH * lightIntensity, _Glossiness * _Glossiness);


				float4 sample = tex2D(_MainTex, i.uv);

				// return _Color * sample * ret ;
				return _Color * sample *( _AmbientColor +  light + specularIntensity) ;
			}
			ENDCG
		}
	}
}