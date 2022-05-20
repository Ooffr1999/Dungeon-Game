using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Weapon : MonoBehaviour
{
    public bool _isMainWeapon;

    public float _damage;
    public float _attackSpeed;

    public enum WeaponType { sword, axe, club, magic}
    public WeaponType _weaponType;

    [HideInInspector]
    public Animator _anim;

    [HideInInspector]
    public bool _canDamage;

    private void Start()
    {
        GameObject.Find("Player").GetComponent<Animator>();
    }

    public void Attack()
    {
        if (_canDamage)
            return;

        switch(_weaponType)
        {
            case WeaponType.sword:

                if (_isMainWeapon)
                    _anim.Play("Player_Anim_Right_Weapon");
                else _anim.Play("Player_Anim_Left_Weapon");
                break;
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Enemy") && _canDamage == true)
        {
            OnAttackHit();
            Destroy(other.gameObject);
            print("Dealt " + _damage + " damage");
        }
    }

    public virtual void OnAttackEngage()
    {

    }

    public virtual void OnAttackHit()
    {

    }

    public virtual void OnAttackOver()
    {

    }
}