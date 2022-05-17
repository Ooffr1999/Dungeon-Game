using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using RoomGen;

public class LevelGen : MonoBehaviour
{
    public int seed;
    public Vector2Int size;
    public GameObject[] floorPlanes;
    public GameObject[] wallPlanes;

    [Space(10)]
    public float _sizeModifier;

    [Header("Player")]
    public GameObject player;

    [Header("Stairs")]
    public GameObject stairs;

    [HideInInspector]
    char[,] map;

    [HideInInspector]
    public List<GameObject> _floorPool;
    [HideInInspector]
    public List<GameObject> _wallPool;

    [HideInInspector]
    public static LevelGen _instance;

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

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Y))
            MakeLevel();
    }

    void GetNewSeed()
    {
        Random.InitState(System.Environment.TickCount);
        seed = Random.Range(-100000, 100000);
    }

    void DrawLevelLayout()
    {
        map = MapGen.GetCatacombMap(size.x, size.y, seed);

        //transform.localScale = new Vector3(map.GetLength(0), map.GetLength(1), 1);

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
                        mapTex.SetPixel(x, y, Color.red);
                        break;

                    case '#':
                        mapTex.SetPixel(x, y, Color.blue);
                        break;

                    case 'D':
                        mapTex.SetPixel(x, y, Color.cyan);
                        break;

                    case 'S':
                        mapTex.SetPixel(x, y, Color.white);
                        break;

                    case 'E':
                        mapTex.SetPixel(x, y, Color.black);
                        break;

                    default:
                        mapTex.SetPixel(x, y, Color.black);
                        break;
                }
            }
        }



        mapTex.Apply();

        GetComponent<Renderer>().sharedMaterial.mainTexture = mapTex;
    }

    void GenerateLevel()
    {
        char[,] map = MapGen.GetCatacombMap(size.x, size.y, seed);

        int floorPiecesUsed = 0;
        int wallPieceUsed = 0;

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
                }

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
    }

    public void MakeLevel()
    {
        ClearRoom();
        DrawLevelLayout();
        GenerateLevel();
        GetNewSeed();
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

    public char getMapSquareData(Vector2Int pos)
    {
        return map[pos.x, pos.y];
    }

    public char getMapSquareData(int x, int y)
    {
        return map[x, y];
    }
}