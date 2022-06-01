using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class Player_Item_Management : MonoBehaviour
{
    public float itemSearchRadius;
    public LayerMask itemLayer;

    //Items and managing them
    #region Items
    [Space(10)]
    public GameObject _mainItem;
    public GameObject _secondaryItem;
    public GameObject _armorItem;
    public GameObject _utilityItem;

    [Space(10)]
    public Weapon _mainItemComponent;
    public Weapon _secondaryItemComponent;
    public Utility _utilityItemComponent;

    [Space(10)]
    public Objects _mainItemData;
    public Objects _secondaryItemData;
    public Objects _armorItemData;
    public Objects _utilityItemData;

    [Space(10)]
    public GameObject iconHolder;

    [Space(5)]
    public GameObject _rightWeapon;
    public GameObject _leftWeapon;
    public GameObject _armor;
    public GameObject _utility;

    [SerializeField]
    GameObject _dropItemTemplate;

    GameObject itemSlot_Main;
    GameObject itemSlot_Secondary;
    GameObject itemSlot_Armor;
    GameObject itemSlot_Utility;
    #endregion

    //Level up
    [Space(10)]
    public GameObject _levelUpMenu;

    [Space(10)]
    public Animator _anim;
    public AnimatorOverrideController _overrideController;
    Player_InputAction input;

    void Awake()
    {
        input = new Player_InputAction();

        input.Player.MainAttack.started += ctx => _mainItemComponent.Attack();
        input.Player.SecondaryAttack.started += ctx => _secondaryItemComponent.Attack();
        input.Player.UtilityAttack.started += ctx => _utilityItemComponent.OnAbilityEngage();
    }

    private void Start()
    {
        //Get slots
        itemSlot_Main = iconHolder.transform.GetChild(0).gameObject;
        itemSlot_Secondary = iconHolder.transform.GetChild(1).gameObject;
        itemSlot_Armor = iconHolder.transform.GetChild(2).gameObject;
        itemSlot_Utility = iconHolder.transform.GetChild(3).gameObject;
    }

    //Picking up items and stuff
    #region Item Management
    public void RetreiveItem()
    {
        if (_mainItem != null && _secondaryItem != null && _utilityItem != null)
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
                    _mainItemComponent._damage = _mainItemData.damageOnHit;
                    _overrideController["Player_Anim_Right_Weapon"] = _mainItemData._mainWeaponAnim;
                    _anim.SetFloat("MainWeaponSpeedModifier", _mainItemData.weaponSpeedModifier);
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
                    _secondaryItemComponent._damage = _secondaryItemData.damageOnHit;
                    _overrideController["Player_Anim_Left_Weapon"] = _secondaryItemData._secondaryWeaponAnim;
                    _anim.SetFloat("SecondaryWeaponSpeedModifier", _secondaryItemData.weaponSpeedModifier);
                }
                
                break;

            case Objects.Slot.utility:
                if (_utilityItem != null)
                    break;

                _utilityItem = Instantiate(pickup.item.createItem, _utility.transform.position, transform.rotation);
                _utilityItemComponent = _utilityItem.GetComponent<Utility>();
                _utilityItemData = pickup.item;
                _utilityItem.transform.parent = _utility.transform;
                _utilityItem.transform.localEulerAngles = Vector3.zero;
                break;
        }
        SetIcon();
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
                if (_utilityItem == null)
                    return;

                //Drop Utility item
                DropItem(_utilityItemData);
                RemoveIcon(itemSlot_Utility);
                _utilityItemComponent = null;
                Destroy(_utility.transform.GetChild(0).gameObject);
                _utilityItem = null;
                break;
        }
    }

    void DropItem(Objects item)
    {
        GameObject itemToDrop = _dropItemTemplate;
        itemToDrop.GetComponent<Pickup>().item= item;
        Instantiate(itemToDrop, transform.position, transform.rotation);
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
    #endregion

    //Attacking and resetting states
    #region AnimatorStateSettings
    public void EnableMainAttack()
    {
        if (_mainItemComponent != null)
            _mainItemComponent._canDamage = true;
    }
    
    public void EnableSecondaryAttack()
    {
        if (_secondaryItemComponent != null)
            _secondaryItemComponent._canDamage = true;
    }
    
    public void DisableMainAttack()
    {
        if (_mainItemComponent != null)
            _mainItemComponent._canDamage = false;
        
    }

    public void DisableSecondaryAttack()
    {
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

    public void EnableIsAttacking()
    {
        _anim.SetBool("IsAttacking", true);
    }

    public void DisableIsAttacking()
    {
        _anim.SetBool("IsAttacking", false);
    }

    public void ResetAllWeaponVariables()
    {
        Debug.Log("Reset attack variables");
        ResetDamageDealtBool();
        EnableMainAttack();
        EnableSecondaryAttack();
        
    }

    public void ActivateMainOnAttackEnd()
    {
        DisableIsAttacking();
        _mainItemComponent.OnAttackOver();
    }

    public void ActivateSecondaryOnAttackEnd()
    {
        DisableIsAttacking();
        _secondaryItemComponent.OnAttackOver();
    }
    #endregion

    //Setting ui and stuff
    #region UI 
    void SetIcon()
    {
        if (_mainItem != null)
            itemSlot_Main.transform.GetChild(0).GetComponent<Image>().sprite = _mainItemData.icon;
        if (_secondaryItem != null)
            itemSlot_Secondary.transform.GetChild(0).GetComponent<Image>().sprite = _secondaryItemData.icon;
        if (_utilityItem != null)
            itemSlot_Utility.transform.GetChild(0).GetComponent<Image>().sprite = _utilityItemData.icon;
    }

    void RemoveIcon(GameObject itemSlot)
    {
        Image icon = itemSlot.transform.GetChild(0).GetComponent<Image>();
        icon.sprite = null;
    }

    public void OpenLevelUpMenu()
    {
        Time.timeScale = 0;
        _levelUpMenu.SetActive(true);
    }

    public void CloseLevelUpMenu()
    {
        Time.timeScale = 1;
        _levelUpMenu.SetActive(false);
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