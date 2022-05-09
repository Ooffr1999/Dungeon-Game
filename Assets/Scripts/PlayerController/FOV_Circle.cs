using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FOV_Circle : MonoBehaviour
{
    public int detail = 30;
    public float length = 5;

    private void Start()
    {
        CircleCast();
    }

    void CircleCast()
    {
        float angle = 0;

        for (int i = 0; i < detail; i++)
        {
            angle += 2 * Mathf.PI / detail;

            //
        }
    }
}
