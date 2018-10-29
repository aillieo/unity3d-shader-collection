using UnityEngine;
using System.Collections;

public class FragWorldPosImg_02 : OnRenderImageBase
{


	void OnEnable() {
		cam.depthTextureMode |= DepthTextureMode.Depth;
	}

    protected override void ProcessMat(Material mat)
    {
        Transform camTransform = cam.transform;
        Matrix4x4 frustumCorners = Matrix4x4.identity;

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

        mat.SetMatrix("_FrustumCornersRay", frustumCorners);

    }

}
