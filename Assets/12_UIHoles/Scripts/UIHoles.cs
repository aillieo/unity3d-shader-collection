using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.UI;

public class UIHoles : MonoBehaviour 
{
    [SerializeField]
    Vector2[] holePos = new Vector2[1];
    [SerializeField]
    float Radius1;
    [SerializeField]
    float Radius2;

    Material mat;

    public void UpdateHoleInfo(IList<Vector2> holes)
    {
        this.holePos = holes.ToArray();
        UpdateMatValues();
    }

    [ExecuteInEditMode]
	void OnEnable()
    {
        UpdateMatValues();
	}

    [ContextMenu("UpdateMatValues")]
    void UpdateMatValues()
    {
        EnsureMat();
        mat.SetFloat("_Radius1", Radius1);
        mat.SetFloat("_Radius2", Radius2);
        mat.SetInt("_HoleCount", holePos.Length);
        mat.SetVectorArray("_Holes", holePos.Select(v2 => (Vector4)v2).ToList());
    }

    void EnsureMat()
    {
        if (mat == null)
        {
            mat = this.GetComponent<Graphic>().material;
        }
    }

#if UNITY_EDITOR
    private void OnValidate()
    {
        UpdateMatValues();    
    }
#endif

}
