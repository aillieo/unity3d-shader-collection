using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MatValueChange : MonoBehaviour
{
    new public Renderer renderer;
    public Image image;

    public string propertyName;

    public float min = 0;
    public float max = 1f;
    public float delta = 0.1f;
    public float value = 0;

    private bool increasing = true;

    void Update()
    {
        delta = Mathf.Abs(delta);

        value = increasing ? value + delta : value - delta;

        if(value > max)
        {
            value = max;
            increasing = false;
        }
        else if(value < min)
        {
            value = min;
            increasing = true;
        }

        if(renderer != null)
        {
            renderer.material.SetFloat(propertyName, value);
        }
        if(image != null)
        {
            image.canvasRenderer.GetMaterial().SetFloat(propertyName, value);
        }
    }
}
