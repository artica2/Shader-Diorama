using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// A script to make the light in the fire move a little bit
public class LightMovement : MonoBehaviour
{
    [SerializeField]
    private float movementSpeed = 0.5f;
    [SerializeField]
    private float moveUnits = 0.3f;

    private Vector3 offset;

    private void Awake()
    {
        offset = transform.localPosition;
    }

    private void Update()
    {
        float moveValue = Mathf.Sin(Time.time * movementSpeed) * moveUnits;
        transform.localPosition = new Vector3(moveValue, moveValue / 2, 0) + offset;
    }
}
