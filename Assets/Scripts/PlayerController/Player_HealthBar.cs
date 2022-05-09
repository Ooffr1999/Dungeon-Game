using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Player_HealthBar : MonoBehaviour
{
    public Slider front_Bar;
    public Slider back_Bar;

    int _maxValue;

    public void InitBar(int currentValue, int maxValue)
    {
        _maxValue = maxValue;

        front_Bar.maxValue = _maxValue;
        back_Bar.maxValue = _maxValue;

        front_Bar.value = currentValue;
        back_Bar.value = currentValue;
    }

    public void UpdateFrontBar(int currentValue)
    {
        front_Bar.value = currentValue;
    }

    public void UpdateBackBar(int currentValue)
    {
        if (currentValue >= back_Bar.value)
            back_Bar.value = currentValue;

        else if (currentValue < back_Bar.value)
            StartCoroutine(ReduceBackBar(currentValue, 2));
    }

    IEnumerator ReduceBackBar(int currentValue, float speedModifier)
    {
        float timeValue = 0;
        float startBackBarValue = back_Bar.value;

        while(true)
        {
            back_Bar.value = Mathf.Lerp(startBackBarValue, currentValue, timeValue);

            timeValue += Time.deltaTime * speedModifier;

            if (back_Bar.value == currentValue)
                break;

            yield return new WaitForEndOfFrame();
        }
    }
}
