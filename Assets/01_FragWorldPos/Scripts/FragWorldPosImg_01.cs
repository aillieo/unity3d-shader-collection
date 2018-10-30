using UnityEngine;

public class FragWorldPosImg_01 : OnRenderImageBase
{

	void OnEnable() {
        cam.depthTextureMode |= DepthTextureMode.Depth;
    }


    protected override void ProcessMat(Material mat)
    {
        mat.SetMatrix("_VP_Inverse", (cam.projectionMatrix * cam.worldToCameraMatrix).inverse);
    }


}
