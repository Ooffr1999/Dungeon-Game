using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Random_Wandering_Enemy : EnemyController
{
    public float attackDistance;

    public GameObject player;

    private IEnumerator Start()
    {
        yield return new WaitForSeconds(5);

        Move(getMapPos(), getMapPos(player.transform.position));
    }

    private void Update()
    {
        if (Vector3.Distance(transform.position, player.transform.position) < attackDistance)
        {
            if (isMoving)
            {
                Stop();
                StartCoroutine(attack());
            }

            Player_Health._instance.LooseHealth(1);
        }

        else Move(getMapPos(), getMapPos(player.transform.position));
        
    }

    /*
    public override void OnReachDestination()
    {
        Move(getMapPos(), getMapPos(player.transform.position));
    }
    */

    Vector2Int GetRandomDestination()
    {
        while(true)
        {
            int x = Mathf.RoundToInt(Random.Range(0, _levelGenerator.getMap().GetLength(0)));
            int y = Mathf.RoundToInt(Random.Range(0, _levelGenerator.getMap().GetLength(1)));

            if (_levelGenerator.getMap()[x, y] == '.')
                return new Vector2Int(x, y);
        }
    }

    IEnumerator attack()
    {
        while(true)
        { 
            yield return new WaitForSeconds(0.5f);

            Player_Health._instance.LooseHealth(1);
        }
}
}
