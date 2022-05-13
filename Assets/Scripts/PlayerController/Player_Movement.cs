using System.Collections;
using System.Collections.Generic;
using UnityEngine;

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

    GameObject stairs;
    Camera cam;

    private void Start()
    {
        _staminaBar.InitBar((int)currentStamina, maxStamina);
        currentStamina = maxStamina;

        stairs = GameObject.FindGameObjectWithTag("Stairs");
        cam = Camera.main;
    }

    private void Update()
    {
        ApplyMovement();
        
        //Apply Gravity
        controller.Move(transform.up * -2);

        //Move on to next level
        if (Input.GetKeyDown(KeyCode.E))
            ProceedToNextLevel();
    }

    void ProceedToNextLevel()
    {
        if (Vector3.Distance(transform.position, stairs.transform.position) < 3)
            GameObject.Find("LevelGen").GetComponent<LevelGen>().MakeLevel();
    }

    void ApplyMovement()
    {
        //Get movement value from Input
        float move = Input.GetAxis("Walk") * _moveSpeed * Time.deltaTime;

        //Apply Running and appropriate stamina management
        if (Input.GetButton("Run") && currentStamina > 0)
        {
            move *= _runSpeedModifier;

            if (move != 0)
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
        if (move != 0)
            transform.eulerAngles = new Vector3(0, GetMouseAngle() - 45, 0);

        //Apply Movement
        if (_canMove)
            controller.Move(transform.forward * move);

        //Animations/////
        if (move > 0)
            _animController.SetBool("IsWalking", true);
        else _animController.SetBool("IsWalking", false);
    }

    float GetMouseAngle()
    {
        Vector2 screenCenter = new Vector2(Screen.width / 2, Screen.height / 2 + 80);

        Vector2 mousePos = (Vector2)Input.mousePosition - screenCenter;

        float angle = Mathf.Atan2(mousePos.x, mousePos.y) * Mathf.Rad2Deg;
        
        if (mousePos.x < 0)
        {
            float dif = Mathf.Abs(180 - Mathf.Abs(angle));
            angle = 180 + dif;
        }

        return angle;
    }
}
