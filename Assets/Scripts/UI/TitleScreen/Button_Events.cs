using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Button_Events : MonoBehaviour
{
    public int sceneStartLeadsTo;

    public void OnStartButtonClick()
    {
        SceneManager.LoadSceneAsync(sceneStartLeadsTo);
    }

    public void OnQuitButtonClick()
    {
        Application.Quit();
    }

    public void OnButtonHover()
    {
        Debug.Log("Play a click sound");
    }
}
