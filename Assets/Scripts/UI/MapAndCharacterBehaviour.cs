using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class MapAndCharacterBehaviour : MonoBehaviour
{
    public bool _mapOn;
    public bool _characterOn;

    [Header("Map Screen")]
    public bool _hasMap;
    public GameObject _mapScreen;
    public Image _mapTex;
    public TextMeshProUGUI _noMapTex;
    public Transform _player;

    [Header("Character Screen")]
    public GameObject _characterScreen;

    Camera _mainCam;
    Player_InputAction input;

    [HideInInspector]
    public static MapAndCharacterBehaviour _instance;

    private void Awake()
    {
        input = new Player_InputAction();

        if (_instance != null)
            Destroy(this);
        else _instance = this;
    }

    private void Start()
    {
        _mainCam = Camera.main;
    }

    private void FixedUpdate()
    {
        if (_hasMap)
            DrawLayout();
    }

    void DrawLayout()
    {
        SetMapTexture(LevelGen._instance.DrawLevelLayout(_player));
    }

    public void InitMap()
    {
        switch(_mapOn)
        {
            case false:
                _mapScreen.SetActive(true);

                if (!_characterOn)
                    _mainCam.rect = new Rect(0.5f, 0.2f, 1, 1);

                _mapOn = true;
                break;

            case true:
                _mapScreen.SetActive(false);

                if (!_characterOn)
                    _mainCam.rect = new Rect(0, 0.2f, 1, 1);

                _mapOn = false;
                break;
        }
    }

    public void InitChar()
    {
        switch(_characterOn)
        {
            case false:
                _characterScreen.SetActive(true);
                
                if (!_mapOn)
                    _mainCam.rect = new Rect(-0.5f, 0.2f, 1, 1);
                
                _characterOn = true;
                break;

            case true:
                _characterScreen.SetActive(false);

                if (!_mapOn)
                    _mainCam.rect = new Rect(0, 0.2f, 1, 1);

                _characterOn = false;
                break;
        }
    }

    public void SetMapTexture(Texture2D tex)
    {
        Sprite map = Sprite.Create(tex, new Rect(0, 0, tex.width, tex.height), new Vector2(tex.width / 2, tex.height / 2));
        _mapTex.color = Color.gray;
        _mapTex.sprite = map;
        _hasMap = true;
        _noMapTex.enabled = false;
    }

    public void ClearMapTexture()
    {
        _mapTex.sprite = null;
        _mapTex.color = Color.gray;
        _hasMap = false;
        _noMapTex.enabled = true;
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
