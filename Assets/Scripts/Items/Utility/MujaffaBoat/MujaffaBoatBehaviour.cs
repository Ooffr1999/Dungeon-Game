using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MujaffaBoatBehaviour : MonoBehaviour
{
    public int _onHitDamage;
    public float _moveSpeed;

    private void Update()
    {
        transform.position += transform.forward * _moveSpeed * Time.deltaTime;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (!other.CompareTag("Enemy"))
            return;

        other.gameObject.GetComponent<EnemyHealth>().RemoveHealth(_onHitDamage);
    }
}
