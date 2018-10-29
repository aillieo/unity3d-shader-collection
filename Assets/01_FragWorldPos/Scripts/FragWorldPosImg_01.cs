using UnityEngine;

public class FragWorldPosImg_01 : OnRenderImageBase
{

	void OnEnable() {
        cam.depthTextureMode |= DepthTextureMode.Depth;
    }


    protected override void ProcessMat(Material mat)
    {

        Matrix4x4 currentViewProjectionMatrix = cam.projectionMatrix * cam.worldToCameraMatrix;
        Matrix4x4 currentViewProjectionInverseMatrix = currentViewProjectionMatrix.inverse;
        mat.SetMatrix("_VP_Inverse", currentViewProjectionInverseMatrix);

        //mat.SetMatrix("_VP_Inverse", (cam.projectionMatrix * cam.worldToCameraMatrix).inverse);
    }


}
