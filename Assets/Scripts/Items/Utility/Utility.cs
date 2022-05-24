using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Utility : MonoBehaviour
{
    public int _coolDownTime;
    public bool _canUseUtility;

    public virtual void OnAbilityEngage()
    {
        StartCoroutine(startCoolDown(_coolDownTime));
    }

    public virtual void OnCoolDownOver()
    {

    }

    IEnumerator startCoolDown(int coolDownTime)
    {
        _canUseUtility = false;

        yield return new WaitForSeconds(coolDownTime);

        _canUseUtility = true;
        OnCoolDownOver();
    }
}
