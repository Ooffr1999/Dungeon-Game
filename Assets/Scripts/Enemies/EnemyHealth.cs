using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyHealth : MonoBehaviour
{
    public int maxHealth;

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
            Destroy(this.gameObject);

        healthBar.UpdateBothBars(currentHealth);
    }
}
