using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Pixel_PostProcessing : MonoBehaviour
{
    public Material _effect;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        _effect.mainTexture = source;
        Graphics.Blit(source, destination, _effect);
    }
}
