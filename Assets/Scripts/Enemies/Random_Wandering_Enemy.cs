using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Random_Wandering_Enemy : EnemyController
{
    public float attackDistance;

    public GameObject player;

    private void Start()
    {
        Move(getMapPos(), getMapPos(player.transform.position));
    }

    private void FixedUpdate()
    {
        //UpdatePath(transform.position, player.transform.position);
    }

    public override void OnReachDestination()
    {
        
    }
    

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
