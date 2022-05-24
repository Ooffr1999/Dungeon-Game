using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class Player_Interract : MonoBehaviour
{
    public Player_Movement p_Mov;
    public Player_Item_Management p_Items;

    Player_InputAction input;

    private void Awake()
    {
        input = new Player_InputAction();
        
        input.Player.Interract.started += ctx => GetPossibleInterractions();
    }

    #region Interractions
    void GetPossibleInterractions()
    {
        GetChests();
        p_Items.RetreiveItem();
        
        ClimbDownDungeon();

        OpenDoor();
    }

    void GetChests()
    {
        RaycastHit hit;

        if (Physics.Raycast(transform.position + Vector3.up, transform.forward, out hit, 1.5f))
        {
            if (hit.collider.CompareTag("Container"))
                hit.collider.gameObject.GetComponent<Container_Behaviour>().Open();
        }
    }

    void OpenDoor()
    {
        RaycastHit hit;

        if (Physics.Raycast(transform.position + Vector3.up, transform.forward, out hit, 1.5f))
        {
            if (hit.collider.CompareTag("Door"))
                hit.collider.gameObject.GetComponent<DoorBehaviour>().Open();
        }
    }

    void ClimbDownDungeon()
    {
        if (Vector2.Distance(transform.position, (Vector2)LevelGen._instance.getMapEndPos() * LevelGen._instance._sizeModifier) < 3)
            LevelGen._instance.MakeLevel();
    }
    #endregion

    private void OnEnable()
    {
        input.Player.Enable();
    }

    private void OnDisable()
    {
        input.Player.Disable();
    }
}
