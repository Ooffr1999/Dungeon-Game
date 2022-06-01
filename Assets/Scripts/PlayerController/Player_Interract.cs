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
        p_Items.RetreiveItem();
        
        RaycastHit hit;

        if (Physics.Raycast(transform.position + Vector3.up, transform.forward, out hit, 1.5f))
        {
            switch(hit.collider.tag)
            {
                case "Container":
                    GetChests(hit);
                    break;

                case "Door":
                    OpenDoor(hit);
                    break;

                case "Stairs":
                    ClimbDownDungeon(hit);
                    break;

                case "MapChest":
                    GetMapChest(hit);
                    break;
            }
        }
    }

    void GetChests(RaycastHit hit)
    {
        hit.collider.gameObject.GetComponent<Container_Behaviour>().Open();
    }

    void GetMapChest(RaycastHit hit)
    {
        Debug.Log("Open map chest");
        hit.collider.gameObject.GetComponent<Map_Container_Behaviour>().Open();
    }

    void OpenDoor(RaycastHit hit)
    {
        hit.collider.gameObject.GetComponent<DoorBehaviour>().Open();
    }

    void ClimbDownDungeon(RaycastHit hit)
    {
        p_Items.OpenLevelUpMenu();
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
