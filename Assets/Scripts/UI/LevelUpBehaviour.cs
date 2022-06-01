using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class LevelUpBehaviour : MonoBehaviour
{
    public TextMeshProUGUI playerLevelDisplay;
    public TextMeshProUGUI playerLevelUpPriceDisplay;
    public TextMeshProUGUI playerPowerDisplay;

    [Header("Strength UI")]
    public TextMeshProUGUI strengthDisplay;
    public Button lowerStrengthButton;
    public Button increaseStrengthButton;

    [Header("Dexterity UI")]
    public TextMeshProUGUI dexterityDisplay;
    public Button lowerDexButton;
    public Button increaseDexButton;

    [Header("Magic UI")]
    public TextMeshProUGUI magicDisplay;
    public Button lowerMagicButton;
    public Button increaseMagicButton;

    [Header("Vitality UI")]
    public TextMeshProUGUI vitalityDisplay;
    public Button lowerVitalityButton;
    public Button increaseVitalityButton;

    [Header("Stamina UI")]
    public TextMeshProUGUI staminaDisplay;
    public Button lowerStaminaButton;
    public Button increaseStaminaButton;

    [Space(10)]
    public Player_Level p_Level;

    //Level variables;
    int playerLevel;
    int playerPower;

    int playerStrength;
    int playerDexterity;
    int playerMagic;
    int playerVitality;
    int playerStamina;

    void GetLevelValues()
    {
        playerLevel = p_Level.currentLevel;
        playerPower = p_Level.currentPower;

        playerStrength = p_Level._strengthLevel;
        playerDexterity = p_Level._dexterityLevel;
        playerMagic = p_Level._magicLevel;
        playerVitality = p_Level._vitalityLevel;
        playerStamina = p_Level._staminaLevel;
    }

    void SetUI()
    {
        //Set player level and power
        playerLevelDisplay.text = playerLevel.ToString();
        playerLevelUpPriceDisplay.text = getLevelUpCost().ToString();
        playerPowerDisplay.text = "(" + playerPower.ToString() + ")";

        //Set strength
        strengthDisplay.text = playerStrength.ToString();

        if (playerStrength == p_Level._strengthLevel)
            lowerStrengthButton.interactable = false;
        else lowerStrengthButton.interactable = true;

        //Set dexterity
        dexterityDisplay.text = playerDexterity.ToString();

        if (playerDexterity == p_Level._dexterityLevel)
            lowerDexButton.interactable = false;
        else lowerDexButton.interactable = true;

        //Set Magic UI
        magicDisplay.text = playerMagic.ToString();

        if (playerMagic == p_Level._magicLevel)
            lowerMagicButton.interactable = false;
        else lowerMagicButton.interactable = true;

        //Set Vitality
        vitalityDisplay.text = playerVitality.ToString();

        if (playerVitality == p_Level._vitalityLevel)
            lowerVitalityButton.interactable = false;
        else lowerVitalityButton.interactable = true;

        //Set Stamina
        staminaDisplay.text = playerStamina.ToString();

        if (playerStamina == p_Level._staminaLevel)
            lowerStaminaButton.interactable = false;
        else lowerStaminaButton.interactable = true;
        
    }

    int getLevelUpCost()
    {
        return 30 * playerLevel;
    }

    public void SetPlayerNewStats()
    {
        p_Level.currentLevel = playerLevel;
        p_Level.currentPower = playerPower;

        p_Level._strengthLevel = playerStrength;
        p_Level._dexterityLevel = playerDexterity;
        p_Level._magicLevel = playerMagic;
        p_Level._vitalityLevel = playerVitality;
        p_Level._staminaLevel = playerStamina;

        p_Level.SetUIScoreValues();
    }

    public void IncrementValue(int statIndexToIncrease)
    {
        if (playerPower - getLevelUpCost() < 0)
            return;
        
        playerPower -= getLevelUpCost();
        playerLevel++;

        switch(statIndexToIncrease)
        {
            case 0:
                playerStrength++;
                break;
            case 1:
                playerDexterity++;
                break;
            case 2:
                playerMagic++;
                break;
            case 3:
                playerVitality++;
                break;
            case 4:
                playerStamina++;
                break;
        }
        

        SetUI();
    }

    public void DecreaseValue(int statIndexToDecrease)
    {
        if (playerLevel == p_Level.currentLevel)
            return;
        
        playerPower += getLevelUpCost() - 30;
        playerLevel--;
        
        switch (statIndexToDecrease)
        {
            case 0:
                playerStrength--;
                break;
            case 1:
                playerDexterity--;
                break;
            case 2:
                playerMagic--;
                break;
            case 3:
                playerVitality--;
                break;
            case 4:
                playerStamina--;
                break;
        }

        SetUI();
    }

    private void OnEnable()
    {
        GetLevelValues();
        SetUI();
    }
}
