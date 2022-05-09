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

        Cursor.lockState = CursorLockMode.Locked;
    }

    private void Update()
    {
        float moveX = Input.GetAxisRaw("Horizontal") * _moveSpeed * Time.deltaTime;
        float moveZ = Input.GetAxisRaw("Vertical") * _moveSpeed * Time.deltaTime;

        //Apply Running and appropriate stamina management
        if (Input.GetKey(KeyCode.LeftShift) && currentStamina > 0)
        {
            moveX *= _runSpeedModifier;
            moveZ *= _runSpeedModifier;

            if (moveX != 0 || moveZ != 0)
            {
                currentStamina -= Time.deltaTime * staminaDrainRateModifier;
                _staminaBar.UpdateFrontBar((int)currentStamina);
                _staminaBar.UpdateBackBar((int)currentStamina);
            }

            else if (currentStamina <= maxStamina)
            {
                currentStamina += Time.deltaTime * staminaGainModifier;
                _staminaBar.UpdateFrontBar((int)currentStamina);
                _staminaBar.UpdateBackBar((int)currentStamina);
            }
        }
        else if (currentStamina <= maxStamina)
        {
            currentStamina += Time.deltaTime * staminaGainModifier;
            _staminaBar.UpdateFrontBar((int)currentStamina);
            _staminaBar.UpdateBackBar((int)currentStamina);
        }

        transform.eulerAngles += Vector3.up * Input.GetAxis("Mouse X");

        if (Input.GetKeyDown(KeyCode.E))
            ProceedToNextLevel();

        if (_canMove)
            controller.Move(transform.forward * moveZ + transform.right * moveX);
    }

    void ProceedToNextLevel()
    {
        if (Vector3.Distance(transform.position, stairs.transform.position) < 3)
            GameObject.Find("LevelGen").GetComponent<LevelGen>().MakeLevel();
    }
}
