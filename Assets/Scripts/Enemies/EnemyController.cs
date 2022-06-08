using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Pathfinding;

public class EnemyController : MonoBehaviour
{
    public float _moveSpeed;
    public Transform target;

    [Space(10)]
    public float activateDistance;

    [Space(10)]
    public float stopPursuitDistance;

    [Space(10)]
    public float interractDistance;

    [HideInInspector]
    public AIPath agent;
    //[HideInInspector]
    public bool canInterract;

    private void Start()
    {
        agent = GetComponent<AIPath>();
        agent.maxSpeed = _moveSpeed;
    }

    public virtual void Update()
    {
        if (agent.canMove)
            agent.destination = target.position;

        //Activate
        if (activateDistance > 0)
        {
            if (!agent.canMove)
            {
                if (Vector3.Distance(transform.position, target.position) <= activateDistance &&
                    Vector3.Distance(transform.position, target.position) >= interractDistance)
                    agent.canMove = true;
            }
        }

        //Interraction distance
        if (interractDistance > 0)
        {
            if (Vector3.Distance(transform.position, target.position) <= interractDistance)
            {
                canInterract = true;
            }
            else canInterract = false;
        }

        //Stop pursuit
        if (stopPursuitDistance > 0)
        {
            if (agent.canMove)
            {
                if (Vector3.Distance(transform.position, target.position) > activateDistance)
                    agent.canMove = false;
            }
        }
    }

    public void Move()
    {
        agent.canMove = true;
    }
    public void Stop()
    {
        agent.canMove = false;
    }

    private void OnDrawGizmosSelected()
    {
        if (activateDistance > 0)
        {
            Gizmos.color = Color.green;
            Gizmos.DrawWireSphere(transform.position, activateDistance);
        }

        if (interractDistance > 0)
        {
            Gizmos.color = Color.blue;
            Gizmos.DrawWireSphere(transform.position, interractDistance);
        }

        if (stopPursuitDistance > 0)
        {
            Gizmos.color = Color.red;
            Gizmos.DrawWireSphere(transform.position, stopPursuitDistance);
        }
    }
}