using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Map_Container_Behaviour : MonoBehaviour
{
    public float openSpeed;
    public Transform lid;

    [HideInInspector]
    bool isOpen = false;

    public void Open()
    {
        if (isOpen)
            return;

        StartCoroutine(openLid());
    }

    IEnumerator openLid()
    {
        float time = 0;
        float lidX = 0;

        while (true)
        {
            time += Time.deltaTime * openSpeed;
            lidX = Mathf.Lerp(0, -113, time);
            lid.localEulerAngles = new Vector3(lidX, lid.transform.localEulerAngles.y, lid.transform.localEulerAngles.z);

            if (time >= 1)
                break;

            yield return new WaitForEndOfFrame();
        }

        MapAndCharacterBehaviour._instance._hasMap = true;

        isOpen = true;

        StopCoroutine(openLid());
    }

    public void ResetContainer()
    {
        lid.transform.localEulerAngles = Vector3.zero;
        isOpen = false;
    }
}
