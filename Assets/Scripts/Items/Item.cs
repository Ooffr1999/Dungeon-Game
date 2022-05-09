using UnityEngine;
using UnityEngine.UI;

[CreateAssetMenu(fileName = "Weapons", menuName = "Inventory Items", order = 1)]
public class Item : ScriptableObject
{
    [Header("Weapons Information")]
    public string name;
    public enum itemType { Weapon, Armor, Utility};
    public itemType _ItemType;

    [Header("Visuals")]
    public Sprite icon;
    public Mesh model;
    public Material model_Material;

}
