using UnityEngine;
using UnityEditor;
using System.IO;
using UObject = UnityEngine.Object;

namespace DOW
{
    public class CreateMatUtils
    {

        [MenuItem("Assets/CreateMat")]
        static public void AddProgressBar(MenuCommand menuCommand)
        {
            UObject[] shaders = Selection.GetFiltered(typeof(Shader), SelectionMode.DeepAssets);
            foreach(var s in shaders)
            {
                Material mat = new Material(s as Shader);
                SaveAsset(mat, GetOutputPath(s));
            }
        }


        static string GetOutputPath(UObject obj)
        {
            string shaderPath = Path.GetDirectoryName(AssetDatabase.GetAssetPath(obj));
            string matPath = shaderPath + "/" + Path.GetFileNameWithoutExtension(obj.name) + ".mat";
            return matPath;
        }


        static void SaveAsset(UObject obj, string path)
        {
            UObject existingAsset = AssetDatabase.LoadMainAssetAtPath(path);
            if (null != existingAsset)
            {
                EditorUtility.CopySerialized(obj, existingAsset);
                AssetDatabase.SaveAssets();
            }
            else
            {
                AssetDatabase.CreateAsset(obj, path);
            }
        }

    }

}