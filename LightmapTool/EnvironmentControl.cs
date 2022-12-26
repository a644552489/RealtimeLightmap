using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace YLib.Environment
{
    public class EnvironmentControl : MonoBehaviour
    {
        public Material skybox;

        public AmbientMode ambientMode;
        public float ambientIntensity;
        public Color ambientSkyColor;
        public Color ambientEquatorColor;
        public Color ambientGroundColor;

        public Cubemap customReflection;
        public float reflectionIntensity;

        [Sirenix.OdinInspector.Button]
        private void GenData()
        {
            skybox = RenderSettings.skybox;

            ambientMode = RenderSettings.ambientMode;
            ambientIntensity = RenderSettings.ambientIntensity;
            ambientSkyColor = RenderSettings.ambientSkyColor;
            ambientEquatorColor = RenderSettings.ambientEquatorColor;
            ambientGroundColor = RenderSettings.ambientGroundColor;

            customReflection = GetReflectionCubemap();
            reflectionIntensity = RenderSettings.reflectionIntensity;
        }

        Cubemap GetReflectionCubemap()
        {
#if UNITY_EDITOR
            var lightmaps = LightmapSettings.lightmaps;
            var lightingDataAsset = UnityEditor.Lightmapping.lightingDataAsset;
            var dependencie = UnityEditor.AssetDatabase.GetDependencies(UnityEditor.AssetDatabase.GetAssetPath(lightingDataAsset));
            foreach (var item in dependencie)
            {
                if (item.EndsWith("-0.exr"))
                {
                    return UnityEditor.AssetDatabase.LoadAssetAtPath<Cubemap>(item);
                }
            }
#endif
            return null;
        }

        void Start()
        {

        }

        public void SetData()
        {
            RenderSettings.skybox = skybox;

            RenderSettings.ambientMode = ambientMode;
            RenderSettings.ambientIntensity = ambientIntensity;
            RenderSettings.ambientSkyColor = ambientSkyColor;
            RenderSettings.ambientEquatorColor = ambientEquatorColor;
            RenderSettings.ambientGroundColor = ambientGroundColor;

            RenderSettings.defaultReflectionMode = DefaultReflectionMode.Custom;
            RenderSettings.customReflection = customReflection;
            RenderSettings.reflectionIntensity = reflectionIntensity;

            DynamicGI.UpdateEnvironment();
        }

        public void ClearData()
        {
            RenderSettings.skybox = null;

            RenderSettings.ambientMode = ambientMode;
            RenderSettings.ambientIntensity = ambientIntensity;
            RenderSettings.ambientSkyColor = ambientSkyColor;
            RenderSettings.ambientEquatorColor = ambientEquatorColor;
            RenderSettings.ambientGroundColor = ambientGroundColor;

            RenderSettings.defaultReflectionMode = DefaultReflectionMode.Custom;
            RenderSettings.customReflection = null;
            RenderSettings.reflectionIntensity = 1;

            DynamicGI.UpdateEnvironment();
        }


    }

}


