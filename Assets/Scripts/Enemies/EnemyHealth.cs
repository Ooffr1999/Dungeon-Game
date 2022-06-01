using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyHealth : MonoBehaviour
{
    public int maxHealth;

    [Space(5)]
    public int powerReward;

    [HideInInspector]
    public int currentHealth;

    [Space(10)]
    public GameObject healthBarObject;

    Camera mainCam;
    Player_HealthBar healthBar;

    private void Start()
    {
        healthBar = GetComponent<Player_HealthBar>();
        healthBar.InitBar(maxHealth, maxHealth);

        currentHealth = maxHealth;

        mainCam = Camera.main;
    }

    private void FixedUpdate()
    {
        healthBarObject.transform.LookAt(mainCam.transform.position);
    }

    public void AddHealth(int healthToAdd)
    {
        currentHealth += healthToAdd;

        if (currentHealth > maxHealth)
            currentHealth = maxHealth;

        healthBar.UpdateBothBars(currentHealth);
    }

    public void RemoveHealth(int healthToRemove)
    {
        currentHealth -= healthToRemove;

        if (currentHealth <= 0)
            OnDeath();

        healthBar.UpdateBothBars(currentHealth);
    }

    public virtual void OnDeath()
    {
        currentHealth = maxHealth;
        healthBar.UpdateBothBars(currentHealth);
        this.gameObject.SetActive(false);

        RewardPlayer();
    }

    public void RewardPlayer()
    {
        GameObject.Find("Player").GetComponent<Player_Level>().IncreasePower(powerReward);
    }
}
