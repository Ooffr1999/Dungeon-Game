using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class EnemyController : MonoBehaviour
{
    public List<Points> openPoints = new List<Points>();
    public List<Points> closedPoints = new List<Points>();

    LevelGen _levelGenerator;

    private void Start()
    {
        _levelGenerator = LevelGen._instance;
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.U))
        {
            openPoints.Clear();
            openPoints.Add(getPoint(new Vector2Int(4, 2), Vector2Int.zero, 0));
        }
        if (Input.GetKeyDown(KeyCode.O))
            IteratePathFinding(1);
    }

    void IteratePathFinding(int iteration)
    {
        List<Points> newOpenPoints = new List<Points>();
        
        //for (int o = 0; o < openPoints.Count; o++)
        //{
            Debug.Log("Get adjacent points");
            Points[] adjecentPoints = getAdjacentPoints(_levelGenerator.getMap(),
                                                        openPoints[0].position.x,
                                                        openPoints[0].position.y,
                                                        Vector2Int.zero,
                                                        iteration,
                                                        openPoints[0]);

            Debug.Log("Got adjacent points. Beginnging to check them");
            Debug.Log(adjecentPoints[0].position);

            for (int i = 0; i < adjecentPoints.Length; i++)
            {
                if (evaluatePoint(adjecentPoints[i]))
                    newOpenPoints.Add(adjecentPoints[i]);
            }

            Debug.Log("Added new open points");
        //}

        Debug.Log("Finishing up");
        closedPoints.AddRange(openPoints);
        openPoints.Clear();
        openPoints = newOpenPoints;
        //openPoints = openPoints.Distinct().ToList();
        openPoints.Sort((p1, p2) => p1.F.CompareTo(p2.F));
        
        Debug.Log("Done");
    }

    //Get points adjecent to inserted point and retreive their values
    Points[] getAdjacentPoints(char[,] map, int x, int y, Vector2Int endPos, int iteration, Points parentPoint)
    {
        if (x > map.GetLength(0) - 1 || x < 0 || y > map.GetLength(1) - 1 || y < 0)
        {
            Debug.LogError("MapPosition you tried to get points from doesn't exist");
            return null;
        }

        Points[] adjacentPoints = new Points[4];

        if (x + 1 < map.GetLength(0) - 1)
            adjacentPoints[0] = getPoint(new Vector2Int(x + 1, y), endPos, iteration, parentPoint);
        if (y - 1 > -1)
            adjacentPoints[1] = getPoint(new Vector2Int(x, y - 1), endPos, iteration, parentPoint);
        if (x - 1 > -1)
            adjacentPoints[2] = getPoint(new Vector2Int(x - 1, y), endPos, iteration, parentPoint);
        if (y + 1 < map.GetLength(1) - 1)
            adjacentPoints[3] = getPoint(new Vector2Int(x, y + 1), endPos, iteration, parentPoint);

        return adjacentPoints;
    }

    Points getPoint(Vector2Int pointPos, Vector2Int endPos, int iteration)
    {
        Points current = new Points();

        current.position = pointPos;
        current.H = Vector2.Distance(pointPos, endPos);
        current.G = iteration;
        current.F = current.H + current.G;

        return current;
    }
    Points getPoint(Vector2Int pointPos, Vector2Int endPos, int iteration, Points parentPoint)
    {
        Points current = new Points();

        current.position = pointPos;
        current.H = Vector2.Distance(pointPos, endPos);
        current.G = iteration;
        current.F = current.H + current.G;
        current.parentPoint = parentPoint;

        return current;
    }

    bool evaluatePoint(Points point)
    {
        if (_levelGenerator.getMap()[point.position.x, point.position.y] == '#')
            return false;
        if (_levelGenerator.getMap()[point.position.x, point.position.y] == '\0')
            return false;
        if (closedPoints.Contains(point))
            return false;
        if (openPoints.Contains(point))
            return false;

        return true;
    }

    Vector3 getWorldPosFromPointPos(Vector2Int pos)
    {
        return new Vector3(pos.x - 0.5f, 0, pos.y + 0.5f) * _levelGenerator._sizeModifier;
    }

    IEnumerator moveToPoint(Vector2 position)
    {
        yield return new WaitForSeconds(1);
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;

        for(int i = 0; i < openPoints.Count; i++)
        {
            Vector3 center = getWorldPosFromPointPos(openPoints[i].position);
            Gizmos.DrawCube(center, Vector3.one / 2);
        }

        Gizmos.color = Color.blue;

        for (int i = 0; i < closedPoints.Count; i++)
        {
            Vector3 center = getWorldPosFromPointPos(closedPoints[i].position);
            Gizmos.DrawCube(center, Vector3.one / 2);
        }
    }
}

[System.Serializable]
public class Points
{
    //Distance between target
    public float H;
    //Iteration
    public int G;
    //H + G
    public float F;
    //Current index position
    public Vector2Int position;
    //Parent index position
    public Points parentPoint;
}