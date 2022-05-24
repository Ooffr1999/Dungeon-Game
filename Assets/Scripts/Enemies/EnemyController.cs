using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class EnemyController : MonoBehaviour
{
    public float _MoveSpeed;
    public LayerMask _obstacles;

    List<Points> openPoints = new List<Points>();
    List<Points> closedPoints = new List<Points>();
    List<Points> pathPoints = new List<Points>();

    [HideInInspector]
    public LevelGen _levelGenerator;

    [HideInInspector]
    public bool isMoving;

    Vector3 destination;
    
    private void Start()
    {
        _levelGenerator = LevelGen._instance;
    }

    #region PathFinding
    public void Move(Vector2Int startPoint, Vector2Int endPoint)
    {
        /*
        if (isMoving)
            return;
        */

        GetPath(startPoint, endPoint);

        if (pathPoints.Count < 1)
            return;

        StartCoroutine(Move_Routine(startPoint, endPoint));
    }

    IEnumerator Move_Routine(Vector2Int start, Vector2Int end)
    {
        Debug.Log("Started pathfinding");

        int pathIterator = 0;

        isMoving = true;

        while (true)
        {
            Vector3 translatedPosition = getWorldPosFromPointPos(pathPoints[pathIterator].position);
            translatedPosition.y = transform.position.y;

            transform.position = Vector3.MoveTowards(transform.position, translatedPosition, _MoveSpeed * Time.deltaTime);

            if (Vector3.Distance(transform.position, translatedPosition) < 1f)
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

    public void UpdatePath(Vector3 start, Vector3 end)
    {
        if (isMoving)
        GetPath(getMapPos(start), getMapPos(end));
    }

    public void Stop()
    {
        StopAllCoroutines();
        isMoving = false;
    }

    void GetPath(Vector2Int startPoint, Vector2Int endPoint)
    {
        ClearPathFinding();

        openPoints.Clear();
        openPoints.Add(getPoint(startPoint, startPoint, endPoint));

        while (true)
        {
            if (openPoints[0].position == endPoint)
            {
                Debug.Log("Got to the end");
                break;
            }

            if (!IteratePathFinding(startPoint, endPoint))
            {
                Debug.LogError("Broke pathfinding loop");
                break;
            }
        }

        GetPathAfterPathFind(startPoint);
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

    bool IteratePathFinding(Vector2Int startPoint, Vector2Int endPoint)
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
                                                    startPoint,
                                                    endPoint,
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
        int pathPointCount = 1;

        pathPoints.Add(openPoints[0]);
        pathPoints.Add(openPoints[0].parentPoint);

        while(true)
        {
            Vector3 currentPosition = getWorldPosFromPointPos(pathPoints[pathPointCount - 1].position);
            currentPosition.y = transform.position.y;

            Vector3 positionToCheck = getWorldPosFromPointPos(pathPoints[pathPointCount].position);
            positionToCheck.y = transform.position.y;

            RaycastHit hit;

            if (pathPoints[pathPointCount].position == start)
            {
                pathPoints.Add(pathPoints[pathPointCount]);
                pathPoints.Reverse();
                break;
            }
            
            if (!Physics.Raycast(currentPosition, positionToCheck - currentPosition, out hit, Vector3.Distance(currentPosition, positionToCheck), _obstacles))
                pathPoints[pathPointCount] = pathPoints[pathPointCount].parentPoint;
            else
            {
                pathPoints.Add(pathPoints[pathPointCount]);
                pathPointCount++;
            }
        }

        /*
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
        */
        
    }

    //Get points adjecent to inserted point and retreive their values
    Points[] getAdjacentPoints(char[,] map, int x, int y, Vector2Int startPos, Vector2Int endPos, Points parentPoint)
    {
        if (x > map.GetLength(0) - 1 || x < 0 || y > map.GetLength(1) - 1 || y < 0)
        {
            Debug.LogError("MapPosition you tried to get points from doesn't exist");
            return null;
        }

        Points[] adjacentPoints = new Points[8];

        if (x + 1 < map.GetLength(0) - 1)
            adjacentPoints[0] = getPoint(new Vector2Int(x + 1, y), startPos, endPos, parentPoint);     //Right
        if (y - 1 > -1)
            adjacentPoints[1] = getPoint(new Vector2Int(x, y - 1), startPos, endPos, parentPoint);     //Down
        if (x - 1 > -1)
            adjacentPoints[2] = getPoint(new Vector2Int(x - 1, y), startPos, endPos, parentPoint);     //Left
        if (y + 1 < map.GetLength(1) - 1)
            adjacentPoints[3] = getPoint(new Vector2Int(x, y + 1), startPos, endPos, parentPoint);     //Up

        //Adding diagonals because Svein came with a good idea
        /*
        adjacentPoints[4] = getPoint(new Vector2Int(x + 1, y + 1), endPos, iteration, parentPoint);     //Right, up
        adjacentPoints[5] = getPoint(new Vector2Int(x + 1, y - 1), endPos, iteration, parentPoint);     //Right, down
        adjacentPoints[6] = getPoint(new Vector2Int(x - 1, y - 1), endPos, iteration, parentPoint);     //Left, down,
        adjacentPoints[7] = getPoint(new Vector2Int(x - 1, y + 1), endPos, iteration, parentPoint);     //Left up
        */

        return adjacentPoints;
    }

    Points getPoint(Vector2Int pointPos, Vector2Int startPos, Vector2Int endPos)
    {
        Points current = new Points();

        current.position = pointPos;

        int distX, distY;

        distX = Math.Abs(pointPos.x - endPos.x);
        distY = Math.Abs(pointPos.y - endPos.y);

        //current.H = Vector2.Distance(pointPos, endPos);

        current.H = distX + distY;
        current.G = Vector2.Distance(startPos, endPos);
        //current.G = iteration;
        current.F = current.H + current.G;

        return current;
    }
    Points getPoint(Vector2Int pointPos, Vector2Int startPos, Vector2Int endPos, Points parentPoint)
    {
        Points current = new Points();

        current.position = pointPos;

        int distX, distY;

        distX = Math.Abs(pointPos.x - endPos.x);
        distY = Math.Abs(pointPos.y - endPos.y);

        //current.H = Vector2.Distance(pointPos, endPos);

        current.H = distX + distY;
        current.G = Vector2.Distance(startPos, endPos);
        //current.G = iteration;
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
        /*
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
        */
        Gizmos.color = Color.green;

        if (pathPoints.Count < 1)
            return;

        for(int i = 0; i < pathPoints.Count; i++)
        {
            Vector3 center = getWorldPosFromPointPos(pathPoints[i].position);
            Gizmos.DrawCube(center, Vector3.one / 2);

            if (i > 0)
                Gizmos.DrawLine(getWorldPosFromPointPos(pathPoints[i - 1].position), getWorldPosFromPointPos(pathPoints[i].position));
        }
    }
    #endregion
}

[System.Serializable]
public class Points
{
    //Distance between target
    public int H;
    //Iteration
    public float G;
    //H + G
    public float F;
    //Current index position
    public Vector2Int position;
    //Parent index position
    public Points parentPoint;
}