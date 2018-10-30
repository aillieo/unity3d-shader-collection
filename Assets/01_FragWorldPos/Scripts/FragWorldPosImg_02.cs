using UnityEngine;
using System.Collections;

public class FragWorldPosImg_02 : OnRenderImageBase
{


	void OnEnable() {
		cam.depthTextureMode |= DepthTextureMode.Depth;
	}


	bool matForCamOrtho = false;

    protected override void ProcessMat(Material mat)
    {
        Transform camTransform = cam.transform;
        Matrix4x4 frustumCorners = Matrix4x4.identity;

		if (cam.orthographic) 
		{
			float aspect = cam.aspect;
			float size = cam.orthographicSize;
			float height = size * 2;
			float width = height * aspect;
		
			Vector3 farCenter = camTransform.forward * cam.farClipPlane;
			Vector3 toRight = 0.5f * width * camTransform.right;
			Vector3 toTop = 0.5f * height * camTransform.up;

			Vector3 bottomLeft = farCenter - toTop - toRight;
			Vector3 bottomRight = farCenter - toTop + toRight;
			Vector3 topRight = farCenter + toTop + toRight;
			Vector3 topLeft = farCenter + toTop - toRight;

			frustumCorners.SetRow(0, bottomLeft);
			frustumCorners.SetRow(1, bottomRight);
			frustumCorners.SetRow(2, topRight);
			frustumCorners.SetRow(3, topLeft);

			frustumCorners.SetColumn (3, farCenter);

			if(!matForCamOrtho)
			{
				matForCamOrtho = true;
				mat.EnableKeyword ("_CAM_ORTHO");
			}
		}
		else 
		{

			float fov = cam.fieldOfView;
			float near = cam.nearClipPlane;
			float aspect = cam.aspect;

			float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
			Vector3 toRight = camTransform.right * halfHeight * aspect;
			Vector3 toTop = camTransform.up * halfHeight;

			Vector3 topLeft = camTransform.forward * near + toTop - toRight;
			float scale = topLeft.magnitude / near;

			topLeft.Normalize();
			topLeft *= scale;

			Vector3 topRight = camTransform.forward * near + toRight + toTop;
			topRight.Normalize();
			topRight *= scale;

			Vector3 bottomLeft = camTransform.forward * near - toTop - toRight;
			bottomLeft.Normalize();
			bottomLeft *= scale;

			Vector3 bottomRight = camTransform.forward * near + toRight - toTop;
			bottomRight.Normalize();
			bottomRight *= scale;

			frustumCorners.SetRow(0, bottomLeft);
			frustumCorners.SetRow(1, bottomRight);
			frustumCorners.SetRow(2, topRight);
			frustumCorners.SetRow(3, topLeft);

			if(matForCamOrtho)
			{
				matForCamOrtho = false;
				mat.DisableKeyword ("_CAM_ORTHO");
			}

		}

        mat.SetMatrix("_FrustumCornersRay", frustumCorners);

    }

}
