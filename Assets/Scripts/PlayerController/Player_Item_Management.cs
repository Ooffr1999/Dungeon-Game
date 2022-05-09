using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Player_Item_Management : MonoBehaviour
{
    public float itemSearchRadius;
    public LayerMask itemLayer;

    [Space(10)]
    public Item _mainItem;
    public Item _secondaryItem;
    public Item _armorItem;
    public Item _utilityItem;

    [Space(10)]
    public GameObject itemHolder;

    [Space(5)]
    public GameObject _rightHand;
    public GameObject _leftHand;
    public GameObject _rightWeapon;
    public GameObject _leftWeapon;

    [SerializeField]
    GameObject _dropItemTemplate;

    GameObject itemSlot_Main;
    GameObject itemSlot_Secondary;
    GameObject itemSlot_Armor;
    GameObject itemSlot_Utility;

    private void Start()
    {
        //Get slots
        itemSlot_Main = itemHolder.transform.GetChild(0).gameObject;
        itemSlot_Secondary = itemHolder.transform.GetChild(1).gameObject;
        itemSlot_Armor = itemHolder.transform.GetChild(2).gameObject;
        itemSlot_Utility = itemHolder.transform.GetChild(3).gameObject;
    }

    private void Update()
    {
        RetreiveItem();

        if (Input.GetKeyDown(KeyCode.Q))
        {
            if (_mainItem != null)
                InitDropItem(0);
            else if (_secondaryItem != null)
                InitDropItem(1);

            UnequipHands();
        }   
    }

    void RetreiveItem()
    {
        if (Physics.CheckSphere(transform.position, itemSearchRadius, itemLayer))
        {
            //Find items and allow the closest one to be picked up
            if (Input.GetKeyDown(KeyCode.E))
            {
                GameObject[] itemsInRange = GameObject.FindGameObjectsWithTag("Items");

                GameObject itemToPickUp = null;

                for (int i = 0; i < itemsInRange.Length; i++)
                {

                    if (itemToPickUp == null)
                        itemToPickUp = itemsInRange[i].gameObject;
                    else
                    {
                        if (Vector3.Distance(transform.position, itemToPickUp.transform.position) >
                            Vector3.Distance(transform.position, itemsInRange[i].transform.position))
                            itemToPickUp = itemsInRange[i].gameObject;
                    }
                }

                ApplyItem(itemToPickUp.GetComponent<Pickup>());
                Destroy(itemToPickUp);
            }
        }
    }

    void ApplyItem(Pickup pickup)
    {
        //Put item in appropriate slot
        switch(pickup.item._ItemType)
        {
            case Item.itemType.Weapon:
            
                if (_mainItem == null)
                {
                    _mainItem = pickup.item;
                    SetIcon();
                    SetHands();
                }

                else if (_secondaryItem == null)
                {
                    _secondaryItem = pickup.item;
                    SetIcon();
                    SetHands();
                }

                else if (_mainItem != null && _secondaryItem != null)
                    Debug.Log("Full slots");
                //make a system for choosing and discarding items

                break;
            case Item.itemType.Armor:
                _armorItem = pickup.item;
                SetIcon();
                break;
        }
        
    }

    public void InitDropItem(int slot)
    {
        switch(slot)
        {
            case 0:
                //Drop main item
                DropItem(_mainItem);
                RemoveIcon(itemSlot_Main);
                _mainItem = null;
                break;

            case 1:
                //Drop secondary item
                DropItem(_secondaryItem);
                RemoveIcon(itemSlot_Secondary);
                _secondaryItem = null;
                break;

            case 2:
                //Drop Armor item
                break;

            case 3:
                //Drop Utility item
                break;
        }
    }

    void DropItem(Item item)
    {
        GameObject itemToDrop = _dropItemTemplate;

        itemToDrop.GetComponent<Pickup>().item = item;
        Instantiate(itemToDrop, transform.position, transform.rotation);
    }

    void SetIcon()
    {
        if (_mainItem != null)
            itemSlot_Main.transform.GetChild(0).GetComponent<Image>().sprite = _mainItem.icon;
        if (_secondaryItem != null)
            itemSlot_Secondary.transform.GetChild(0).GetComponent<Image>().sprite = _secondaryItem.icon;
        if (_armorItem != null)
            itemSlot_Armor.transform.GetChild(0).GetComponent<Image>().sprite = _armorItem.icon;
        if (_utilityItem != null)
            itemSlot_Utility.transform.GetChild(0).GetComponent<Image>().sprite = _utilityItem.icon;

    }

    void RemoveIcon(GameObject itemSlot)
    {
        Image armor_icon = itemSlot.transform.GetChild(0).GetComponent<Image>();
        armor_icon.sprite = null;
    }

    void SetHands()
    {
        if (_mainItem != null)
        {
            _rightWeapon.GetComponent<MeshFilter>().mesh = _mainItem.model;
            _rightWeapon.GetComponent<MeshRenderer>().material = _mainItem.model_Material;
        }
        if (_secondaryItem != null)
        {
            _leftWeapon.GetComponent<MeshFilter>().mesh = _secondaryItem.model;
            _leftWeapon.GetComponent<MeshRenderer>().material = _secondaryItem.model_Material;
        }
    }

    void UnequipHands()
    {
        if (_mainItem == null)
        {
            _rightWeapon.GetComponent<MeshFilter>().mesh = null;
            _rightWeapon.GetComponent<MeshRenderer>().material = null;
        }

        if (_secondaryItem == null)
        {
            _leftWeapon.GetComponent<MeshFilter>().mesh = null;
            _leftWeapon.GetComponent<MeshRenderer>().material = null;
        }
    }
}
