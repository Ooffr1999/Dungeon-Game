using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class Player_Movement : MonoBehaviour
{
    public float _moveSpeed;
    public float _runSpeedModifier;

    [Space(5)]
    public bool _canMove;

    [Space(10)]
    public int maxStamina;
    float currentStamina;
    public float staminaGainModifier;
    public float staminaDrainRateModifier;

    [Header("Animations")]
    public Animator _animController;

    [Space(10)]
    public CharacterController controller;
    [SerializeField]
    Player_HealthBar _staminaBar;

    Camera cam;

    float _move;
    bool _run;
    Vector2 _cursorPos;
    
    Player_InputAction input;

    private void Awake()
    {
        input = new Player_InputAction();

        input.Player.Move.started += ctx => _move = 1;
        input.Player.Move.canceled += ctx => _move = 0;

        input.Player.Run.started += ctx => _run = true;
        input.Player.Run.canceled += ctx => _run = false;

        input.Player.Look.performed += ctx => _cursorPos = ctx.ReadValue<Vector2>();
    }

    private void Start()
    {
        _staminaBar.InitBar((int)currentStamina, maxStamina);
        currentStamina = maxStamina;

        cam = Camera.main;
    }

    private void Update()
    {
        ApplyMovement();

        //Apply Gravity
        controller.Move(transform.up * -2);
    }
    public void ReversePlayerMove ()
    {
        _canMove = !_canMove;
    }
    private void ApplyMovement()
    {
        float step = _move * _moveSpeed * Time.deltaTime;
        
        //Apply Running and appropriate stamina management
        if (_run && currentStamina > 0)
        {
            step *= _runSpeedModifier;

            if (step != 0)
            {
                currentStamina -= Time.deltaTime * staminaDrainRateModifier;
                _staminaBar.UpdateFrontBar((int)currentStamina);
                _staminaBar.UpdateBackBar((int)currentStamina);
                _animController.SetBool("IsRunning", true);
            }

            else if (currentStamina <= maxStamina)
            {
                currentStamina += Time.deltaTime * staminaGainModifier;
                _staminaBar.UpdateFrontBar((int)currentStamina);
                _staminaBar.UpdateBackBar((int)currentStamina);
                _animController.SetBool("IsRunning", false);
            }
        }
        else if (currentStamina <= maxStamina)
        {
            currentStamina += Time.deltaTime * staminaGainModifier;
            _staminaBar.UpdateFrontBar((int)currentStamina);
            _staminaBar.UpdateBackBar((int)currentStamina);
            _animController.SetBool("IsRunning", false);
        }

        //Rotate after mouse
        if (step != 0)
            transform.eulerAngles = new Vector3(0, GetMouseAngle() - 45, 0);

        //Apply Movement
        if (_canMove)
            controller.Move(transform.forward * step);

        //Animations/////
        if (step > 0)
            _animController.SetBool("IsWalking", true);
        else _animController.SetBool("IsWalking", false);
    }

    float GetMouseAngle()
    {
        Vector2 screenCenter = new Vector2(Screen.width / 2, Screen.height / 2 + 80);

        Vector2 mousePos = _cursorPos - screenCenter;

        float angle = Mathf.Atan2(mousePos.x, mousePos.y) * Mathf.Rad2Deg;
        
        if (mousePos.x < 0)
        {
            float dif = Mathf.Abs(180 - Mathf.Abs(angle));
            angle = 180 + dif;
        }

        return angle;
    }
    
    void EnableMovement()
    {
        _canMove = true;
    }

    void DisableMovement()
    {
        _canMove = false;
    }

    private void OnEnable()
    {
        input.Player.Enable();
    }

    private void OnDisable()
    {
        input.Player.Disable();
    }
}
