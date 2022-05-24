using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "Objects", menuName = "Objects", order = 1)]
public class Objects : ScriptableObject
{
    [Header("Object Information")]
    public string name;

    [Header("Data")]
    public GameObject createItem;
    public enum Slot { weapon, armor, utility}
    public Slot _slotType;

    [Header("Visuals")]
    public Sprite icon;
    public Mesh model;
    public Material model_Material;
}
