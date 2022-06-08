using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Unity.Jobs;

public class NavMeshGeneration : MonoBehaviour
{
    public float checkHeight;
    public float obstacleCheckRange;
    public LayerMask obstacles;

    [SerializeField]
    LevelGen _levelGen;

    [HideInInspector]
    public PathNode[,] navMesh;

    Vector2Int dimension;

    private IEnumerator Start()
    {
        yield return new WaitForEndOfFrame();

        GenMesh();
    }

    public void GenMesh()
    {
        //Generate navmesh size and get map size
        dimension = _levelGen.size;
        navMesh = new PathNode[dimension.x, dimension.y];

        for(int y = 0; y < dimension.y; y++)
        {
            for (int x = 0; x < dimension.x; x++)
            {
                Vector3 rayCastPos = new Vector3(x - 0.5f, checkHeight, y + 0.5f) * _levelGen._sizeModifier;

                RaycastHit hit;
                
                navMesh[x, y] = new PathNode();

                if (!Physics.Raycast(rayCastPos, Vector3.down, out hit, Mathf.Infinity))
                {
                    navMesh[x, y].isStatic = true;
                    continue;
                }

                if (Physics.SphereCast(rayCastPos, obstacleCheckRange, Vector3.down, out hit, Mathf.Infinity))
                {       
                    //If match
                    if (((1 << hit.transform.gameObject.layer) & obstacles) != 0)
                        navMesh[x, y].isWalkable = false;
                    else navMesh[x, y].isWalkable = true;
                }
                
                navMesh[x, y].position = new Vector3(x - 0.5f, 0, y + 0.5f) * _levelGen._sizeModifier;
                navMesh[x, y].index = new Vector2Int(x, y);
            }
        }

        Debug.Log("Generated navmesh");
        Debug.Log(dimension);
    }

    private void OnDrawGizmos()
    {
        for(int y = 0; y < dimension.y; y++)
        {
            for(int x = 0; x < dimension.x; x++)
            {
                if (navMesh[x, y].isStatic)
                    continue;

                switch(navMesh[x, y].isWalkable)
                {
                    //Hit nothing
                    case false:
                        Gizmos.color = Color.red;
                        Gizmos.DrawCube(navMesh[x, y].position, Vector3.one);
                        break;

                    case true:
                        Gizmos.color = Color.blue;
                        Gizmos.DrawCube(navMesh[x, y].position, Vector3.one);
                        break;
                }
            }
        }
    }
}

[System.Serializable]
public class PathNode
{
    public float H;
    public float G;
    public float F;

    public Vector3 position;
    public PathNode parent;
    public Vector2Int index;

    //State checks
    public bool isChecked;
    public bool isOpen; 

    public bool isWalkable;
    public bool isStatic;
}