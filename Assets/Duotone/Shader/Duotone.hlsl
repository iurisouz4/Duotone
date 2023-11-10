static float DuotoneBayerArray[] =
{
#if defined(_DITHERTYPE_BAYER2X2)
    0.000000, 0.664062,
    0.996094, 0.332031,
#elif defined(_DITHERTYPE_BAYER3X3)
    0.000000, 0.871094, 0.371094,
    0.746094, 0.621094, 0.246094,
    0.496094, 0.121094, 0.996094,
#elif defined(_DITHERTYPE_BAYER4X4)
    0.000000, 0.531250, 0.132812, 0.664062,
    0.796875, 0.265625, 0.929688, 0.398438,
    0.199219, 0.730469, 0.066406, 0.597656,
    0.996094, 0.464844, 0.863281, 0.332031,
#else
    0.000000, 0.757812, 0.187500, 0.945312, 0.046875, 0.804688, 0.234375, 0.996094,
    0.503906, 0.250000, 0.695312, 0.441406, 0.550781, 0.296875, 0.742188, 0.488281,
    0.125000, 0.882812, 0.062500, 0.820312, 0.171875, 0.929688, 0.109375, 0.867188,
    0.628906, 0.378906, 0.566406, 0.312500, 0.679688, 0.425781, 0.613281, 0.363281,
    0.031250, 0.789062, 0.218750, 0.976562, 0.015625, 0.773438, 0.203125, 0.960938,
    0.535156, 0.281250, 0.726562, 0.472656, 0.519531, 0.265625, 0.710938, 0.457031,
    0.156250, 0.914062, 0.093750, 0.851562, 0.140625, 0.898438, 0.078125, 0.835938,
    0.664062, 0.410156, 0.597656, 0.347656, 0.644531, 0.394531, 0.582031, 0.332031
#endif
};

void DuotoneSamplePoints_float
  (float2 UV, float Width, float Height,
   out float2 UV1, out float2 UV2, out float2 UV3)
{
    UV1 = UV + float2(1 / Width, 1 / Height);
    UV2 = float2(UV.x, UV1.y);
    UV3 = float2(UV1.x, UV.y);
}

void DuotoneMain_float
  (float2 SPos, float Width, float Height,
   float3 C0, float3 C1, float3 C2, float3 C3,
   float4 EdgeColor,
   float4 ColorKey0, float4 ColorKey1, float4 ColorKey2, float4 ColorKey3,
   float DitherStrength,
   out float3 Output)
{
    // Roberts cross operator
    float2 g1 = C1.yz - C0.yz;
    float2 g2 = C3.yz - C2.yz;
    float2 g = sqrt(g1 * g1 + g2 * g2);

    // Dithering
    uint2 psp = SPos * float2(Width, Height);
#if defined(_DITHERTYPE_BAYER2X2)
    float dither = DuotoneBayerArray[(psp.x % 2) + (psp.y % 2) * 2];
#elif defined(_DITHERTYPE_BAYER3X3)
    float dither = DuotoneBayerArray[(psp.x % 3) + (psp.y % 3) * 3];
#elif defined(_DITHERTYPE_BAYER4X4)
    float dither = DuotoneBayerArray[(psp.x % 4) + (psp.y % 4) * 4];
#else
    float dither = DuotoneBayerArray[(psp.x % 8) + (psp.y % 8) * 8];
#endif
    dither = (dither - 0.5) * DitherStrength;

    float3 fill = ColorKey0.rgb;
    float lum = C0.x + dither;
    fill = lum > ColorKey0.w ? ColorKey1.rgb : fill;
    fill = lum > ColorKey1.w ? ColorKey2.rgb : fill;
    fill = lum > ColorKey2.w ? ColorKey3.rgb : fill;

    float edge1 = smoothstep(0.10, 0.20, g.x);
    float edge2 = smoothstep(0.03, 0.04, g.y);
    float edge = max(edge1, edge2);

    Output = lerp(fill, EdgeColor.rgb, edge * EdgeColor.a);
}
