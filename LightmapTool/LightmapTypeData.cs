using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace YLib.Lightmap
{
    [System.Serializable]
    [CreateAssetMenu(fileName = "LightmapTypeData", menuName = "�ҵĽű�����/LightmapTypeData")]
    public class LightmapTypeData : SerializedScriptableObject
    {
        private static LightmapTypeData _inst;
        public static LightmapTypeData Inst
        {
            get
            {
#if UNITY_EDITOR
                if (_inst == null)
                {
                    var guids = UnityEditor.AssetDatabase.FindAssets($"t:LightmapTypeData");
                    if (guids.Length > 0)
                    {
                        _inst = UnityEditor.AssetDatabase.LoadAssetAtPath<LightmapTypeData>(UnityEditor.AssetDatabase.GUIDToAssetPath(guids[0]));
                    }
                }
#endif
                return _inst;
            }
        }

        [SerializeField]
        public Dictionary<int, Info> typeMap = new Dictionary<int, Info>();

        [SerializeField]
        public AmbientColor Ambient = new AmbientColor();

        private ValueDropdownList<int> propertys;
        public ValueDropdownList<int> Propertys
        {
            get
            {
                if (propertys == null)
                {
                    propertys = new ValueDropdownList<int>();
                }
                else
                {
                    propertys.Clear();
                }

                foreach (var item in typeMap)
                {
                    propertys.Add(item.Value.name, item.Key);
                }
                return propertys;
            }
        }

        public enum SavePrefabType
        {
            [LabelText("������Ԥ�Ƽ�")]
            None = 0,
            [LabelText("��������Ԥ�Ƽ�")]
            SaveContainer,
            [LabelText("��������Ԥ�Ƽ�")]
            SaveAll,
        }

        [System.Serializable]
        [HideReferenceObjectPicker]
        public class Info
        {
            public string name;
#if UNITY_EDITOR
            public UnityEditor.SceneAsset scene;
#endif
            public SavePrefabType type;
        }

        [System.Serializable]
        public class AmbientColor 
        {
            public Color Morning_AmbientColor = Color.white;
            public Color Evening_AmbientColor = Color.white;

           
        }


    }
}

