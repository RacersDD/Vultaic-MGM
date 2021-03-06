#include "mta-helper.fx"

#define PI 3.141592653589793
#define TAU 6.283185307179586

float2 resolution = float2(1, 1);
float intensity = 1;
float opacity = 1;
float3 color = float3(1.0, 1.0, 1.0);
float rate = 1.0;

struct vsin
{
	float4 Position : POSITION;
	float2 TexCoord : TEXCOORD0;
};

struct vsout
{
	float4 Position : POSITION;
	float2 TexCoord : TEXCOORD0;
};

vsout vs(vsin input)
{
	vsout output;
	output.Position = mul(input.Position, gWorldViewProjection);
	output.TexCoord = input.TexCoord;
	return output;
}

float4 ps(vsout input) : COLOR0
{
	float iGlobalTime = gTime * (1. + rate);
	float alpha = pow(intensity*2,2)*opacity*1.5;
	float2 p = (input.TexCoord.xy - resolution) / min(resolution.x, resolution.y);  
	float f = 0.0;
	for(float i = 0.0; i < 200.0; i++){
	float s = sin(iGlobalTime*0.01 + i * PI / 100.0) * 0.7;
	float c = cos(iGlobalTime*0.01 + i * PI / 100.0) * 0.7;
	f += 0.01 / (abs(p.x + c) - abs(p.y + s));
	}
	float x = input.TexCoord.x;
	float y = input.TexCoord.y;
	float3 c = float3(color.r*abs(x-0.5), color.g*abs(y-0.5), color.b*(abs(y-0.5)));
	return float4(float3(f * c), alpha * 2*pow(abs(distance(float2(0.5,0.5),input.TexCoord)),2));
}

float countDepthBias(float minBias, float maxBias, float closeBias)
{
    float4 viewPos = mul(float4(gWorld[3].xyz, 1), gView);
    float4 projPos = mul(viewPos, gProjection);
    float depthImpact = minBias + ((maxBias - minBias) * (1 - saturate(projPos.z / projPos.w)));
    depthImpact += closeBias * saturate(0.5 - (viewPos.z / viewPos.w));
    return depthImpact;
}

technique tec
{
	pass Pass0
	{
        SlopeScaleDepthBias = -0.5;
        DepthBias = countDepthBias(-0.000002, -0.0004, -0.001);
		AlphaBlendEnable = true;
		AlphaRef = 1;
		VertexShader = compile vs_3_0 vs();
		PixelShader = compile ps_3_0 ps();
	}
}