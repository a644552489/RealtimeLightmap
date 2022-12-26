using Sirenix.OdinInspector;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using static YLib.Lightmap.LightmapMgr;
using Sirenix.Serialization;

namespace YLib.Lightmap
{

    [ExecuteInEditMode]
    public class LightmapNode : SerializedMonoBehaviour
    {
        public static int Unity_Lightmap_ID = Shader.PropertyToID("unity_Lightmap");
        public static int Unity_LightmapInd_ID = Shader.PropertyToID("unity_LightmapInd");
        public static int Unity_ShadowMask_ID = Shader.PropertyToID("unity_ShadowMask");
        public static int Unity_LightmapST_ID = Shader.PropertyToID("unity_LightmapST");
        public static int Unity_SpecCube0_ID = Shader.PropertyToID("unity_SpecCube0");
        public static int Custom_LightmapST_Morning_ID = Shader.PropertyToID("_Custom_LightmapST_Morning");
        public static int Custom_LightmapST_Evening_ID = Shader.PropertyToID("_Custom_LightmapST_Evening");

        public static int LightmapST_Morning = Shader.PropertyToID("LightmapST_Morning");
        public static int LightmapST_Evening = Shader.PropertyToID("LightmapST_Evening");

        public static int Lightmap_Morning = Shader.PropertyToID("Lightmap_Morning");
        public static int LightmapInd_Morning = Shader.PropertyToID("LightmapInd_Morning");
        public static int ShadowMask_Morning = Shader.PropertyToID("ShadowMask_Morning");

        public static int Lightmap_Evening = Shader.PropertyToID("Lightmap_Evening");
        public static int LightmapInd_Evening = Shader.PropertyToID("LightmapInd_Evening");
        public static int ShadowMask_Evening = Shader.PropertyToID("ShadowMask_Evening");

        public static int _LightmapStrength = Shader.PropertyToID("_LightmapStrength");
        public static int _EmissionStrength = Shader.PropertyToID("_EmissionStrength");
        public static int _ShadowGIStrength = Shader.PropertyToID("_ShadowGIStrength");


        public static MaterialPropertyBlock block = null;
         
        [ValueDropdown("GetTypeName")]
        public int type;
    
        private IEnumerable GetTypeName()
        {
            if (LightmapTypeData.Inst != null)
            {
                return LightmapTypeData.Inst.Propertys;
            }
            return null;
        }
        [SerializeField]
        public Dictionary<LightmapType, LightProp> LightmapProp = new Dictionary<LightmapType, LightProp>();



        private void Awake()
        {
            if (block == null)
            {
                block = new MaterialPropertyBlock();
            }
        }

        private void Start()
        {
#if !IS_ART
            SetLightmapProp_Morning();
            SetLightmapProp_Evening();
#endif
        }

        private void OnEnable()
        {
#if !IS_ART

            SetLightmapProp_Morning();
            SetLightmapProp_Evening();
#endif
        }
      
       
        private void Update()
        {
#if IS_ART
             SetLightmapProp_Morning();
            SetLightmapProp_Evening();
#endif
        }

        private void SetProperty()
        {
            LightProp prop = null;
            
            LightmapProp.TryGetValue(LightmapMgr.Inst.LightType, out prop);
            if (prop == null) return;

            var renderer = GetComponent<MeshRenderer>();
            if (renderer == null) return;

            var material = renderer.sharedMaterial;
            if (material == null) return;

            var texturePackage = LightmapMgr.Inst.GetTexturePackageByInfo(type, prop.lightmapIndex , LightmapMgr.Inst.LightType);
            if (texturePackage == null) return;

  
            SetMaterial(material, prop.lightmapsMode, prop.mixedLightingMode);
            SetBlockProp(texturePackage, renderer, prop.lightmapST);
            
        }

        private void SetLightmapProp_Morning()
        {
            LightProp prop = null;

                LightmapProp.TryGetValue(LightmapType.Morning,out prop);
                if (prop == null) return;

                var renderer = GetComponent<MeshRenderer>();
                if (renderer == null) return;

                var material = renderer.sharedMaterial;
                if (material == null) return;

                var texturePackage = LightmapMgr.Inst.GetTexturePackageByInfo(type, prop.lightmapIndex , LightmapType.Morning);
                if (texturePackage == null) return;

                SetMaterial(material, prop.lightmapsMode, prop.mixedLightingMode);
                SetBlockProperty_Morning(texturePackage, renderer, prop.lightmapST);
        }
        private void SetLightmapProp_Evening()
        {
            LightProp prop = null;

            LightmapProp.TryGetValue(LightmapType.Evening, out prop);
            if (prop == null) return;

            var renderer = GetComponent<MeshRenderer>();
            if (renderer == null) return;

            var material = renderer.sharedMaterial;
            if (material == null) return;

            var texturePackage = LightmapMgr.Inst.GetTexturePackageByInfo(type, prop.lightmapIndex , LightmapType.Evening);
            if (texturePackage == null) return;

            SetMaterial(material, prop.lightmapsMode, prop.mixedLightingMode);
            SetBlockProperty_Evening(texturePackage, renderer, prop.lightmapST);
        }
        private void SetBlockProperty_Morning(TexturePackage texturePackage, MeshRenderer renderer, Vector4 lightmapST)
        {
            if (block == null)
            {
                block = new MaterialPropertyBlock();
            }

       

            renderer.GetPropertyBlock(block);

            block.SetVector(LightmapST_Morning, lightmapST);

            if (texturePackage.lightmapColor != null)
            {
                block.SetTexture(Lightmap_Morning, texturePackage.lightmapColor);
            }
            else
            {
                block.SetTexture(Lightmap_Morning, Texture2D.blackTexture);
            }

            if (texturePackage.lightmapDir != null)
            {
                block.SetTexture(LightmapInd_Morning, texturePackage.lightmapDir);
            }
            else
            {
                block.SetTexture(LightmapInd_Morning, Texture2D.blackTexture);
            }

            if (texturePackage.shadowMask != null)
            {
                block.SetTexture(ShadowMask_Morning, texturePackage.shadowMask);
            }
            else
            {
                block.SetTexture(ShadowMask_Morning, Texture2D.blackTexture);
            }

            renderer.SetPropertyBlock(block);
        }
        private void SetBlockProperty_Evening(TexturePackage texturePackage, MeshRenderer renderer, Vector4 lightmapST)
        {
            if (block == null)
            {
                block = new MaterialPropertyBlock();
            }

       

            renderer.GetPropertyBlock(block);

            block.SetVector(LightmapST_Evening, lightmapST);

            if (texturePackage.lightmapColor != null)
            {
                block.SetTexture(Lightmap_Evening, texturePackage.lightmapColor);
            }
            else
            {
                block.SetTexture(Lightmap_Evening, Texture2D.blackTexture);
            }

            if (texturePackage.lightmapDir != null)
            {
                block.SetTexture(LightmapInd_Evening, texturePackage.lightmapDir);
            }
            else
            {
                block.SetTexture(LightmapInd_Evening, Texture2D.blackTexture);
            }

            if (texturePackage.shadowMask != null)
            {
                block.SetTexture(ShadowMask_Evening, texturePackage.shadowMask);
            }
            else
            {
                block.SetTexture(ShadowMask_Evening, Texture2D.blackTexture);
            }

            renderer.SetPropertyBlock(block);
        }
    



        /*
                public void SetData(SLG_LightingMapData lightingMapData)
                {
                    type = lightingMapData.type;
                    lightmapIndex = lightingMapData.lightmapIndex;
                    lightmapST = lightingMapData.lightmapST;
                    lightmapsMode = lightingMapData.lightmapsMode;
                    mixedLightingMode = lightingMapData.mixedLightingMode;
                }

                public static void SetData(MeshRenderer renderer, SLG_LightingMapData lightingMapData)
                {
                    var type = lightingMapData.type;
                    var lightmapIndex = lightingMapData.lightmapIndex;
                    var lightmapST = lightingMapData.lightmapST;
                    var lightmapsMode = lightingMapData.lightmapsMode;
                    var mixedLightingMode = lightingMapData.mixedLightingMode;

                    var material = renderer.material;
                    if (material == null) return;

                    var texturePackage = LightmapMgr.Inst.GetTexturePackageByInfo(type, lightmapIndex);
                    if (texturePackage == null) return;

                    SetMaterial(material, lightmapsMode, mixedLightingMode);
                    SetBlockProp(texturePackage, renderer, lightmapST);
                }


                */
        public void Register(LightmapType t, LightProp prop)
        {
            if (!LightmapProp.ContainsKey(t))
            {
                LightmapProp.Add(t, new LightProp());
            }
            LightmapProp[t] = prop;
        }


        public static void SetMaterial(Material material, LightmapsMode lightmapsMode, MixedLightingMode mixedLightingMode)
        {
            if (lightmapsMode == LightmapsMode.CombinedDirectional)
            {
                material.EnableKeyword("DIRLIGHTMAP_COMBINED");
            }

            if (mixedLightingMode == MixedLightingMode.Shadowmask)
            {
                material.EnableKeyword("SHADOWS_SHADOWMASK");
                material.EnableKeyword("LIGHTMAP_SHADOW_MIXING");
            }

            if (mixedLightingMode == MixedLightingMode.Subtractive)
            {
                material.EnableKeyword("LIGHTMAP_SHADOW_MIXING");
            }

            material.EnableKeyword("LIGHTMAP_ON");
        }

        private static void SetBlockProp(TexturePackage texturePackage, MeshRenderer renderer, Vector4 lightmapST)
        {
            if (block == null)
            {
                block = new MaterialPropertyBlock();
            }

            block.Clear();

            renderer.GetPropertyBlock(block);

            block.SetVector(Unity_LightmapST_ID, lightmapST);

            if (texturePackage.lightmapColor != null)
            {
                block.SetTexture(Unity_Lightmap_ID, texturePackage.lightmapColor);
            }
            else
            {
                block.SetTexture(Unity_Lightmap_ID, Texture2D.blackTexture);
            }

            if (texturePackage.lightmapDir != null)
            {
                block.SetTexture(Unity_LightmapInd_ID, texturePackage.lightmapDir);
            }
            else
            {
                block.SetTexture(Unity_LightmapInd_ID, Texture2D.blackTexture);
            }

            if (texturePackage.shadowMask != null)
            {
                block.SetTexture(Unity_ShadowMask_ID, texturePackage.shadowMask);
            }
            else
            {
                block.SetTexture(Unity_ShadowMask_ID, Texture2D.blackTexture);
            }

            renderer.SetPropertyBlock(block);
        }

        public void ClearBlockProp()
        {
            var renderer = GetComponent<MeshRenderer>();
            if (renderer == null) return;

            if (block == null)
            {
                block = new MaterialPropertyBlock();
            }

            block.Clear();

            renderer.SetPropertyBlock(block);
        }



        /*
                public void CopyTo(SLG_LightingMapData lightingMapData)
                {
                    lightingMapData.type = type;
                    lightingMapData.lightmapIndex = lightmapIndex;
                    lightingMapData.lightmapST = lightmapST;
                    lightingMapData.lightmapsMode = lightmapsMode;
                    lightingMapData.mixedLightingMode = mixedLightingMode;
                }
        */
    }
}
