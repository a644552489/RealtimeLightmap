using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector;

namespace YLib.Lightmap
{
    [ExecuteInEditMode]
    public class SunNight : MonoBehaviour
    {


        [ShowInInspector]
        [Range(0, 1)]
        public static float lightmap = 1;

        public static float Emission = 1;
        [ShowInInspector]
        [Range(1, 3)]
        public static float ShadowGI = 1;
        private Light realtimeDic;
        public List<LightProp> RealtimeLightParams = new List<LightProp>();


        [System.Serializable]
        public class LightProp
        {
            public Color color = Color.white;
            public float intensity = 1;
            public float continuedTime = 1;
            public float LerpTime = 1;
            public Vector3 rot = Vector3.zero;
            [Range(0, 1)]
            public float SunNight = 0;

            [Range(0, 3)]
            public float Emission = 1;
        }

        private void Start()
        {
            realtimeDic = GetComponent<Light>();

        }

        private void Update()
        {
            Shader.SetGlobalFloat(LightmapNode._LightmapStrength, lightmap);
            Shader.SetGlobalFloat(LightmapNode._EmissionStrength, Emission);
            Shader.SetGlobalFloat(LightmapNode._ShadowGIStrength, ShadowGI);


        }
        int realtimeIndex = 0;
        private void FixedUpdate()
        {

            if (RealtimeLightParams.Count > 0)
            {
                GetParams();
            }
        }

        float fixedDeltaTime = 0;
        float waittime = 0;
        void GetParams()
        {
            if (realtimeIndex >= 0 && realtimeIndex < RealtimeLightParams.Count)
            {
                //插值
                float t = Time.fixedDeltaTime / (RealtimeLightParams[realtimeIndex].LerpTime - fixedDeltaTime);


                fixedDeltaTime += Time.fixedDeltaTime;
                realtimeDic.intensity = Mathf.Lerp(realtimeDic.intensity, RealtimeLightParams[realtimeIndex].intensity, t);

                realtimeDic.color = Color.Lerp(realtimeDic.color, RealtimeLightParams[realtimeIndex].color, t);

                transform.rotation = Quaternion.Slerp(transform.rotation, Quaternion.Euler(RealtimeLightParams[realtimeIndex].rot), t);

                lightmap = Mathf.Lerp(lightmap, RealtimeLightParams[realtimeIndex].SunNight, t);

                Emission = Mathf.Lerp(Emission, RealtimeLightParams[realtimeIndex].Emission, t);

                //当插值完成
                if (t >= 1 || t < 0)
                {

                    //暂停时间
                    float waits = Time.fixedDeltaTime / (RealtimeLightParams[realtimeIndex].continuedTime - waittime);
                    waittime += Time.fixedDeltaTime;

                    //暂停完成
                    if (waits >= 1)
                    {
                        fixedDeltaTime = 0;
                        waittime = 0;
                        if (realtimeIndex + 1 < RealtimeLightParams.Count)
                        {
                            realtimeIndex++;
                            GetParams();
                        }
                        else
                        {
                            realtimeIndex = 0;
                            GetParams();
                        }
                    }
                }

            }

        }

    }
}