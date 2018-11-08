using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


public class RadarImage : MonoBehaviour {

    [SerializeField]
    int dimensions;


    [SerializeField]
    Shader radarShader;
    [SerializeField]
    Image baseImage;

	public bool animateOnStart = false;

    struct MatPair
    {
        public Material mat1;
        public Material mat2;
    }

    List<MatPair> radarMats = new List<MatPair>();


	void Start ()
    {

        dimensions = Mathf.Clamp(dimensions, 3, 18);

        if (radarShader != null && baseImage != null)
        {
            InitMats();
			if(animateOnStart)
			{
				StartChangeValue();
			}
		}
	}
	

    void InitMats()
    {

        List<Material> mats = new List<Material>();

        float angleRange = 360.0f / dimensions;

        for(int i = 0; i < dimensions; i ++)
        {
            Image img = Instantiate(baseImage);
            img.transform.SetParent(transform,false);
            img.gameObject.SetActive(true);

            Material mat = new Material(radarShader);
            mat.hideFlags = HideFlags.DontSave;
            mat.SetFloat("_AngleRange", angleRange);
            mat.SetFloat("_AngleStart", angleRange * i);

			mat.SetColor ("_Color",baseImage.color);

            img.material = mat;
            mats.Add(mat);
        }

        for(int i = 0; i < dimensions; i ++)
        {
            radarMats.Add(new MatPair{
                mat1 = mats[i],
                mat2 = mats[(i+1)%dimensions],
            });
        }
    }


    public void SetValueForIndex(int index, float value)
    {
        MatPair mp = radarMats[index];
        mp.mat1.SetFloat("_ValueEnd", value);
        mp.mat2.SetFloat("_ValueStart", value);
    }


    void StartChangeValue()
    {
		StartCoroutine (UpdateValues());
    }

	IEnumerator UpdateValues()
	{
		int frames = 180;
		List<float> currentValues = new List<float> ();
		for(int i = 0; i < dimensions; i ++)
		{
			currentValues.Add (1.0f);
		}
		while (true)
		{
			int frame = 0;
			List<float> deltaValues = new List<float> ();
			for(int i = 0; i < dimensions; i ++)
			{
				deltaValues.Add (( Random.Range(0.5f,0.95f) - currentValues[i]) / frames);
			}
			while(frame < frames)
			{
				frame++;
				for(int i = 0; i < dimensions; i ++)
				{
					currentValues[i] += deltaValues[i];
					SetValueForIndex (i,currentValues[i]);
				}
				yield return null;
			}
		}
	}


}
