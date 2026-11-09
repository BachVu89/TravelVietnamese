Shader "VietTrail/Painterly Lit"
{
 Properties
 {
  _Palette("Original palette atlas", 2D) = "white" {}
  _ShadowTint("Painted shadow tint", Color) = (0.67,0.73,0.66,1)
  _HeightLowTint("Low terrain tint", Color) = (0.85,0.91,0.82,1)
  _HeightHighTint("High terrain tint", Color) = (1.06,1.01,0.90,1)
  _SlopeTint("Steep terrain brown-violet tint", Color) = (0.78,0.69,0.74,1)
  _SlopeThreshold("Steep slope threshold normal Y", Range(0,1)) = 0.65
  _HeightMin("Gradient lower world height", Float) = 0
  _HeightMax("Gradient upper world height", Float) = 100
  _BandSoftness("Lambert band softness", Range(0.02,0.4)) = 0.16
  _AmbientStrength("SH ambient strength", Range(0,2)) = 0.75
  _HazeColor("Valley haze", Color) = (0.73,0.78,0.68,1)
  _FogDensity("Distance haze density", Range(0,0.02)) = 0.0018
  _FogStart("Clear near distance", Float) = 65
  _FogBaseHeight("Valley base height", Float) = 10
  _FogHeightFalloff("Haze height falloff", Range(0,0.1)) = 0.012
  _FogMax("Maximum haze", Range(0,1)) = 0.82
 }
 SubShader
 {
  Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
  HLSLINCLUDE
  #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
  #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
  TEXTURE2D(_Palette); SAMPLER(sampler_Palette);
  CBUFFER_START(UnityPerMaterial)
   float4 _Palette_ST;
   half4 _ShadowTint, _HeightLowTint, _HeightHighTint, _HazeColor, _SlopeTint;
   float _HeightMin, _HeightMax, _BandSoftness, _AmbientStrength, _SlopeThreshold;
   float _FogDensity, _FogStart, _FogBaseHeight, _FogHeightFalloff, _FogMax;
  CBUFFER_END
  struct Attributes { float4 positionOS:POSITION; float3 normalOS:NORMAL; float2 uv:TEXCOORD0; half4 color:COLOR; UNITY_VERTEX_INPUT_INSTANCE_ID };
  struct Varyings { float4 positionCS:SV_POSITION; float3 positionWS:TEXCOORD0; half3 normalWS:TEXCOORD1; float2 uv:TEXCOORD2; half4 color:TEXCOORD3; UNITY_VERTEX_INPUT_INSTANCE_ID UNITY_VERTEX_OUTPUT_STEREO };
  Varyings Vert(Attributes v)
  {
   Varyings o=(Varyings)0; UNITY_SETUP_INSTANCE_ID(v); UNITY_TRANSFER_INSTANCE_ID(v,o); UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
   VertexPositionInputs p=GetVertexPositionInputs(v.positionOS.xyz); o.positionCS=p.positionCS; o.positionWS=p.positionWS;
   o.normalWS=TransformObjectToWorldNormal(v.normalOS); o.uv=v.uv; o.color=v.color; return o;
  }
  ENDHLSL
  Pass
  {
   Name "PainterlyForward" Tags { "LightMode"="UniversalForward" }
   HLSLPROGRAM
   #pragma vertex Vert
   #pragma fragment Frag
   #pragma multi_compile_instancing
   #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
   #pragma multi_compile_fragment _ _SHADOWS_SOFT
   half4 Frag(Varyings i):SV_Target
   {
    UNITY_SETUP_INSTANCE_ID(i); UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
    half3 normal=normalize(i.normalWS);
    #if defined(_MAIN_LIGHT_SHADOWS_SCREEN)
     float4 shadowCoord=ComputeScreenPos(TransformWorldToHClip(i.positionWS));
    #else
     float4 shadowCoord=TransformWorldToShadowCoord(i.positionWS);
    #endif
    Light sun=GetMainLight(shadowCoord);
    half lambert=saturate(dot(normal,sun.direction));
    half band=0.42h+0.32h*smoothstep(0.26-_BandSoftness,0.26+_BandSoftness,lambert)+0.26h*smoothstep(0.7-_BandSoftness,0.7+_BandSoftness,lambert);
    half3 pigment=SAMPLE_TEXTURE2D(_Palette,sampler_Palette,i.uv).rgb*i.color.rgb;
    half height=saturate((i.positionWS.y-_HeightMin)/max(_HeightMax-_HeightMin,0.01));
    pigment*=lerp(half3(1,1,1),lerp(_HeightLowTint.rgb,_HeightHighTint.rgb,height),saturate(i.color.a));
    half steep=1-smoothstep(_SlopeThreshold-0.12,_SlopeThreshold+0.12,saturate(normal.y));
    pigment*=lerp(half3(1,1,1),_SlopeTint.rgb,steep*saturate(i.color.a));
    half shade=saturate(sun.shadowAttenuation*sun.distanceAttenuation);
    half3 paintedLight=lerp(_ShadowTint.rgb,half3(1,1,1),shade)*band;
    half3 ambient=max(SampleSH(normal),half3(0.12,0.12,0.12))*_AmbientStrength;
    half3 color=pigment*(paintedLight*sun.color*0.8h+ambient*0.45h);
    float distanceToCamera=distance(_WorldSpaceCameraPos,i.positionWS);
    float heightDensity=exp(-max(i.positionWS.y-_FogBaseHeight,0)*_FogHeightFalloff);
    half haze=min(_FogMax,1-exp(-max(distanceToCamera-_FogStart,0)*_FogDensity*heightDensity));
    return half4(lerp(color,_HazeColor.rgb,saturate(haze)),1);
   }
   ENDHLSL
  }
  Pass
  {
   Name "ShadowCaster" Tags { "LightMode"="ShadowCaster" } ZWrite On ZTest LEqual ColorMask 0 Cull Back
   HLSLPROGRAM
   #pragma vertex ShadowVert
   #pragma fragment EmptyFrag
   #pragma multi_compile_instancing
   #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
   float3 _LightDirection; float3 _LightPosition;
   float4 ShadowVert(Attributes v):SV_POSITION
   {
    UNITY_SETUP_INSTANCE_ID(v); float3 positionWS=TransformObjectToWorld(v.positionOS.xyz); float3 normalWS=TransformObjectToWorldNormal(v.normalOS);
    #if defined(_CASTING_PUNCTUAL_LIGHT_SHADOW)
     float3 direction=normalize(_LightPosition-positionWS);
    #else
     float3 direction=_LightDirection;
    #endif
    float4 positionCS=TransformWorldToHClip(ApplyShadowBias(positionWS,normalWS,direction));
    #if UNITY_REVERSED_Z
     positionCS.z=min(positionCS.z,UNITY_NEAR_CLIP_VALUE*positionCS.w);
    #else
     positionCS.z=max(positionCS.z,UNITY_NEAR_CLIP_VALUE*positionCS.w);
    #endif
    return positionCS;
   }
   half4 EmptyFrag():SV_Target { return 0; }
   ENDHLSL
  }
  Pass
  {
   Name "DepthOnly" Tags { "LightMode"="DepthOnly" } ZWrite On ColorMask 0
   HLSLPROGRAM
   #pragma vertex DepthVert
   #pragma fragment DepthFrag
   #pragma multi_compile_instancing
   float4 DepthVert(Attributes v):SV_POSITION { UNITY_SETUP_INSTANCE_ID(v); return TransformObjectToHClip(v.positionOS.xyz); }
   half4 DepthFrag():SV_Target { return 0; }
   ENDHLSL
  }
 }
 Fallback Off
}
