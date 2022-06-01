using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class EnemyController : MonoBehaviour
{
    public float _moveSpeed;

    public Transform player;

    PathNode[,] navMesh;
    public List<PathNode> openNodes = new List<PathNode>();
    public List<PathNode> path = new List<PathNode>();

    private IEnumerator Start()
    {
        yield return new WaitForSeconds(1);

        GetNavMesh();

        while (true)
        {
            yield return new WaitForSeconds(.1f);

            if (IncrementPathFinding(transform.position, player.transform.position))
                break;
        }

        GetFoundPath(transform.position, player.transform.position);

        Debug.Log("Found end");
    }

    //Retreive the Navmesh Data from current NavMeshGeneration object
    public void GetNavMesh()
    {
        navMesh = FindObjectOfType<NavMeshGeneration>().navMesh;
    }

    public bool IncrementPathFinding(Vector3 start, Vector3 end)
    {
        List<PathNode> openPoints = new List<PathNode>();

        for (int y = 0; y < navMesh.GetLength(1); y++)
        {
            for (int x = 0; x < navMesh.GetLength(0); x++)
            {
                if (!navMesh[x, y].isChecked && navMesh[x, y].isOpen)
                    openPoints.Add(navMesh[x, y]);
            }
        }

        if (openPoints.Count == 0)
        {
            //SetPathNode(GetPathNode(), start, end);
            GetPathNode().isOpen = true;
            return false;
        }

        openPoints.Sort((p1, p2) => p1.F.CompareTo(p2.F));
        //openPoints.Reverse();

        PathNode[] neighbourNodes = getNeighboursofIndex(openPoints[0].index.x, openPoints[0].index.y);

        for (int i = 0; i < neighbourNodes.Length; i++)
        {
            if (evaluatePathNode(neighbourNodes[i]))
            {
                neighbourNodes[i] = SetPathNode(neighbourNodes[i], start, end, openPoints[0]);
                neighbourNodes[i].isOpen = true;
            }
        }

        openPoints[0].isChecked = true;
        openPoints[0].isOpen = false;
        
        openNodes = openPoints;
        
        if (openPoints[0].position == GetPathNode(end).position)
            return true;

        return false;
    }

    public void GetFoundPath(Vector3 start, Vector3 end)
    {
        path.Add(GetPathNode(end));

        while(true)
        {
            path.Add(path[path.Count - 1].parent);
            
            if (path[path.Count - 1].position == start)
                break;
        }
    }

    public PathNode[] getNeighboursofIndex(int index_X, int index_Y)
    {
        PathNode[] neighbours = new PathNode[4];

        if (index_X + 1 < navMesh.GetLength(0) + 1)
            neighbours[0] = navMesh[index_X + 1, index_Y];
        if (index_Y - 1 > -1)
            neighbours[1] = navMesh[index_X, index_Y - 1];
        if (index_X - 1 > -1)
            neighbours[2] = navMesh[index_X - 1, index_Y];
        if (index_Y + 1 < navMesh.GetLength(1) + 1)
            neighbours[3] = navMesh[index_X, index_Y + 1];

        return neighbours;
    }

    public bool evaluatePathNode(PathNode node)
    {
        if (node.isStatic)
            return false;

        if (!node.isWalkable)
            return false;

        if (node.isChecked && !node.isOpen)
            return false;

        return true;
    }

    //Find path after tracking
    public 

    //Gets this transforms path node
    PathNode GetPathNode()
    {
        if (navMesh == null)
            return null;

        Vector2Int index = Vector2Int.one * 32000;

        for (int y = 0; y < navMesh.GetLength(1); y++)
        {
            for (int x = 0; x < navMesh.GetLength(0); x++)
            {
                if (navMesh[x, y] == null)
                    continue;

                if (index.x > navMesh.GetLength(0))
                {
                    index = new Vector2Int(x, y);
                    continue;
                }

                if (Vector3.Distance(transform.position, navMesh[x, y].position) < Vector3.Distance(transform.position, navMesh[index.x, index.y].position))
                    index = new Vector2Int(x, y);
            }
        }

        return navMesh[index.x, index.y];
    }

    //Gets pathnode of assigned transform
    PathNode GetPathNode(Vector3 target)
    {
        if (navMesh == null)
            return null;

        Vector2Int index = Vector2Int.one * 32000;

        for (int y = 0; y < navMesh.GetLength(1); y++)
        {
            for (int x = 0; x < navMesh.GetLength(0); x++)
            {
                if (navMesh[x, y] == null)
                    continue;

                if (index.x > navMesh.GetLength(0))
                {
                    index = new Vector2Int(x, y);
                    continue;
                }

                if (Vector3.Distance(target, navMesh[x, y].position) < Vector3.Distance(target, navMesh[index.x, index.y].position))
                    index = new Vector2Int(x, y);
            }
        }

        Gizmos.color = Color.green;

        for (int i = 0; i < path.Count - 1; i++)
        {
            if (i + 1 > path.Count - 1)
                break;

            Gizmos.DrawLine(path[i].position, path[i + 1].position);
        }

        return navMesh[index.x, index.y];
    }

    //Calculate the necessary values of the pathnode
    PathNode SetPathNode(PathNode node, Vector3 start, Vector3 end)
    {
        node.H = Vector3.Distance(node.position, start);
        node.G = Vector3.Distance(node.position, end);
        node.F = node.H + node.G;

        return node;
    }

    PathNode SetPathNode(PathNode node, Vector3 start, Vector3 end, PathNode parent)
    {
        node.H = Vector3.Distance(node.position, end);
        node.G = Vector3.Distance(node.position, start);
        node.F = node.H + node.G;

        node.parent = parent;

        return node;
    }

    //Draw path
    private void OnDrawGizmosSelected()
    {
        if (navMesh == null)
            return;

        GetNavMesh();

        Gizmos.color = Color.red;

        for (int y = 0; y < navMesh.GetLength(1); y++)
        {
            for (int x = 0; x < navMesh.GetLength(0); x++)
            {
                if (!navMesh[x, y].isChecked && navMesh[x, y].isOpen)
                    Gizmos.DrawCube(navMesh[x, y].position, Vector3.one * 1.5f);
            }
        }
    }
}