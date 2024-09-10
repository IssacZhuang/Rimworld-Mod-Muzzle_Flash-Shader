using UnityEngine;
using UnityEditor;
using System.IO;

public class AssetBundlePacker : MonoBehaviour
{
    [MenuItem("Assets/Set AssetBundles")]
    static void SetAssetBundles()
    {
        string path = "Assets/Shaders";

        var assetPaths = Directory.GetFiles(path, "*.*", SearchOption.AllDirectories);

        foreach (var assetPath in assetPaths)
        {

            if (Path.GetExtension(assetPath) == ".meta") continue;


            var assetImporter = AssetImporter.GetAtPath(assetPath);

            if (assetImporter != null)
            {

                assetImporter.assetBundleName = "shaders";
            }
        }

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }

    [MenuItem("Assets/Build AssetBundles")]
    static void BuildAllAssetBundles()
    {
        SetAssetBundles();
        string outputPath = "Assets/AssetBundles";

        if (!Directory.Exists(outputPath))
        {
            Directory.CreateDirectory(outputPath);
        }

        //delete all files in the output directory
        var files = Directory.GetFiles(outputPath);
        foreach (var file in files)
        {
            File.Delete(file);
        }

        BuildBundleForPlatform(outputPath, BuildTarget.StandaloneWindows);
        BuildBundleForPlatform(outputPath, BuildTarget.StandaloneLinux64);
        BuildBundleForPlatform(outputPath, BuildTarget.StandaloneOSX);
    }

    private static void BuildBundleForPlatform(string path, BuildTarget target)
    {
        AssetBundleBuild build = new AssetBundleBuild();
        build.assetBundleName = "shaders" + GetPlatformPostFix(target);
        build.assetNames = AssetDatabase.GetAssetPathsFromAssetBundle("shaders");
        AssetBundleBuild[] builds = new AssetBundleBuild[]{build};

        BuildPipeline.BuildAssetBundles(path, builds, BuildAssetBundleOptions.ForceRebuildAssetBundle, target);
    }

    private static string GetPlatformPostFix(BuildTarget target)
    {
        switch (target)
        {
            case BuildTarget.StandaloneWindows:
                return "-windows";
            case BuildTarget.StandaloneLinux64:
                return "-linux";
            case BuildTarget.StandaloneOSX:
                return "-macos";

        }

        return "-unknown";
    }
}