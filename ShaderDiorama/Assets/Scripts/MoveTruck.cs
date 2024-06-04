using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveTruck : MonoBehaviour
{
    public Vector3 StartPos;
    public Vector3 EndPos;
    public float MoveSpeed;

    public Vector3 HidePos;

    public GameObject MoveObject;

    private bool isMoving;

    private float startTime, endTime, travelTime, distance;
    private Vector3 travelDirection;
    // Start is called before the first frame update
    void Start()
    {
        MoveObject.transform.position = HidePos;
    }

    // Update is called once per frame
    void Update()
    {
        // Start moving if the sequence isnt already taking place
        if (Input.GetKeyDown(KeyCode.J) && !isMoving)
        {
            StartMoving();
        }

        // if we should keep moving
        if (isMoving && endTime > Time.time)
        {
            float frameMovement = MoveSpeed * Time.deltaTime;
            MoveObject.transform.position += travelDirection * frameMovement;
        } else if (endTime < Time.time) // if we should stop moving
        {
            isMoving = false;
            MoveObject.transform.position = HidePos;
        }
    }

    void StartMoving()
    {
        isMoving = true;
        MoveObject.transform.position = StartPos;

        // work out the travel time
        startTime = Time.time;
        distance = (EndPos - StartPos).magnitude; // work out distance
        travelTime = distance / MoveSpeed; // speed distance time triangle
        endTime = startTime + travelTime; // work out when the sequence will end

        travelDirection = (EndPos - StartPos).normalized; // direction
    }

}
