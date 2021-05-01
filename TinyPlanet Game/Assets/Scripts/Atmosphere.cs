using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class Atmosphere : MonoBehaviour
{
	protected MeshRenderer AtmosphereObject;
	public Material AtmosphereMaterial;

	void OnEnable ()
	{
		AtmosphereObject = gameObject.GetComponent<MeshRenderer>();
		if (AtmosphereObject == null)
			Debug.LogError("Volume Fog Object must have a MeshRenderer Component!");
		
		//Note: In forward lightning path, the depth texture is not automatically generated.
		Camera.main.depthTextureMode = DepthTextureMode.Depth;
		
		AtmosphereObject.material = AtmosphereMaterial;
		
	}
 
 				public float densityFalloff = 5;
				public float atmosphereScale = 101;

	void Update ()
	{
		int numOpticalDepthPoints = 20;
		int numScatteringPoints = 20;
		
		float radius = (transform.lossyScale.x + transform.lossyScale.y + transform.lossyScale.z) / 6;
		float planetRadius = (radius/((transform.localScale.x + transform.localScale.y + transform.localScale.z)/6));
		Vector3 dirToSun = (transform.position - GameObject.FindGameObjectWithTag("Sun").transform.position).normalized;
		float atmosphereHeight = ((atmosphereScale/100) * radius);
		
		
		
		Material mat = Application.isPlaying ? AtmosphereObject.material : AtmosphereObject.sharedMaterial;
		if (mat){
			mat.SetVector ("AtmosphereCenter", new Vector3(transform.position.x, transform.position.y, transform.position.z));
			mat.SetFloat ("PlanetRadius", planetRadius);
			mat.SetFloat ("numOpticalDepthPoints",numOpticalDepthPoints);
			mat.SetFloat ("numScatteringPoints",numScatteringPoints);
			mat.SetFloat ("densityFalloff",densityFalloff);
			mat.SetFloat ("AtmosphereRadius",atmosphereHeight);
			mat.SetVector ("dirToSun", dirToSun);
			}
	}
}
