/*
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(LevelGen))]
public class LevelGen_Editor : Editor
{
    
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        LevelGen _levelGen = (LevelGen)target;

        if (GUILayout.Button("Generate"))
            _levelGen.DrawLevelLayout();
        if (GUILayout.Button("New Seed"))
            _levelGen.GetNewSeed();
    }
}
*/