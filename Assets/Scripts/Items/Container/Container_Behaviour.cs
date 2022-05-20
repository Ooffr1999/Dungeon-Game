using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Container_Behaviour : MonoBehaviour
{
    public float openSpeed;
    public Transform lid;

    [Space(10)]
    public GameObject _dropItem;

    [HideInInspector]
    public bool isOpen = false;

    public void Open()
    {
        StartCoroutine(openLid());
    }

    IEnumerator openLid()
    {
        float time = 0;
        float lidX = 0;

        while(true)
        {
            time += Time.deltaTime * openSpeed;
            lidX = Mathf.Lerp(0, -113, time);
            lid.localEulerAngles = new Vector3(lidX, lid.transform.localEulerAngles.y, lid.transform.localEulerAngles.z);

            if (time >= 1)
                break;

            yield return new WaitForEndOfFrame();
        }

        if (_dropItem != null)
            DropItem();

        isOpen = true;

        StopCoroutine(openLid());
    }

    void DropItem()
    {
        Instantiate(_dropItem, transform.position + Vector3.right * LevelGen._instance._sizeModifier, transform.rotation);
    }
}
