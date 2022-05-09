using System.Collections;
using System.Collections.Generic;
using UnityEngine;

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
    public List<GameObject> _floorPool;
    [HideInInspector]
    public List<GameObject> _wallPool;

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

    public void GetNewSeed()
    {
        Random.InitState(System.Environment.TickCount);
        seed = Random.Range(-100000, 100000);
    }

    public void DrawLevelLayout()
    {
        char[,] map = MapGen.GetCatacombMap(size.x, size.y, seed);

        transform.localScale = new Vector3(map.GetLength(0), map.GetLength(1), 1);

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

    public void GenerateLevel()
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

                    case 'E':
                        stairs.transform.localScale = Vector3.one * _sizeModifier;
                        stairs.transform.position = (new Vector3(x, 0, y) + new Vector3(-0.5f, 0.5f, 0.5f)) * _sizeModifier;
                        break;

                    case '#':
                        _wallPool[wallPieceUsed].transform.position = (new Vector3(x, 0, y) + new Vector3(-0.5f, 0.5f, 0.5f)) * _sizeModifier;
                        _wallPool[wallPieceUsed].SetActive(true);
                        wallPieceUsed++;
                        break;
                }               
            }
        }

        player.GetComponent<CharacterController>().enabled = false;
        player.transform.position = getStartPosition(map) * _sizeModifier;
        player.GetComponent<CharacterController>().enabled = true;
    }

    public void InitPool()
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

        for (int i = 0; i < size.x * size.y; i++)
        {
            GameObject wallPiece = Instantiate(wallPlanes[0], wallPlanes[0].transform.position, wallPlanes[0].transform.rotation);
            wallPiece.transform.localScale *= _sizeModifier;
            wallPiece.transform.parent = this.transform;
            _wallPool.Add(wallPiece);
            wallPiece.SetActive(false);
        }
    }

    public void ClearRoom()
    {
        for (int i = 0; i < _floorPool.Count; i++)
        {
            _floorPool[i].SetActive(false);
        }

        for (int i = 0; i < _wallPool.Count; i++)
        {
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
}
