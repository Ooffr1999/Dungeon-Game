using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
[RequireComponent(typeof(MeshRenderer))]
[RequireComponent(typeof(BoxCollider))]
public class Pickup : MonoBehaviour
{
    public Objects item;
    public MeshFilter mesh;
    public MeshRenderer renderer;

    private void Awake()
    {
        mesh = GetComponent<MeshFilter>();
        renderer = GetComponent<MeshRenderer>();

        mesh.mesh = item.model;
        renderer.material = item.model_Material;
    }

    private void Start()
    {
        transform.localEulerAngles = Vector3.right * 45;
    }

    private void Update()
    {
        transform.eulerAngles += Vector3.up * 0.3f;
    }
}
