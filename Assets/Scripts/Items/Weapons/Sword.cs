using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Sword : Weapon
{
    public override void OnAttackEngage()
    {
        Debug.Log("Starting attack");
    }
}
