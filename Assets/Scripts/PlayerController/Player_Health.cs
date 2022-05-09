using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player_Health : MonoBehaviour
{
    public int maxHealth;
    [HideInInspector]
    public int currentHealth;

    [HideInInspector]
    public Player_Health _instance;

    [SerializeField]
    Player_HealthBar _healthBar;

    public void Awake()
    {
        //Init singleton
        if (_instance != null)
            Destroy(this);
        else _instance = this;
    }

    private void Start()
    {
        currentHealth = maxHealth;

        _healthBar = GetComponent<Player_HealthBar>();
        _healthBar.InitBar(currentHealth, maxHealth);
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.K))
            GetHealth(10);
        else if (Input.GetKeyDown(KeyCode.J))
            LooseHealth(10);

        else if (Input.GetKeyDown(KeyCode.I))
            UpdateHealthByPercentage(50);
    }

    public void GetHealth(int healthReceived)
    {
        //Add health received
        currentHealth += healthReceived;

        if (currentHealth > maxHealth)
            currentHealth = maxHealth;
        //Play some "OO, you regained health" effect
        //Update health bar
        _healthBar.UpdateFrontBar(currentHealth);
        _healthBar.UpdateBackBar(currentHealth);
    }

    public void LooseHealth(int healthLost)
    {
        //Remove health lost
        currentHealth -= healthLost;
        //Play a "O shit, you dyin" thingymagig
        //Update health bar
        _healthBar.UpdateFrontBar(currentHealth);
        _healthBar.UpdateBackBar(currentHealth);

        //If health to low, die :(
        if (currentHealth <= 0)
        {
            currentHealth = 0;
            //You ded
        }    
    }

    public void UpdateHealthByPercentage(float percentage)
    {
        float p = percentage / 100;

        float v = 1 + p;

        currentHealth = Mathf.FloorToInt(currentHealth * v);
        maxHealth = Mathf.FloorToInt(maxHealth * v);

        _healthBar.InitBar(currentHealth, maxHealth);
    }
}
