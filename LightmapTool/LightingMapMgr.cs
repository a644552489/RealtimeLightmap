//using Loader;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LitJson;
using System.Text.RegularExpressions;
//using LGui;

namespace Utility
{
    public class LightingMapMgr
    {
        enum LoadState
        {
            NOLOAD,
            LOADING,
            LOADED,
            LOAD_ERROR,
            LOADED_DEAL,
        }
        class Info
        {
            public string m_jsonPath;
            public string m_boundlePath;
            public Info(string boundlePath, string jsonPath)
            {
                m_boundlePath = boundlePath;
                m_jsonPath = jsonPath;
                m_lightmapDatalist = new List<LightmapData>();
                m_indexMap = new Dictionary<int, int>();
            }

            public AssetBundle m_boundle;
            public JsonData m_json;
            public List<LightmapData> m_lightmapDatalist = null;
            public Dictionary<int, int> m_indexMap = null;


            public LoadState m_state = LoadState.NOLOAD;
        }

        static LightmapData lightMapData_null = new LightmapData();

        static string cur_assetName = null;

        //static Dictionary<string, LoadState> m_boundleLoadState = new Dictionary<string, LoadState>();
        static Dictionary<string, Info> m_infos = new Dictionary<string, Info>();

        //public static void OnLoadBoundle(LoadSession session, object obj)
        //{
        //    string assetName = (string)session.Param;
        //    Info info;
        //    if (!m_infos.TryGetValue(assetName, out info)) //还没load完就已经切场景出去了
        //    {
        //        return;
        //    }
        //    if (obj == null)
        //    {
        //        info.m_state = LoadState.LOAD_ERROR;
        //        Debug.LogError("load error " + " " + session.Error);
        //        LoadSession.Push(session);
        //        return;
        //    }
        //    //Debug.Log("OnInitLoad --" + session.Path);
        //    info.m_state = LoadState.LOADED;

        //    AssetBundle assetBundle = obj as AssetBundle;

        //    info.m_boundle = obj as AssetBundle;

        //    info.m_json = GetJsonObject(info.m_jsonPath);

        //    LoadSession.Push(session);
        //}

        //public static float IsLoadOver(string assetName, out bool isDone)
        //{
        //    Info info;
        //    if (!m_infos.TryGetValue(assetName, out info)) //不需要光照贴图
        //    {
        //        isDone = true;
        //        return 1f;
        //    }
        //    LoadState loadBoundleState = info.m_state;
        //    if (loadBoundleState == LoadState.NOLOAD)
        //    {
        //        info.m_state = LoadState.LOADING;
        //        LoadSession session = LoadSession.Pop(info.m_boundlePath, info.m_boundlePath, assetName);
        //        session.IsCacheBoundle = true;
        //        session.IsOnlyLoadBoundle = true;
        //        LoadAccessor.LoadAsset(session, OnLoadBoundle, true);
        //    }
        //    else if (loadBoundleState == LoadState.LOADED)
        //    {
        //        LoadLightmapByFile(info);
        //        info.m_state = LoadState.LOADED_DEAL;
        //        isDone = true;
        //        return 1f;
        //    }
        //    else if (loadBoundleState == LoadState.LOADED_DEAL)
        //    {
        //        isDone = true;
        //        return 1f;
        //    }

        //    isDone = false;
        //    return 0f;
        //}

        public static void AddNeedLightMap(string assetName, string bundlePath, string jsonPath)
        {
            cur_assetName = assetName;

            Info info;
            if (!m_infos.TryGetValue(assetName, out info))
            {
                info = new Info(bundlePath, jsonPath);
                m_infos[assetName] = info;
            }
            else
            {
                if (info.m_state == LoadState.LOADED_DEAL)
                {
                    info.m_state = LoadState.LOADED;
                }
            }
        }

        struct SceneLightmapStruct
        {
            public int startIndex;
            public int endIndex;
        }
        private static Dictionary<string, SceneLightmapStruct> sceneLightmapIndexDic = new Dictionary<string, SceneLightmapStruct>();
        //[XLua.BlackList]
        public static void addSceneLightmap(string sceneName, int startIndex, int endIndex)
        {
            if (!sceneLightmapIndexDic.ContainsKey(sceneName) && endIndex >= startIndex)
            {
                SceneLightmapStruct sls = new SceneLightmapStruct();
                sls.startIndex = startIndex;
                sls.endIndex = endIndex;
                sceneLightmapIndexDic.Add(sceneName, sls);
            }
        }
        //清空数据
        public static void clearSceneLightmapDic(string sceneName)
        {
            if (string.IsNullOrEmpty(sceneName))
            {
                sceneLightmapIndexDic.Clear();
            }
            else
            {
                if (!sceneLightmapIndexDic.ContainsKey(sceneName))
                {
                    sceneLightmapIndexDic.Remove(sceneName);
                }
            }
        }
        //将场景自带的光照贴图销毁掉
        public static void DestorySceneLightmap(string sceneName)
        {
            SceneLightmapStruct sls;
            if (sceneLightmapIndexDic.TryGetValue(sceneName, out sls))
            {
                sceneLightmapIndexDic.Remove(sceneName);
                int startIndex = sls.startIndex;
                int endIndex = sls.endIndex;
                LightmapData[] lightmaps = LightmapSettings.lightmaps;
                if (lightmaps.Length > endIndex)
                {
                    for (int i = startIndex; i <= endIndex; i++)
                    {
                        if (null != lightmaps[i].lightmapColor)
                        {
                            Resources.UnloadAsset(lightmaps[i].lightmapColor);
                            lightmaps[i].lightmapColor = null;
                        }
                        if (null != lightmaps[i].lightmapDir)
                        {
                            Resources.UnloadAsset(lightmaps[i].lightmapDir);
                            lightmaps[i].lightmapDir = null;
                        }
                        if (null != lightmaps[i].shadowMask)
                        {
                            Resources.UnloadAsset(lightmaps[i].shadowMask);
                            lightmaps[i].shadowMask = null;
                        }
                    }
                    adjustLightmaps(lightmaps);
                }
            }

            cur_assetName = null;
        }

        //重整光照贴图个数
        private static void adjustLightmaps(LightmapData[] lightmaps)
        {
            int maxIndex = -1;
            for (int i = lightmaps.Length - 1; i >= 0; i--)
            {
                if (lightmaps[i].lightmapColor != null || lightmaps[i].lightmapDir != null || lightmaps[i].shadowMask != null)
                {
                    maxIndex = i;
                    break;
                }
            }

            LightmapData[] lightmapsNew = null;
            if (maxIndex >= 0)
            {
                if (maxIndex == lightmaps.Length - 1)  //长度没改变
                {
                    lightmapsNew = lightmaps;
                }
                else
                {
                    maxIndex++; //长度
                    lightmapsNew = new LightmapData[maxIndex];
                    for (int i = 0; i < maxIndex; i++)
                    {
                        lightmapsNew[i] = lightmaps[i];
                    }
                }
            }

            LightmapSettings.lightmaps = lightmapsNew;
        }

        public static void SetNullLightmaps()
        {
            LightmapSettings.lightmaps = null;
        }

        public static void OnSceneDestroy(string assetName)
        {
            Info info;
            if (m_infos.TryGetValue(assetName, out info))
            {
                if (info.m_indexMap.Count > 0)
                {
                    LightmapData[] lightmaps = LightmapSettings.lightmaps;
                    int length = lightmaps.Length;
                    foreach (var keyValue in info.m_indexMap)
                    {
                        if (length > keyValue.Value)
                        {
                            lightmaps[keyValue.Value] = lightMapData_null;
                        }
                    }
                    adjustLightmaps(lightmaps);
                    info.m_indexMap.Clear();
                }
            }
        }

        //加载光照贴图
        private static void LoadLightmapByFile(Info info)
        {
            var jsonData = info.m_json;
            var assetBundle = info.m_boundle;
            List<LightmapData> newAddLightmapDatalist = info.m_lightmapDatalist;

            //还没加载过
            if (newAddLightmapDatalist.Count != jsonData["lightmapList"].Count)
            {
                //读json
                LightmapsMode newLightmapsMode = (LightmapsMode)jsonData["lightmapsMode"].ToInt32();
                MixedLightingMode mixedLightingMode = (MixedLightingMode)jsonData["mixedLightingMode"].ToInt32();

                for (int k = 0; k < jsonData["lightmapList"].Count; k++)
                {
                    LightmapData lightmapData = new LightmapData();
                    lightmapData.lightmapColor = assetBundle.LoadAsset<Texture2D>(jsonData["lightmapList"][k]["col"].ToString());

                    if (newLightmapsMode == LightmapsMode.CombinedDirectional && jsonData["lightmapList"][k].Contains("dir"))
                    {
                        lightmapData.lightmapDir = assetBundle.LoadAsset<Texture2D>(jsonData["lightmapList"][k]["dir"].ToString());
                    }

                    if (mixedLightingMode == MixedLightingMode.Shadowmask && jsonData["lightmapList"][k].Contains("shadowmask"))
                    {
                        lightmapData.shadowMask = assetBundle.LoadAsset<Texture2D>(jsonData["lightmapList"][k]["shadowmask"].ToString());
                    }

                    newAddLightmapDatalist.Add(lightmapData);
                }
            }


            //复制当前使用的光照数组
            LightmapData[] lightmaps = LightmapSettings.lightmaps;

            int i = 0;
            int j = 0;
            for (; i < newAddLightmapDatalist.Count; i++)
            {
                while (j < lightmaps.Length)
                {
                    //填到空位置
                    //if (LightmapSettings.lightmaps[j] == lightMapData_null) //竟然不相等？
                    if (lightmaps[j].lightmapColor == null)
                    {
                        lightmaps[j] = newAddLightmapDatalist[i];
                        info.m_indexMap.Add(i, j);

                        break;
                    }
                    j++;
                }
                if (j == lightmaps.Length)
                {
                    break;
                }
            }

            //多出的插入数组后面
            if (i < newAddLightmapDatalist.Count)
            {
                LightmapData[] tempLightmaps = new LightmapData[LightmapSettings.lightmaps.Length + newAddLightmapDatalist.Count - i];
                lightmaps.CopyTo(tempLightmaps, 0);

                for (; i < newAddLightmapDatalist.Count; i++)
                {
                    tempLightmaps[j] = newAddLightmapDatalist[i];
                    info.m_indexMap.Add(i, j);
                    j++;
                }

                //设置新的光照贴图
                LightmapSettings.lightmaps = tempLightmaps;
            }
            else
            {
                LightmapSettings.lightmaps = lightmaps;
            }


            /*
            //合并数组
            int indexOffset = LightmapSettings.lightmaps.Length;
            LightmapData[] lightmaps = new LightmapData[indexOffset + newLightmapDatalist.Count];
            LightmapSettings.lightmaps.CopyTo(lightmaps, 0);
            newLightmapDatalist.CopyTo(lightmaps, indexOffset);

            //设置新的光照贴图
            //LightmapSettings.lightmapsMode = newLightmapsMode;
            LightmapSettings.lightmaps = lightmaps;

            info.m_offest = indexOffset;
            */
        }

        public static void SetLightmap(GameObject gameObject, string prefabName)
        {
            if (cur_assetName == null) return;
            Info info = m_infos[cur_assetName];
            SetLightmap(gameObject, prefabName, info);
        }

        private static void SetLightmap(GameObject gameObject, string prefabName, Info info)
        {
            if (!info.m_json["prefabList"].Contains(prefabName)) return;

            var subJsonObj = info.m_json["prefabList"][prefabName];
            var renderers = gameObject.GetComponentsInChildren<MeshRenderer>(true);
            for (int j = 0; j < renderers.Length; j++)
            {
                var renderer = renderers[j];
                if (subJsonObj.Contains(renderer.name))
                {
                    var nodeJsonObj = subJsonObj[renderer.name];
                    renderer.lightmapIndex = info.m_indexMap[nodeJsonObj["i"].ToInt32()];
                    var offsetScale = nodeJsonObj["offsetScale"];
                    renderer.lightmapScaleOffset = new Vector4(
                        offsetScale[0].ToFloat(),
                        offsetScale[1].ToFloat(),
                        offsetScale[2].ToFloat(),
                        offsetScale[3].ToFloat()
                    );
                }
            }
        }

        //static private JsonData GetJsonObject(string jsonPath)
        //{
        //    return JsonMapper.ToObject(LGuiGlobal.Tool.LoadText(jsonPath)); ;
        //}

    }
}


