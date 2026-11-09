Shader "VietTrail/Painterly Sky"
{
 Properties
 {
  _ZenithColor("Upper sky", Color)=(0.59,0.74,0.74,1)
  _HorizonColor("Warm horizon", Color)=(0.88,0.79,0.63,1)
  _GroundColor("Below horizon", Color)=(0.65,0.72,0.61,1)
  _SunColor("Soft sun", Color)=(1,0.88,0.65,1)
  _SunDirection("Direction toward sun", Vector)=(0.3,0.45,0.7,0)
  _SunSize("Sun angular softness", Range(0.001,0.05))=0.008
  _CloudColor("Painted clouds", Color)=(0.94,0.89,0.75,1)
  _CloudAmount("Cloud coverage", Range(0,1))=0.35
 }
 SubShader
 {
  Tags { "RenderPipeline"="UniversalPipeline" "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
  Cull Off ZWrite Off
  Pass
  {
   HLSLPROGRAM
   #pragma vertex Vert
   #pragma fragment Frag
   #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
   CBUFFER_START(UnityPerMaterial)
    half4 _ZenithColor,_HorizonColor,_GroundColor,_SunColor,_CloudColor;
    float4 _SunDirection; float _SunSize,_CloudAmount;
   CBUFFER_END
   struct Attributes { float4 positionOS:POSITION; };
   struct Varyings { float4 positionCS:SV_POSITION; float3 direction:TEXCOORD0; };
   Varyings Vert(Attributes v) { Varyings o; o.positionCS=TransformObjectToHClip(v.positionOS.xyz); o.direction=v.positionOS.xyz; return o; }
   half4 Frag(Varyings i):SV_Target
   {
    float3 d=normalize(i.direction); float altitude=saturate(d.y);
    half3 sky=lerp(_HorizonColor.rgb,_ZenithColor.rgb,smoothstep(0,0.85,altitude));
    sky=lerp(sky,_GroundColor.rgb,(1-smoothstep(-0.4,0,d.y)));
    // Direction-space broad overlapping strokes: cheap, static and seam-free.
    float stroke=sin(d.x*13+d.z*4)*0.4+sin(d.z*17-d.x*5)*0.25+sin(d.x*29+d.z*21)*0.1;
    float clouds=smoothstep(0.65-_CloudAmount,0.9-_CloudAmount,stroke)*smoothstep(0.02,0.18,d.y)*(1-smoothstep(0.5,0.8,d.y));
    sky=lerp(sky,_CloudColor.rgb,clouds*0.65);
    float sunDot=saturate(dot(d,normalize(_SunDirection.xyz)));
    float disk=smoothstep(1-_SunSize,1-_SunSize*0.25,sunDot);
    float halo=pow(sunDot,24)*0.12;
    sky=lerp(sky,_SunColor.rgb,saturate(disk*0.7+halo));
    return half4(sky,1);
   }
   ENDHLSL
  }
 }
 Fallback Off
}
