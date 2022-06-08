using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class PauseBehaviour : MonoBehaviour
{
    public bool _canPause = true;
    public bool _isPaused = false;

    [Space(10)]
    public GameObject _pauseScreenParent;

    Player_InputAction input;

    void Awake()
    {
        input = new Player_InputAction();

        input.Pause.PauseandUnpause.performed += ctx => OnPause();
        input.Pause.Reset.performed += ctx => Reset();
    }

    void OnPause()
    {
        Debug.Log("Pause game");

        if (!_canPause)
            return;

        switch(_isPaused)
        {
            case false:
                Time.timeScale = 0;
                _pauseScreenParent.SetActive(true);
                _isPaused = true;
                break;

            case true:
                Time.timeScale = 1;
                _pauseScreenParent.SetActive(false);
                _isPaused = false;
                break;
        }
    }

    private void Reset()
    {
        SceneManager.LoadScene(0);
    }

    private void OnEnable()
    {
        input.Pause.Enable();
    }

    private void OnDisable()
    {
        input.Pause.Disable();
    }
}
