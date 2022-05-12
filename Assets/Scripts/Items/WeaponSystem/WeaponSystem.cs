using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WeaponSystem : MonoBehaviour
{
    public void ApplyEffect(int index)
    {
        switch (index)
        {
            case 1:
                AngryText();
                break;

            case 2:
                MakeCube();
                break;

            default:
                Debug.Log("No effect took place");
                break;
        }
    }

    public void AngryText()
    {
        Debug.Log("Hurt the enemy");
    }

    public void MakeCube()
    {
        Instantiate(GameObject.CreatePrimitive(PrimitiveType.Cube), transform.position, transform.rotation);
    }
}
