using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class EnemyController : MonoBehaviour
{
    public List<Points> openPoints = new List<Points>();
    public List<Points> closedPoints = new List<Points>();
    public List<Points> pathPoints = new List<Points>();

    LevelGen _levelGenerator;

    private void Start()
    {
        _levelGenerator = LevelGen._instance;
    }

    private void Update()
    {
        Vector2Int startPoint = new Vector2Int(53, 17);
        Vector2Int endPoint = new Vector2Int(51, 17);

        if (Input.GetKeyDown(KeyCode.U))
            StartCoroutine(moveToPoint(startPoint, endPoint));
    }

    #region PathFinding
    bool IteratePathFinding(int iteration, Vector2Int endPoint)
    {
        //Check if endpoint is on valid squares
        #region Verifying space
        if (_levelGenerator.getMapSquareData(endPoint) == '#')
        {
            Debug.LogError("Pathfinding endpoint was not at a viable space on the map");
            return false;
        }
        if (_levelGenerator.getMapSquareData(endPoint) == '\0')
        {
            Debug.LogError("Pathfinding endpoint was not at a viable space on the map");
            return false;
        }
        
        //Check if endpoint is on the map
        if (endPoint.x > _levelGenerator.getMap().GetLength(0) - 1 || 
            endPoint.x < 0 || 
            endPoint.y > _levelGenerator.getMap().GetLength(1) - 1 ||
            endPoint.y < 0)
        {
            Debug.LogError("Pathfinding endpoint was not on the map");
            return false;
        }
        #endregion

        List<Points> newOpenPoints = new List<Points>();

        Points[] adjecentPoints = getAdjacentPoints(_levelGenerator.getMap(),
                                                    openPoints[0].position.x,
                                                    openPoints[0].position.y,
                                                    endPoint,
                                                    iteration,
                                                    openPoints[0]);

        for (int i = 0; i < adjecentPoints.Length; i++)
        {
            if (adjecentPoints[i] == null)
                continue;

            if (evaluatePoint(adjecentPoints[i]))
                newOpenPoints.Add(adjecentPoints[i]);
        }

        closedPoints.Add(openPoints[0]);
        openPoints.Remove(openPoints[0]);

        openPoints.AddRange(newOpenPoints);
        openPoints.Sort((p1, p2) => p1.F.CompareTo(p2.F));

        return true;
    }

    void GetPathAfterPathFind()
    {
        pathPoints.Add(openPoints[0]);

        while(true)
        {
            if (pathPoints[pathPoints.Count - 1].parentPoint == null)
            {
                Debug.Log("Found entire path");
                break;
            }
            
            pathPoints.Add(pathPoints[pathPoints.Count - 1].parentPoint);
        }
    }

    //Get points adjecent to inserted point and retreive their values
    Points[] getAdjacentPoints(char[,] map, int x, int y, Vector2Int endPos, int iteration, Points parentPoint)
    {
        if (x > map.GetLength(0) - 1 || x < 0 || y > map.GetLength(1) - 1 || y < 0)
        {
            Debug.LogError("MapPosition you tried to get points from doesn't exist");
            return null;
        }

        Points[] adjacentPoints = new Points[8];

        if (x + 1 < map.GetLength(0) - 1)
            adjacentPoints[0] = getPoint(new Vector2Int(x + 1, y), endPos, iteration, parentPoint);     //Right
        if (y - 1 > -1)
            adjacentPoints[1] = getPoint(new Vector2Int(x, y - 1), endPos, iteration, parentPoint);     //Down
        if (x - 1 > -1)
            adjacentPoints[2] = getPoint(new Vector2Int(x - 1, y), endPos, iteration, parentPoint);     //Left
        if (y + 1 < map.GetLength(1) - 1)
            adjacentPoints[3] = getPoint(new Vector2Int(x, y + 1), endPos, iteration, parentPoint);     //Up

        //Adding diagonals because Svein came with a good idea
        /*
        adjacentPoints[4] = getPoint(new Vector2Int(x + 1, y + 1), endPos, iteration, parentPoint);     //Right, up
        adjacentPoints[5] = getPoint(new Vector2Int(x + 1, y - 1), endPos, iteration, parentPoint);     //Right, down
        adjacentPoints[6] = getPoint(new Vector2Int(x - 1, y - 1), endPos, iteration, parentPoint);     //Left, down,
        adjacentPoints[7] = getPoint(new Vector2Int(x - 1, y + 1), endPos, iteration, parentPoint);     //Left up
        */

        return adjacentPoints;
    }

    Points getPoint(Vector2Int pointPos, Vector2Int endPos, int iteration)
    {
        Points current = new Points();

        current.position = pointPos;

        int distX, distY;

        distX = Math.Abs(pointPos.x - endPos.x);
        distY = Math.Abs(pointPos.y - endPos.y);

        //current.H = Vector2.Distance(pointPos, endPos);

        current.H = distX + distY;
        current.G = iteration;
        current.F = current.H + current.G;

        return current;
    }
    Points getPoint(Vector2Int pointPos, Vector2Int endPos, int iteration, Points parentPoint)
    {
        Points current = new Points();

        current.position = pointPos;

        int distX, distY;

        distX = Math.Abs(pointPos.x - endPos.x);
        distY = Math.Abs(pointPos.y - endPos.y);

        //current.H = Vector2.Distance(pointPos, endPos);

        current.H = distX + distY;
        current.G = iteration;
        current.F = current.H + current.G;
        current.parentPoint = parentPoint;

        return current;
    }

    bool evaluatePoint(Points point)
    {
        Points evaluatePoint = new Points();

        //Check closed points for point
        evaluatePoint = closedPoints.Find(p => p.position == point.position);
        if (evaluatePoint != null)
            return false;

        //Check open points for point
        evaluatePoint = openPoints.Find(p => p.position == point.position);
        if (evaluatePoint != null)
            return false;

        //Check if point is available 
        if (_levelGenerator.getMap()[point.position.x, point.position.y] == '#')
            return false;
        if (_levelGenerator.getMap()[point.position.x, point.position.y] == '\0')
            return false;

        return true;
    }

    Vector3 getWorldPosFromPointPos(Vector2Int pos)
    {
        return new Vector3(pos.x - 0.5f, 0, pos.y + 0.5f) * _levelGenerator._sizeModifier;
    }

    IEnumerator moveToPoint(Vector2Int startPoint, Vector2Int endPoint)
    {
        int iteration = 1;

        openPoints.Clear();
        openPoints.Add(getPoint(startPoint, endPoint, 0));

        while (true)
        {
            if (openPoints[0].position == endPoint)
            {
                Debug.Log("Got to the end");
                break;
            }

            //yield return new WaitForEndOfFrame();

            if (!IteratePathFinding(iteration, endPoint))
            {
                Debug.LogError("Broke pathfinding loop");
                break;
            }

            iteration++;
        }

        GetPathAfterPathFind();

        yield return 0;
        
    }
    #endregion

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

        Gizmos.color = Color.green;

        for(int i = 0; i < pathPoints.Count; i++)
        {
            Vector3 center = getWorldPosFromPointPos(pathPoints[i].position);
            Gizmos.DrawCube(center, Vector3.one / 2);
        }
    }
}

public static class DDA
{
    #region Raycasting for Pathfinding
    public static bool Cast(Vector2Int start, Vector2Int end)
    {
        //Get direction
        Vector2 dir = end - start;
        dir = dir.normalized;

        Vector2 RayUnitStepSize = new Vector2(Mathf.Sqrt(1 + (dir.y / dir.x) * (dir.y / dir.x)), Mathf.Sqrt(1 + (dir.x / dir.y) * dir.x / dir.y));

        Vector2Int mapCheck = start;
        Vector2 rayLength1D = new Vector2Int();

        Vector2Int vStep = new Vector2Int();

        if (dir.x < 0)
        {
            vStep.x = -1;
            rayLength1D.x = (start.x - mapCheck.x) * RayUnitStepSize.x;
        }
        else
        {
            vStep.x = 1;
        }

        if (dir.y < 0)
        {
            vStep.y = -1;
        }
        else
        {
            vStep.y = 1;
        }

        return true;
    }

    #endregion
}

[System.Serializable]
public class Points
{
    //Distance between target
    public int H;
    //Iteration
    public int G;
    //H + G
    public float F;
    //Current index position
    public Vector2Int position;
    //Parent index position
    public Points parentPoint;
}