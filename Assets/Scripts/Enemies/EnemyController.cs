using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class EnemyController : MonoBehaviour
{
    public float _MoveSpeed;

    List<Points> openPoints = new List<Points>();
    List<Points> closedPoints = new List<Points>();
    List<Points> pathPoints = new List<Points>();

    public LevelGen _levelGenerator;

    [HideInInspector]
    public bool isMoving;

    private void Start()
    {
        _levelGenerator = LevelGen._instance;
    }

    #region PathFinding
    public void Move(Vector2Int startPoint, Vector2Int endPoint)
    {
        if (isMoving)
            return;

        ClearPathFinding();

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

            if (!IteratePathFinding(iteration, endPoint))
            {
                Debug.LogError("Broke pathfinding loop");
                break;
            }

            iteration++;
        }

        GetPathAfterPathFind(startPoint);

        StartCoroutine(Move_Routine(endPoint));
    }

    IEnumerator Move_Routine(Vector2 end)
    {
        int pathIterator = 0;

        isMoving = true;

        while (true)
        {
            Vector3 translatedPosition = new Vector3(pathPoints[pathIterator].position.x, 0, pathPoints[pathIterator].position.y) * _levelGenerator._sizeModifier;
            translatedPosition += new Vector3(-0.5f, 0, 0.5f);
            translatedPosition.y = transform.position.y;

            transform.position = Vector3.MoveTowards(transform.position, translatedPosition, _MoveSpeed * Time.deltaTime);

            if (Vector3.Distance(transform.position, translatedPosition) < 0.5f)
            {
                if (pathPoints[pathIterator].position == end)
                    break;
                else pathIterator++;
            }

            yield return new WaitForEndOfFrame();
        }

        isMoving = false;

        Debug.Log("On end");
        OnReachDestination();
    }

    public void Stop()
    {
        StopAllCoroutines();
        isMoving = false;
    }

    public virtual void OnReachDestination()
    {
        Debug.Log("On end");
    }

    public Vector2Int getMapPos()
    {
        return new Vector2Int(Mathf.FloorToInt(transform.position.x / _levelGenerator._sizeModifier) + 1, 
                              Mathf.FloorToInt(transform.position.z / _levelGenerator._sizeModifier));
    }

    public Vector2Int getMapPos(Vector3 pos)
    {
        return new Vector2Int(Mathf.FloorToInt(pos.x / _levelGenerator._sizeModifier) + 1,
                              Mathf.FloorToInt(pos.z / _levelGenerator._sizeModifier));
    }

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

    void ClearPathFinding()
    {
        openPoints.Clear();
        closedPoints.Clear();
        pathPoints.Clear();
    }

    void GetPathAfterPathFind(Vector2Int start)
    {   
        pathPoints.Add(openPoints[0]);
        
        while(true)
        {     
            //If the startpoint is found
            if (pathPoints[pathPoints.Count - 1].parentPoint == null)
                break;
            
            //Else add parentpoint to pathlist to be iterated upon next cycle
            pathPoints.Add(pathPoints[pathPoints.Count - 1].parentPoint);
        }

        pathPoints.Reverse();
        
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
    #endregion

    #region Draw Paths
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
    #endregion
}

public static class DDA
{
    #region Raycasting for Pathfinding
    public static bool Cast(Vector2Int start, Vector2Int end, char[,] map)
    {
        //Declare direction of the ray
        Vector2Int dir = end - start;

        Vector2Int steps = start;

        int p = 2 * dir.y - dir.x;

        Debug.Log("Started at " + steps);

        for (int i = 0; i < 100; i++)
        {
            if (p >= 0)
            {
                steps.y += 1;
                p = p + 2 * dir.y - 2 * dir.x;
            }
            else
            {
                p = p + 2 * dir.y;
                steps.x += 1;
            }

            Debug.Log("Moved to " + steps);

            if (steps == end)
                return true;

            if (map[steps.x, steps.y] == '#')
            {
                Debug.Log("Broke off for loop at " + i + " iterations because I hit a wall");
                return false;
            }
        }

        Debug.Log("Iterated a fuckin 100 times with no result");
        return false;

        /*
        //Get direction
        Vector2 rayStart = start;
        Vector2 dir = end - start;
        dir = dir.normalized;

        //Vector2 RayUnitStepSize = new Vector2(Mathf.Sqrt(1f + (dir.y / dir.x) * (dir.y / dir.x)), Mathf.Sqrt(1f + (dir.x / dir.y) * (dir.x / dir.y)));
        float deltaDistX = (dir.x == 0) ? Mathf.Infinity : Mathf.Abs(1 / dir.x);
        float deltaDistY = (dir.y == 0) ? Mathf.Infinity : Mathf.Abs(1 / dir.y);

        Vector2Int mapCheck = Vector2Int.RoundToInt(rayStart);
        Vector2 rayLength1D = new Vector2();

        Vector2Int vStep = Vector2Int.zero;
        
        if (dir.x < 0)
        {
            vStep.x = -1;
            rayLength1D.x = (rayStart.x - (float)mapCheck.x) * deltaDistX;   
        }
        else
        {
            vStep.x = 1;
            rayLength1D.x = ((float)mapCheck.x + 1.0f - rayStart.x) * deltaDistX;
        }

        if (dir.y < 0)
        {
            vStep.y = -1;
            rayLength1D.y = (rayStart.y - (float)mapCheck.y) * deltaDistY;
        }
        else
        {
            vStep.x = 1;
            rayLength1D.y = ((float)mapCheck.y + 1.0f - rayStart.y) * deltaDistY;
        }

        while(true)
        {
            if (rayLength1D.x < rayLength1D.y)
            {
                rayLength1D.x += deltaDistX;
                mapCheck.x += vStep.x;
            }
            else
            {
                rayLength1D.y += deltaDistY;
                mapCheck.y += vStep.y;
            }

            Debug.Log("Raylength 1D = " + rayLength1D);
            Debug.Log("Map grid checked: " + mapCheck);

            //Check results
            if (mapCheck.x > map.GetLength(0) || mapCheck.x < 0)
            {
                Debug.Log("Tried to move out of map");
                return false;
            }
            if (mapCheck.y > map.GetLength(1) || mapCheck.y < 0)
            {
                Debug.Log("Tried to move out of map");
                return false;
            }

            if (mapCheck == end)
                return true;

            switch (map[mapCheck.x, mapCheck.y])
            {
                case '#':
                    return false;
            }
        }
        */
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