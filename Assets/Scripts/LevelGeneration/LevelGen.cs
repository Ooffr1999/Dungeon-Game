using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using RoomGen;
using Pathfinding;

public class LevelGen : MonoBehaviour
{
    public int seed;
    public Vector2Int size;
    public GameObject[] floorPlanes;
    public GameObject[] wallPlanes;
    public GameObject[] doors;
    public GameObject chest;

    [Space(10)]
    public float _sizeModifier;

    [Header("Player")]
    public GameObject player;

    [Header("Stairs")]
    public GameObject stairs;

    [Header("Map Chest")]
    public GameObject mapChest;

    [HideInInspector]
    char[,] map;

    [HideInInspector]
    public List<GameObject> _floorPool;
    [HideInInspector]
    public List<GameObject> _wallPool;
    [HideInInspector]
    public List<GameObject> _doorPool;
    [HideInInspector]
    public List<GameObject> _chestPool;

    [HideInInspector]
    public static LevelGen _instance;

    Vector2Int startPos;
    Vector2Int endPos;

    private void Awake()
    {
        if (_instance != null)
            Destroy(this.gameObject);
        else _instance = this;
    }

    private void Start()
    {
        InitPool();
        MakeLevel();
    }

    public static int GetNewSeed()
    {
        Random.InitState(System.Environment.TickCount);
        int seed = Random.Range(-100000, 100000);

        return seed;
    }

    #region Draw Map
    public static Texture2D DrawLevelLayout(int seed)
    {
        char[,] map = MapGen.GetCatacombMap(40, 40, seed);

        Texture2D mapTex = new Texture2D(map.GetLength(0), map.GetLength(1), TextureFormat.RGB24, true);
        mapTex.filterMode = FilterMode.Point;
        mapTex.wrapMode = TextureWrapMode.Clamp;
        
        for (int y = 0; y < map.GetLength(1); y++)
        {
            for (int x = 0; x < map.GetLength(0); x++)
            {
                switch(map[x, y])
                {
                    case '.':
                        mapTex.SetPixel(x, y, Color.white);
                        break;

                    case '#':
                        mapTex.SetPixel(x, y, Color.gray);
                        break;

                    case 'D':
                        mapTex.SetPixel(x, y, Color.black);
                        break;

                    default:
                        mapTex.SetPixel(x, y, Color.black);
                        break;
                }
            }
        }

        mapTex.Apply();
        return mapTex;
    }

    public Texture2D DrawLevelLayout(Transform target)
    {
        map = MapGen.GetCatacombMap(size.x, size.y, seed);

        Texture2D mapTex = new Texture2D(map.GetLength(0), map.GetLength(1), TextureFormat.RGB24, true);
        mapTex.filterMode = FilterMode.Point;
        mapTex.wrapMode = TextureWrapMode.Clamp;

        for (int y = 0; y < map.GetLength(1); y++)
        {
            for (int x = 0; x < map.GetLength(0); x++)
            {
                switch (map[x, y])
                {
                    case '.':
                        mapTex.SetPixel(x, y, Color.white);
                        break;

                    case '#':
                        mapTex.SetPixel(x, y, Color.gray);
                        break;

                    case 'D':
                        mapTex.SetPixel(x, y, Color.black);
                        break;

                    case 'S':
                        mapTex.SetPixel(x, y, Color.white);
                        startPos = new Vector2Int(x, y);
                        break;

                    case 'E':
                        mapTex.SetPixel(x, y, Color.black);
                        endPos = new Vector2Int(x, y);
                        break;

                    default:
                        mapTex.SetPixel(x, y, Color.black);
                        break;
                }
            }
        }

        mapTex.SetPixel(getMapPos(target.position).x, getMapPos(target.position).y, Color.red);

        mapTex.Apply();
        return mapTex;
    }
    #endregion

    void GenerateLevel()
    {
        char[,] map = MapGen.GetCatacombMap(size.x, size.y, seed);

        int floorPiecesUsed = 0;
        int wallPieceUsed = 0;
        int doorPieceUsed = 0;

        for (int y = 0; y < map.GetLength(1); y++)
        {
            for (int x = 0; x < map.GetLength(0); x++)
            {  
                switch(map[x, y])
                {
                    //Place floor tiles
                    case '.':
                        _floorPool[floorPiecesUsed].transform.position = new Vector3(x, 0, y) * _sizeModifier;
                        _floorPool[floorPiecesUsed].SetActive(true);
                        floorPiecesUsed++;
                        break;

                    case 'S':
                        _floorPool[floorPiecesUsed].transform.position = new Vector3(x, 0, y) * _sizeModifier;
                        _floorPool[floorPiecesUsed].SetActive(true);
                        floorPiecesUsed++;
                        break;
                    
                    //Place stairs
                    case 'E':
                        stairs.transform.localScale = Vector3.one * _sizeModifier;
                        stairs.transform.position = (new Vector3(x, 0, y) + new Vector3(-0.5f, 0.5f, 0.5f)) * _sizeModifier;
                        break;

                    //Place door
                    case 'D':
                        _floorPool[floorPiecesUsed].transform.position = new Vector3(x, 0, y) * _sizeModifier;
                        _floorPool[floorPiecesUsed].SetActive(true);
                        floorPiecesUsed++;

                        _doorPool[doorPieceUsed].transform.position = new Vector3(x, 0, y) * _sizeModifier;

                        switch(RoomEngine.MarchThroughMap(map, '#', x, y))
                        {
                            case 5:
                                _doorPool[doorPieceUsed].transform.eulerAngles = Vector3.up * 90;
                                break;

                            case 10:
                                _doorPool[doorPieceUsed].transform.eulerAngles = Vector3.up * 0;
                                break;
                        }

                        _doorPool[doorPieceUsed].SetActive(true);
                        doorPieceUsed++;

                        break;
                }

                //Place wall
                switch(EvaluateForWallPlacement(map, x, y, wallPieceUsed))
                {
                    case 1:
                        wallPieceUsed++;
                        break;

                    case 2:
                        wallPieceUsed++;
                        break;

                    case 3:
                        wallPieceUsed += 2;
                        break;

                    case 4:
                        wallPieceUsed++;
                        break;

                    case 5:
                        wallPieceUsed += 2;
                        break;

                    case 6:
                        wallPieceUsed += 2;
                        break;

                    case 7:
                        wallPieceUsed += 3;
                        break;

                    case 8:
                        wallPieceUsed++;
                        break;

                    case 9:
                        wallPieceUsed += 2;
                        break;

                    case 10:
                        wallPieceUsed += 2;
                        break;

                    case 11:
                        wallPieceUsed += 3;
                        break;

                    case 12:
                        wallPieceUsed += 2;
                        break;

                    case 13:
                        wallPieceUsed += 3;
                        break;

                    case 14:
                        wallPieceUsed += 3;
                        break;

                    case 15:
                        wallPieceUsed += 4;
                        break;
                }
            }
        }

        //Place chests
        int chestAmount = Random.Range(2, 6);

        Debug.Log("Placing " + chestAmount + " chests");
        for (int i = 0; i < chestAmount; i++)
        {
            while (true)
            {
                Vector2Int pos = RoomEngine.getRandomMapPos(map);
                int index = RoomEngine.MarchThroughMap(map, '.', pos.x, pos.y);
                
                if (index == 15)
                {
                    _chestPool[i].SetActive(true);
                    _chestPool[i].transform.position = new Vector3(pos.x - 0.5f, 0, pos.y + 0.5f) * _sizeModifier;
                    break;
                }
            }
        }

        //Place Map chest
        while(true)
        {
            Vector2Int pos = RoomEngine.getRandomMapPos(map);
            int index = RoomEngine.MarchThroughMap(map, '.', pos.x, pos.y);

            if (index == 15)
            {
                mapChest.SetActive(true);
                //mapChest.transform.localScale = Vector3.one * _sizeModifier;
                mapChest.transform.position = new Vector3(pos.x - 0.5f, 0, pos.y + 0.5f) * _sizeModifier;
                break;
            }
        }

        //Enable player
        player.GetComponent<CharacterController>().enabled = false;
        player.transform.position = getStartPosition(map) * _sizeModifier;
        player.GetComponent<CharacterController>().enabled = true;
    }
    
    void InitPool()
    {
        //Floor pool
        for (int i = 0; i < size.x * size.y; i++)
        {
            int rand = Random.Range(0, floorPlanes.Length);
            GameObject floorPiece = Instantiate(floorPlanes[rand], floorPlanes[rand].transform.position, floorPlanes[rand].transform.rotation);
            floorPiece.transform.localScale *= _sizeModifier;
            floorPiece.transform.parent = this.transform;
            _floorPool.Add(floorPiece);
            floorPiece.SetActive(false);
        }

        //Wall Pool
        for (int i = 0; i < size.x * size.y * 4; i++)
        {
            GameObject wallPiece = Instantiate(wallPlanes[0], wallPlanes[0].transform.position, wallPlanes[0].transform.rotation);
            wallPiece.transform.localScale *= _sizeModifier;
            wallPiece.transform.parent = this.transform;
            _wallPool.Add(wallPiece);
            wallPiece.SetActive(false);
        }
        
        //Door pool
        for (int i = 0; i < size.x * size.y / 2; i++)
        {
            GameObject door = Instantiate(doors[0], doors[0].transform.position, doors[0].transform.rotation);
            door.transform.localScale *= _sizeModifier;
            door.transform.parent = this.transform;
            _doorPool.Add(door);
            door.SetActive(false);
        }

        //Chest pool
        for (int i = 0; i < 50; i++)
        {
            GameObject _chest = Instantiate(chest, chest.transform.position, chest.transform.rotation);
            _chest.transform.parent = this.transform;
            _chestPool.Add(_chest);
            chest.SetActive(false);
        }
    }
    
    void ClearRoom()
    {
        for (int i = 0; i < _floorPool.Count; i++)
        {
            _floorPool[i].SetActive(false);
        }

        for (int i = 0; i < _wallPool.Count; i++)
        {
            _wallPool[i].transform.eulerAngles = Vector3.zero;
            _wallPool[i].SetActive(false);
        }

        for (int i = 0; i < _doorPool.Count; i++)
        {
            _doorPool[i].transform.eulerAngles = Vector3.zero;
            _doorPool[i].GetComponent<Collider>().enabled = true;
            _doorPool[i].SetActive(false);
        }

        for (int i = 0; i < _chestPool.Count; i++)
        {
            _chestPool[i].transform.eulerAngles = chest.transform.eulerAngles;
            _chestPool[i].GetComponent<Container_Behaviour>().ResetContainer();
        }

        mapChest.GetComponent<Map_Container_Behaviour>().ResetContainer();
    }
    
    public void MakeLevel()
    {
        StartCoroutine(MakeLevelRoutine());
    }

    IEnumerator MakeLevelRoutine()
    {
        MapAndCharacterBehaviour._instance.ClearMapTexture();
        ClearRoom();
        GenerateLevel();

        yield return new WaitForEndOfFrame();

        AstarPath.active.Scan();
    }
    
    float EvaluateForWallPlacement(char[,] map, int x, int y, int poolIndex)
    {
        if (map[x, y] != '#')
            return 0;

        Vector3 currentPos = new Vector3(x, 0, y);

        Vector3 _northAdditionPos = Vector3.forward;
        Vector3 _eastAdditionPos = Vector3.zero;
        Vector3 _southAdditionPos = Vector3.right;
        Vector3 _westAdditionPos = Vector3.left + Vector3.forward;

        Vector3 _northAdditionRot = Vector3.zero;
        Vector3 _eastAdditionRot = Vector3.up * 90;
        Vector3 _southAdditionRot = Vector3.up * 180;
        Vector3 _westAdditionRot = Vector3.up * 270;
 
        int index = RoomEngine.MarchThroughMap(map, '.', x, y);
        index += RoomEngine.MarchThroughMap(map, 'D', x, y);

        switch(index)
        {
            case 1:
                _wallPool[poolIndex].transform.position = (currentPos * _sizeModifier) + (_northAdditionPos * _sizeModifier);
                _wallPool[poolIndex].transform.eulerAngles += _northAdditionRot;
                _wallPool[poolIndex].SetActive(true);
                break;

            case 2:
                _wallPool[poolIndex].transform.position = (currentPos * _sizeModifier) + (_eastAdditionPos * _sizeModifier);
                _wallPool[poolIndex].transform.eulerAngles = _eastAdditionRot;
                _wallPool[poolIndex].SetActive(true);
                break;

            case 3:
                _wallPool[poolIndex].transform.position = (currentPos * _sizeModifier) + (_northAdditionPos * _sizeModifier);
                _wallPool[poolIndex].transform.eulerAngles += _northAdditionRot;
                _wallPool[poolIndex].SetActive(true);

                _wallPool[poolIndex + 1].transform.position = (currentPos * _sizeModifier) + (_eastAdditionPos * _sizeModifier);
                _wallPool[poolIndex + 1].transform.eulerAngles = _eastAdditionRot;
                _wallPool[poolIndex + 1].SetActive(true);
                break;

            case 4:
                _wallPool[poolIndex].transform.position = (currentPos * _sizeModifier) - (_southAdditionPos * _sizeModifier);
                _wallPool[poolIndex].transform.eulerAngles = _southAdditionRot;
                _wallPool[poolIndex].SetActive(true);
                break;

            case 5:
                _wallPool[poolIndex].transform.position = (currentPos * _sizeModifier) + (_northAdditionPos * _sizeModifier);
                _wallPool[poolIndex].transform.eulerAngles += _northAdditionRot;
                _wallPool[poolIndex].SetActive(true);

                _wallPool[poolIndex + 1].transform.position = (currentPos * _sizeModifier) - (_southAdditionPos * _sizeModifier);
                _wallPool[poolIndex + 1].transform.eulerAngles = _southAdditionRot;
                _wallPool[poolIndex + 1].SetActive(true);
                break;

            case 6:
                _wallPool[poolIndex].transform.position = (currentPos * _sizeModifier) + (_eastAdditionPos * _sizeModifier);
                _wallPool[poolIndex].transform.eulerAngles = _eastAdditionRot;
                _wallPool[poolIndex].SetActive(true);

                _wallPool[poolIndex + 1].transform.position = (currentPos * _sizeModifier) - (_southAdditionPos * _sizeModifier);
                _wallPool[poolIndex + 1].transform.eulerAngles = _southAdditionRot;
                _wallPool[poolIndex + 1].SetActive(true);
                break;

            case 7:
                _wallPool[poolIndex].transform.position = (currentPos * _sizeModifier) + (_northAdditionPos * _sizeModifier);
                _wallPool[poolIndex].transform.eulerAngles += _northAdditionRot;
                _wallPool[poolIndex].SetActive(true);

                _wallPool[poolIndex + 1].transform.position = (currentPos * _sizeModifier) + (_eastAdditionPos * _sizeModifier);
                _wallPool[poolIndex + 1].transform.eulerAngles = _eastAdditionRot;
                _wallPool[poolIndex + 1].SetActive(true);

                _wallPool[poolIndex + 2].transform.position = (currentPos * _sizeModifier) - (_southAdditionPos * _sizeModifier);
                _wallPool[poolIndex + 2].transform.eulerAngles = _southAdditionRot;
                _wallPool[poolIndex + 2].SetActive(true);
                break;

            case 8:
                _wallPool[poolIndex].transform.position = (currentPos * _sizeModifier) + (_westAdditionPos * _sizeModifier);
                _wallPool[poolIndex].transform.eulerAngles = _westAdditionRot;
                _wallPool[poolIndex].SetActive(true);
                break;

            case 9:
                _wallPool[poolIndex].transform.position = (currentPos * _sizeModifier) + (_northAdditionPos * _sizeModifier);
                _wallPool[poolIndex].transform.eulerAngles += _northAdditionRot;
                _wallPool[poolIndex].SetActive(true);

                _wallPool[poolIndex + 1].transform.position = (currentPos * _sizeModifier) + (_westAdditionPos * _sizeModifier);
                _wallPool[poolIndex + 1].transform.eulerAngles = _westAdditionRot;
                _wallPool[poolIndex + 1].SetActive(true);
                break;

            case 10:
                _wallPool[poolIndex].transform.position = (currentPos * _sizeModifier) + (_eastAdditionPos * _sizeModifier);
                _wallPool[poolIndex].transform.eulerAngles = _eastAdditionRot;
                _wallPool[poolIndex].SetActive(true);

                _wallPool[poolIndex + 1].transform.position = (currentPos * _sizeModifier) + (_westAdditionPos * _sizeModifier);
                _wallPool[poolIndex + 1].transform.eulerAngles = _westAdditionRot;
                _wallPool[poolIndex + 1].SetActive(true);
                break;

            case 11:
                _wallPool[poolIndex].transform.position = (currentPos * _sizeModifier) + (_northAdditionPos * _sizeModifier);
                _wallPool[poolIndex].transform.eulerAngles += _northAdditionRot;
                _wallPool[poolIndex].SetActive(true);

                _wallPool[poolIndex + 1].transform.position = (currentPos * _sizeModifier) + (_eastAdditionPos * _sizeModifier);
                _wallPool[poolIndex + 1].transform.eulerAngles = _eastAdditionRot;
                _wallPool[poolIndex + 1].SetActive(true);

                _wallPool[poolIndex + 2].transform.position = (currentPos * _sizeModifier) + (_westAdditionPos * _sizeModifier);
                _wallPool[poolIndex + 2].transform.eulerAngles = _westAdditionRot;
                _wallPool[poolIndex + 2].SetActive(true);
                break;

            case 12:
                _wallPool[poolIndex].transform.position = (currentPos * _sizeModifier) - (_southAdditionPos * _sizeModifier);
                _wallPool[poolIndex].transform.eulerAngles = _southAdditionRot;
                _wallPool[poolIndex].SetActive(true);

                _wallPool[poolIndex + 1].transform.position = (currentPos * _sizeModifier) + (_westAdditionPos * _sizeModifier);
                _wallPool[poolIndex + 1].transform.eulerAngles = _westAdditionRot;
                _wallPool[poolIndex + 1].SetActive(true);
                break;

            case 13:
                _wallPool[poolIndex].transform.position = (currentPos * _sizeModifier) + (_northAdditionPos * _sizeModifier);
                _wallPool[poolIndex].transform.eulerAngles += _northAdditionRot;
                _wallPool[poolIndex].SetActive(true);

                _wallPool[poolIndex + 1].transform.position = (currentPos * _sizeModifier) - (_southAdditionPos * _sizeModifier);
                _wallPool[poolIndex + 1].transform.eulerAngles = _southAdditionRot;
                _wallPool[poolIndex + 1].SetActive(true);

                _wallPool[poolIndex + 2].transform.position = (currentPos * _sizeModifier) + (_westAdditionPos * _sizeModifier);
                _wallPool[poolIndex + 2].transform.eulerAngles = _westAdditionRot;
                _wallPool[poolIndex + 2].SetActive(true);
                break;

            case 14:
                _wallPool[poolIndex].transform.position = (currentPos * _sizeModifier) + (_eastAdditionPos * _sizeModifier);
                _wallPool[poolIndex].transform.eulerAngles = _eastAdditionRot;
                _wallPool[poolIndex].SetActive(true);

                _wallPool[poolIndex + 1].transform.position = (currentPos * _sizeModifier) - (_southAdditionPos * _sizeModifier);
                _wallPool[poolIndex + 1].transform.eulerAngles = _southAdditionRot;
                _wallPool[poolIndex + 1].SetActive(true);

                _wallPool[poolIndex + 2].transform.position = (currentPos * _sizeModifier) + (_westAdditionPos * _sizeModifier);
                _wallPool[poolIndex + 2].transform.eulerAngles = _westAdditionRot;
                _wallPool[poolIndex + 2].SetActive(true);
                break;

            case 15:
                _wallPool[poolIndex].transform.position = (currentPos * _sizeModifier) + (_northAdditionPos * _sizeModifier);
                _wallPool[poolIndex].transform.eulerAngles += _northAdditionRot;
                _wallPool[poolIndex].SetActive(true);

                _wallPool[poolIndex + 1].transform.position = (currentPos * _sizeModifier) + (_eastAdditionPos * _sizeModifier);
                _wallPool[poolIndex + 1].transform.eulerAngles = _eastAdditionRot;
                _wallPool[poolIndex + 1].SetActive(true);

                _wallPool[poolIndex + 2].transform.position = (currentPos * _sizeModifier) - (_southAdditionPos * _sizeModifier);
                _wallPool[poolIndex + 2].transform.eulerAngles = _southAdditionRot;
                _wallPool[poolIndex + 2].SetActive(true);

                _wallPool[poolIndex + 3].transform.position = (currentPos * _sizeModifier) + (_westAdditionPos * _sizeModifier);
                _wallPool[poolIndex + 3].transform.eulerAngles = _westAdditionRot;
                _wallPool[poolIndex + 3].SetActive(true);
                break;
        }

        return index;
    }
    
    public Vector3 getStartPosition(char[,] map)
    {
        for(int y = 0; y < map.GetLength(1); y++)
            for(int x = 0; x < map.GetLength(0); x++)
            {
                if (map[x, y] == 'S')
                    return new Vector3(x, 1, y);
            }
        
            Debug.LogError("Found no Start Point");
            return Vector3.zero;
    }
    
    public char[,] getMap()
    {
        return map;
    }

    public Vector2Int getMapStartPos()
    {
        return startPos;
    }

    public Vector2Int getMapEndPos()
    {
        return endPos;
    }

    public char getMapSquareData(Vector2Int pos)
    {
        return map[pos.x, pos.y];
    }

    public char getMapSquareData(int x, int y)
    {
        return map[x, y];
    }

    public Vector2Int getMapPos(Vector3 pos)
    {
        return new Vector2Int(Mathf.FloorToInt(pos.x / _sizeModifier) + 1,
                              Mathf.FloorToInt(pos.z / _sizeModifier));
    }
}