using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoonMove : MonoBehaviour
{

	public float rotSpeed = 1.0f;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
		this.transform.Rotate(new Vector3(0,Time.deltaTime * rotSpeed,0));
    }
}
