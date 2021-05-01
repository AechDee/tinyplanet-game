using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
	public CharacterController controller;
	private Vector3 Momentum;
	private Vector3 inputMove;
	public float controlMultiplier = 4;
	public float jumpForce = 10;
	public Collider collider;
	// Start is called before the first frame update
	void Start()
	{
		controller = GetComponent<CharacterController>();
		collider = GetComponent<CapsuleCollider>();
		}
		// Update is called once per frame
		void Update()
		{
			inputMove = new Vector3(Input.GetAxis("Horizontal"), -1f, Input.GetAxis("Vertical"));
			if (Input.GetButtonDown("Jump"))
			{
				inputMove.y = jumpForce;
				}
				//inputMove = inputMove * controlMultiplier;
				Momentum = (Momentum + inputMove);
				controller.Move(Momentum * Time.deltaTime);
    }
}
