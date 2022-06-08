using UnityEngine;
using UnityEditor;

public class MapManager_Editor : EditorWindow
{
    string seed;
    Texture2D mapTex;

    [MenuItem("Window/Map Control")]
    public static void showWindow()
    {
        GetWindow<MapManager_Editor>("Map Control");
    }

    private void OnGUI()
    {
        //Window Code
        GUILayout.Label("Map stuff", EditorStyles.boldLabel);

        if (GUILayout.Button("Generate Seed"))
            seed = LevelGen.GetNewSeed().ToString();

        seed = (GUILayout.TextField(seed.ToString(), seed));

        

        if (GUILayout.Button("Generate Map"))
            mapTex = DrawMap();

        GUILayout.BeginHorizontal();

        if (mapTex != null)
            GUI.Label(new Rect(650, 650, 100, 100), mapTex);
    }

    Texture2D DrawMap()
    {
        Texture2D mapTex = AssetPreview.GetAssetPreview(LevelGen.DrawLevelLayout(int.Parse(seed)));
        return mapTex;
    }
}
