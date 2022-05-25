using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class Player_Movement : MonoBehaviour
{
    public float _moveSpeed;
    public float _onAttackMoveSpeed;
    public float _dashSpeed;
    public int _dashStaminaCost;

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

        input.Player.Dash.started += ctx => Dash();

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

    private void ApplyMovement()
    {
        float step;

        if (!_animController.GetBool("IsAttacking"))
            step = _move * _moveSpeed * Time.deltaTime;
        else step = _move * _onAttackMoveSpeed * Time.deltaTime;
        
        if (currentStamina <= maxStamina)
        {
            currentStamina += Time.deltaTime * staminaGainModifier;
            _staminaBar.UpdateBothBars((int)currentStamina);
        }

        //Rotate after mouse
        if (step != 0 && _canMove)
            transform.eulerAngles = new Vector3(0, GetMouseAngle() - 45, 0);

        //Apply Movement
        if (_canMove)
            controller.Move(transform.forward * step);

        //Animations/////
        if (step > 0)
            _animController.SetBool("IsRunning", true);
        else _animController.SetBool("IsRunning", false);

        //Set Player Blend tree correctly
        _animController.SetFloat("Momentum", Mathf.Lerp(0, 0.5f, controller.velocity.magnitude));
    }

    void Dash()
    {
        if (currentStamina < _dashStaminaCost)
            return;

        currentStamina -= _dashStaminaCost;
        _staminaBar.UpdateBothBars((int)currentStamina);

        StartCoroutine(DashRoutine());
    }

    IEnumerator DashRoutine()
    {
        float time = 0;
        _canMove = false;
        _animController.SetBool("IsDashing", true);

        while(true)
        {
            if (time >= 0.15)
                break;

            time += Time.deltaTime;
            controller.Move(transform.forward * _dashSpeed * Time.deltaTime);

            yield return new WaitForEndOfFrame();
        }

        _animController.SetBool("IsDashing", false);
        _canMove = true;
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

    private void OnTriggerStay(Collider other)
    {
        if (!other.CompareTag("Door"))
            return;

        if (!_animController.GetBool("IsDashing"))
            return;

        other.gameObject.SetActive(false);
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
