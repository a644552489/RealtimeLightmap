using UnityEngine;

// 光照贴图数据
public class SLG_LightingMapData
{

    public int type;
    public int lightmapIndex;
    public Vector4 lightmapST;
    public LightmapsMode lightmapsMode;
    public MixedLightingMode mixedLightingMode;

    public SLG_LightingMapData(Mgs_LightingMapData msgData)
    {
        type = msgData.lightSceneType;
        lightmapIndex = msgData.lightmapIndex;
        lightmapST = msgData.lightmapST;
        lightmapsMode = (LightmapsMode)msgData.lightmapsMode;
        mixedLightingMode = (MixedLightingMode)msgData.mixedLightingMode;
    }

}
