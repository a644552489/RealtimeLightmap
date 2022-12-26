using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace Utility
{
    public class DynamicLightMapItem : MonoBehaviour
    {
        [SerializeField]
        public string prefabName;

        [SerializeField]
        public List<Renderer> rendererList = new List<Renderer>();

        [HideInInspector]
        public List<string> objectPathList = new List<string>();

        private void OnEnable()
        {
            LightingMapMgr.SetLightmap(gameObject, prefabName);
        }

        public int AddRendererToList(Renderer renderer)
        {
            rendererList.Add(renderer);

            return rendererList.Count - 1;
        }

        //[Sirenix.OdinInspector.Button]
        public void RecordCurRendererPath()
        {
            objectPathList.Clear();
            foreach (var renderer in rendererList)
            {
                var go = renderer.gameObject;

                var path = go.name;
                var parent = go.transform.parent;

                while (parent != null && parent != transform)
                {

                    path = $"{parent.name}/{path}";
                    parent = parent.transform.parent;
                }

                objectPathList.Add(path);
            }
        }

        //[Sirenix.OdinInspector.Button]
        public void RevertRenderer()
        {
            var count = objectPathList.Count;
            for (int i = 0; i < count; i++)
            {
                rendererList[i] = transform.Find(objectPathList[i])?.GetComponent<Renderer>();
            }
        }

    }

}
