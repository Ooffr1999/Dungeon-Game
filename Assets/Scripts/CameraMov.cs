using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMov : MonoBehaviour
{
    public GameObject player;
    public float moveSpeed;

    private void Update()
    {
        transform.position = player.transform.position;
    }
}
