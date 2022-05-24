using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DoorBehaviour : MonoBehaviour
{
    public float rotSpeed;
    Vector3 rotation;

    private void Start()
    {
        rotation = transform.eulerAngles;
    }

    public void Open()
    {
        StartCoroutine(InvokeDoor());
    }

    IEnumerator InvokeDoor()
    {
        float time = 0;
        Vector3 endRotation = rotation + Vector3.up * 90;

        GetComponent<Collider>().isTrigger = true;

        while(true)
        {
            transform.eulerAngles = Vector3.Lerp(rotation, endRotation, time);
            
            time += Time.deltaTime * rotSpeed;

            yield return new WaitForEndOfFrame();

            if (time > 1)
                break;
        }

        Destroy(this);
    }
}
