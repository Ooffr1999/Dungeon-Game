using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Player_Item_Management : MonoBehaviour
{
    public float itemSearchRadius;
    public LayerMask itemLayer;

    [Space(10)]
    public GameObject _mainItem;
    public GameObject _secondaryItem;
    public Item _armorItem;
    public Item _utilityItem;

    [Space(10)]
    public Weapon _mainItemComponent;
    public Weapon _secondaryItemComponent;

    [Space(10)]
    public Objects _mainItemData;
    public Objects _secondaryItemData;

    [Space(10)]
    public GameObject iconHolder;

    [Space(5)]
    public GameObject _rightWeapon;
    public GameObject _leftWeapon;

    [SerializeField]
    GameObject _dropItemTemplate;

    GameObject itemSlot_Main;
    GameObject itemSlot_Secondary;
    GameObject itemSlot_Armor;
    GameObject itemSlot_Utility;

    public Animator _anim;
    Player_InputAction input;

    void Awake()
    {
        input = new Player_InputAction();

        input.Player.MainAttack.started += ctx => _mainItemComponent.Attack();
        input.Player.SecondaryAttack.started += ctx => _secondaryItemComponent.Attack();
    }

    private void Start()
    {
        //Get slots
        itemSlot_Main = iconHolder.transform.GetChild(0).gameObject;
        itemSlot_Secondary = iconHolder.transform.GetChild(1).gameObject;
        itemSlot_Armor = iconHolder.transform.GetChild(2).gameObject;
        itemSlot_Utility = iconHolder.transform.GetChild(3).gameObject;
    }

    public void RetreiveItem()
    {
        if (_mainItem != null && _secondaryItem != null)
            return;

        if (Physics.CheckSphere(transform.position, itemSearchRadius, itemLayer))
        {
            //Find items and allow the closest one to be picked up
            GameObject itemToPickUp = null;
            GameObject[] itemsInRange = GameObject.FindGameObjectsWithTag("Items");

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

    void ApplyItem(Pickup pickup)
    {
        //Put item in appropriate slot
        switch(pickup.item._slotType)
        {
            case Objects.Slot.weapon:
                if (_mainItem == null)
                {
                    _mainItem = Instantiate(pickup.item.createItem, _rightWeapon.transform.position, transform.rotation);
                    _mainItemComponent = _mainItem.GetComponent<Weapon>();
                    _mainItemComponent._isMainWeapon = true;
                    _mainItemComponent._anim = _anim;
                    _mainItemData = pickup.item;
                    _mainItem.transform.parent = _rightWeapon.transform;
                    _mainItem.transform.localEulerAngles = Vector3.zero;
                }

                else if (_secondaryItem == null)
                {
                    _secondaryItem = Instantiate(pickup.item.createItem, _leftWeapon.transform.position, transform.rotation);
                    
                    _secondaryItemComponent = _secondaryItem.GetComponent<Weapon>();
                    _secondaryItemComponent._isMainWeapon = false;
                    _secondaryItemComponent._anim = _anim;
                    _secondaryItemData = pickup.item;
                    _secondaryItem.transform.parent = _leftWeapon.transform;
                    _secondaryItem.transform.localEulerAngles = Vector3.zero;
                }
                
                SetIcon();
                break;
        }
    }

    public void InitDropItem(int slot)
    {
        switch(slot)
        {
            case 0:
                if (_mainItem == null)
                    return;

                //Drop main item
                DropItem(_mainItemData);
                RemoveIcon(itemSlot_Main);
                _mainItemComponent = null;
                Destroy(_rightWeapon.transform.GetChild(0).gameObject);
                _mainItem = null;
                break;

            case 1:
                if (_secondaryItem == null)
                    return;

                //Drop secondary item
                DropItem(_secondaryItemData);
                RemoveIcon(itemSlot_Secondary);
                _secondaryItemComponent = null;
                Destroy(_leftWeapon.transform.GetChild(0).gameObject);
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

    void DropItem(Objects item)
    {
        GameObject itemToDrop = _dropItemTemplate;
        itemToDrop.GetComponent<Pickup>().item= item;
        Instantiate(itemToDrop, transform.position, transform.rotation);
    }

    void SetIcon()
    {
        if (_mainItem != null)
            itemSlot_Main.transform.GetChild(0).GetComponent<Image>().sprite = _mainItemData.icon;
        if (_secondaryItem != null)
            itemSlot_Secondary.transform.GetChild(0).GetComponent<Image>().sprite = _secondaryItemData.icon;
    }

    void RemoveIcon(GameObject itemSlot)
    {
        Image icon = itemSlot.transform.GetChild(0).GetComponent<Image>();
        icon.sprite = null;
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

    public void EnableMainAttack()
    {
        _mainItemComponent._canDamage = true;
    }
    public void EnableSecondaryAttack()
    {
        _secondaryItemComponent._canDamage = true;
    }
    public void DisableAttack()
    {
        if (_mainItemComponent != null)
            _mainItemComponent._canDamage = false;
        if (_secondaryItemComponent != null)
            _secondaryItemComponent._canDamage = false;
    }

    public void ResetDamageDealtBool()
    {
        if (_mainItemComponent != null)
            _mainItemComponent._hasDealtDamage = false;

        if (_secondaryItemComponent != null)
            _secondaryItemComponent._hasDealtDamage = false;
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