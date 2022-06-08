using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy_Crawler : EnemyController
{
    public int damage;
    public float timeBetweenAttacks;

    public override void Update()
    {
        if (canInterract)
        {
            agent.canMove = false;
            StartCoroutine(attack());
        }
        else agent.canMove = true;

        base.Update();
    }

    IEnumerator attack()
    {
        while(true)
        {
            yield return new WaitForSeconds(timeBetweenAttacks);

            if (canInterract)
                Player_Health._instance.LooseHealth(1);
            else yield break;
        }
    }
}
