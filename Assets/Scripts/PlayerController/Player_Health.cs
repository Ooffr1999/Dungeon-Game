using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player_Health : MonoBehaviour
{
    public int maxHealth;
    [HideInInspector]
    public int currentHealth;

    [Header("Animations")]
    public Animator _animController;

    [HideInInspector]
    public static Player_Health _instance;

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
            OnDeath();
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

    void OnDeath()
    {
        StartCoroutine(OnDeathEnum());
    }

    IEnumerator OnDeathEnum()
    {
        _animController.Play("Player_Anim_Die_1");
        GetComponent<Player_Movement>().enabled = false;

        yield return new WaitForSeconds(5);
    }
}
