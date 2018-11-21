using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class ColorDebugger: MonoBehaviour {

    void Update()
    {
        if(Input.GetMouseButtonDown(0))
        {
            StartCoroutine(CaptureScreenshot());
        }
    }


    IEnumerator CaptureScreenshot()
    {
        yield return new WaitForEndOfFrame();

        Texture2D m_texture = new Texture2D(Screen.width, Screen.height, TextureFormat.RGB24, false);

        m_texture.ReadPixels(new Rect(0, 0, Screen.width, Screen.height), 0, 0);

        m_texture.Apply();

        Color color = m_texture.GetPixel((int)Input.mousePosition.x, (int)Input.mousePosition.y);

        Debug.Log("Color = " + color.ToString());

    }
}
