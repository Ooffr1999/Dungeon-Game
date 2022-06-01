using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class Player_Level : MonoBehaviour
{
    public int currentLevel;
    public int currentPower;

    [Header("Stats")]
    public int _strengthLevel;
    public int _dexterityLevel;
    public int _magicLevel;
    public int _vitalityLevel;
    public int _staminaLevel;

    [Space(10)]
    public int _levelIncreaseModifier;

    [Header("Character screen UI")]
    public TextMeshProUGUI levelDisplay;
    public TextMeshProUGUI powerDisplay;

    [Space(10)]
    [SerializeField]
    TextMeshProUGUI strengthScoreDisplay;
    [SerializeField]
    TextMeshProUGUI dexterityScoreDisplay;
    [SerializeField]
    TextMeshProUGUI magicScoreDisplay;
    [SerializeField]
    TextMeshProUGUI vitalityScoreDisplay;
    [SerializeField]
    TextMeshProUGUI staminaLevelDisplay;

    private void Start()
    {
        SetUIScoreValues();
    }

    public void IncreaseLevels(int strength, int dexterity, int magic, int vitality, int stamina)
    {
        _strengthLevel += strength;
        _dexterityLevel += dexterity;
        _magicLevel += magic;
        _vitalityLevel += vitality;
        _staminaLevel += stamina;

        SetUIScoreValues();
    }

    public void IncreasePower(int power)
    {
        currentPower += power;
    }

    public void SetUIScoreValues()
    {
        levelDisplay.text = currentLevel.ToString();
        powerDisplay.text = currentPower.ToString();

        strengthScoreDisplay.text = _strengthLevel.ToString();
        dexterityScoreDisplay.text = _dexterityLevel.ToString();
        magicScoreDisplay.text = _magicLevel.ToString();
        vitalityScoreDisplay.text = _vitalityLevel.ToString();
        staminaLevelDisplay.text = _strengthLevel.ToString();
    }
}
