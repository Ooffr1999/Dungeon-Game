using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Utility_MujaffaBoat : Utility
{
    public GameObject MujaffaBoat;
    public float MujaffaBoatLifeTime;

    GameObject player;

    private void OnEnable()
    {
        player = GameObject.Find("Player");
    }

    public override void OnAbilityEngage()
    {
        if (_canUseUtility)
        {
            GameObject newBoat = Instantiate(MujaffaBoat, transform.position, player.transform.rotation);
            Destroy(newBoat, MujaffaBoatLifeTime);
            transform.GetChild(0).gameObject.SetActive(false);
        }

        base.OnAbilityEngage();
    }

    public override void OnCoolDownOver()
    {
        base.OnCoolDownOver();
        transform.GetChild(0).gameObject.SetActive(true);
    }

    private void Update()
    {
        transform.localEulerAngles += Vector3.up * 100 * Time.deltaTime;
    }
}
