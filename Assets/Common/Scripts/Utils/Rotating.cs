using UnityEngine;

public class Rotating : MonoBehaviour
{

    public Quaternion rotate = Quaternion.identity;

	void Update ()
    {
        transform.localRotation*= rotate;
	}
}
