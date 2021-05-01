using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SunRotation : MonoBehaviour
{
	public float savedTimeOffset = 0;
	//public int solarPeriod = 30;
	private float currentSolarTime;
	private float sunRot;
	
	
    // Start is called before the first frame update
    void Start()
    {
      //load the time offset here
			//private int sunRot = solarPeriod *60;
		}

    // Update is called once per frame
    void Update()
    {
			currentSolarTime = savedTimeOffset + Time.realtimeSinceStartup; //realtime in seconds
			sunRot = (currentSolarTime*5); //sunPeriod; 
      transform.localRotation = Quaternion.Euler(0,sunRot,0);
    }
}
