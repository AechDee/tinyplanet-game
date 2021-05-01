// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/Atmosphere" {
	Properties {
	}
	  
	Category {
		Tags { "Queue"="Transparent+99" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off Lighting Off ZWrite Off
		ZTest Always
	 	
		SubShader {
			Pass {
				CGPROGRAM
				#pragma target 3.0
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
				 
				inline float2 raySphere (
					float3 sphereCenter,
					float sphereRadius,
					float3 rayOrigin,
					float3 rayDir
				) {
					// offset is the cam position in local space of the sphere.
					float3 offset = rayOrigin - sphereCenter;
					float a = dot(rayDir, rayDir);
					float b = 2 * dot (offset, rayDir);
					float c = dot(offset, offset) - sphereRadius * sphereRadius;
					float d = b * b - 4 * a * c;
					
					if(d > 0) {
						float s = sqrt (d);
						// Distance to front of sphere (0 if inside sphere).
						// This is the distance from the camera where sampling should begin.
						float dstToSphereNear = max (0, (-b - s) / (2 * a));
						// Distance to back of sphere
						float dstToSphereFar = (-b + s) / (2 * a);
						
						if(dstToSphereFar >= 0){
							return float2(dstToSphereNear, dstToSphereFar - dstToSphereNear);
						}
					}
					return float2(0, 0);
				}
			
				
				
				
				
				
				sampler2D _MainTex;
				sampler2D _CameraDepthTexture;
				uniform float3 AtmosphereCenter;
				uniform float4 ParentTransform;
				uniform float numOpticalDepthPoints;
				uniform float numScatteringPoints;
				uniform float densityFalloff;
				uniform float PlanetRadius;
				uniform float3 dirToSun;
				uniform float AtmosphereRadius;
				const float epsilon = 0.0001;
				
				 
				 
				struct v2f {
					float4 pos : SV_POSITION;
					float3 view : TEXCOORD0;
					float4 projPos : TEXCOORD1;
				};
				 
				v2f vert (appdata_base v) {
					v2f o;
					float4 wPos = mul (unity_ObjectToWorld, v.vertex);
					o.pos = UnityObjectToClipPos (v.vertex);
					o.view = wPos.xyz - _WorldSpaceCameraPos;
					o.projPos = ComputeScreenPos (o.pos);
				 	
					// Move projected z to near plane if point is behind near plane.
					float inFrontOf = ( o.pos.z / o.pos.w ) > 0;
					o.pos.z *= inFrontOf;
					return o;
				}
				

				
				
				float densityAtPoint(float3 densitySamplePoint){
					float3 planetCenter = AtmosphereCenter;
					float heightAboveSurface = length(densitySamplePoint - planetCenter) - PlanetRadius;
					float height01 = heightAboveSurface / (AtmosphereRadius - PlanetRadius);
					float localDensity = exp(-height01 * densityFalloff) * (1-height01);
					return localDensity;
				}
				
				float opticalDepth(float3 rayOrigin, float3 rayDir, float rayLength){
					float3 densitySamplePoint = rayOrigin;
					float stepSize = rayLength / (numOpticalDepthPoints -1);
					float opticalDepth = 0;
					
					for(int i = 0; i<numOpticalDepthPoints; i++){
						float localDensity = densityAtPoint(densitySamplePoint);
						opticalDepth += localDensity * stepSize;
						densitySamplePoint += rayDir * stepSize;
					}
					return opticalDepth;
				}
				
				float calculateLight(float3 rayOrigin, float3 rayDir, float rayLength){
					float3 inScatterPoint = rayOrigin;
					float stepSize = rayLength / (numScatteringPoints -  1);
					float inScatteredLight = 0;
					
					for(int i=0; i < numScatteringPoints; i++ ){
					float3 planetCenter = AtmosphereCenter;
						float sunRayLength = raySphere(planetCenter, AtmosphereRadius, inScatterPoint, dirToSun).y;
						float sunRayOpticalDepth = opticalDepth(inScatterPoint, dirToSun, sunRayLength);
						float viewRayOpticalDepth = opticalDepth(inScatterPoint, -rayDir, stepSize * i);
						float transmittance = exp(-(sunRayOpticalDepth + viewRayOpticalDepth));
						float localDensity = densityAtPoint(inScatterPoint);
						
						inScatteredLight += localDensity * transmittance * stepSize;
						inScatterPoint += rayDir * stepSize;	
					}
					return inScatteredLight;
				}
				
				
				
				float4 frag (v2f i) : SV_Target {
					float4 originalColor = tex2D(_MainTex, i.view);
					float sceneDepthNonLinear = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.view);
					float sceneDepth = LinearEyeDepth(sceneDepthNonLinear) * length(i.view);
					float3 rayOrigin = _WorldSpaceCameraPos;
					float3 rayDir = normalize (i.view);
					
					
					// Calculate fog density.
					float2 hitInfo = raySphere (
						AtmosphereCenter,
						AtmosphereRadius,
						rayOrigin,
						rayDir);
					float dstToAtmosphere = hitInfo.x;
					float dstThruAtmosphere = min(hitInfo.y, sceneDepth - dstToAtmosphere);
					
					if(dstThruAtmosphere>0){
						float3 pointInAtmosphere = rayOrigin + rayDir * (dstToAtmosphere + epsilon);
						float light = -calculateLight(pointInAtmosphere, rayDir, (dstThruAtmosphere - epsilon * 2));
						return originalColor * (1-light) + light;
					}
					
					return originalColor;
				}
				ENDCG
			}
		}
	}
	Fallback "VertexLit"
}
