using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CircularWalk : MonoBehaviour
{
    [SerializeField]
    private float radius;
    [SerializeField]
    private float speed;

    [SerializeField]
    private Vector3 center;

    // Start is called before the first frame update
    void Start()
    {
        center = transform.position;
    }

    // Update is called once per frame
    void Update()
    {
        float angle = Time.time * speed;
        float x = center.x + radius * Mathf.Cos(angle);
        float z = center.z + radius * Mathf.Sin(angle);

        transform.position = new Vector3(x, transform.position.y, z);
    }
}
