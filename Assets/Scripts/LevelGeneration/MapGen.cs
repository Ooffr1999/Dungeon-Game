using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using RoomGen;

public static class MapGen
{
    public static int[,] GetTexBasedMap(int width, int height, Texture2D[] tex, int seed)
    {
        Random.InitState(seed);

        int[,] newMap = new int[width, height];

        int posX = 1;
        int posY = 1;

        int widthBetweenRows = 0;

        for (int ix = 0; ix < 7; ix++)
        {
            for (int iy = 0; iy < 5; iy++)
            {
                int texIndex = Random.Range(0, tex.Length);

                int texEndX = posX + tex[texIndex].width;
                int texEndY = posY + tex[texIndex].height;

                //Ensure map isn't to big
                if (texEndX > width)
                    break;

                if (texEndY > height)
                    break;

                int texX = 0;
                int texY = 0;

                for (int y = posY; y < texEndY; y++)
                {
                    for (int x = posX; x < texEndX; x++)
                    {
                        Color pixelColor = tex[texIndex].GetPixel(texX, texY);

                        if (pixelColor == Color.white)
                            newMap[y, x] = 1;
                        else newMap[y, x] = 0;

                        Debug.Log(pixelColor);
                        texX++;
                    }
                    texX = 0;
                    texY++;
                }
                posY += tex[texIndex].height;

                if (tex[texIndex].width > widthBetweenRows)
                    widthBetweenRows = tex[texIndex].width;
            }

            posX += widthBetweenRows;
            posY = 1;
            widthBetweenRows = 0;
        }

        return newMap;
    }

    public static char[,] GetCatacombMap(int width, int height, int seed)
    {
        List<Room> roomList = new List<Room>();

        Random.InitState(seed);

        //Generate new map
        char[,] map = new char[width, height];

        Vector2Int spineRoomPos;
        Vector2Int spineRoomDim;

        spineRoomPos = new Vector2Int(Random.Range(20, 40), 1);
        spineRoomDim = new Vector2Int(Random.Range(12, 20), Random.Range(25, 30));

        roomList.Add(RoomEngine.CreateRoom(map, spineRoomPos, spineRoomDim));

        spineRoomPos = new Vector2Int(Random.Range(spineRoomPos.x - 7, spineRoomPos.x + 7), spineRoomDim.y);
        spineRoomDim = new Vector2Int(Random.Range(10, 15), Random.Range(25, 30));

        roomList.Add(RoomEngine.CreateRoom(map, spineRoomPos, spineRoomDim));  

        for (int i = 0; i < 4; i++)
        {
            Vector2Int randPos = new Vector2Int(Random.Range(1, 20), Random.Range(2, 20) * i + 1);
            Vector2Int randDim = new Vector2Int(Random.Range(6, 20), Random.Range(6, 11));

            if (RoomEngine.CheckSpace(map, randPos, randDim)) 
                roomList.Add(RoomEngine.CreateRoom(map, randPos, randDim));

            randPos = new Vector2Int(Random.Range(35, 49), Random.Range(2, 20) * i + 1);
            randDim = new Vector2Int(Random.Range(6, 11), Random.Range(6, 11));

            if (RoomEngine.CheckSpace(map, randPos, randDim))
                roomList.Add(RoomEngine.CreateRoom(map, randPos, randDim));
        }
        
        for (int i = 0; i < 100; i++)
        {
            Room room = RoomEngine.FillRoom(map);
            
            if (room != null)
                roomList.Add(room);

            if (Random.Range(0, 101) > 75)
                RoomEngine.GenerateWalls(map);

            int count = RoomEngine.CountTiles(map);
            if (count > 2300)
                break;
        }  

        for (int i = 0; i < roomList.Count - 1; i++)
        {
            RoomEngine.GenerateHallWay(map, Random.Range(2, 4), roomList[i].origin, roomList[i+1].origin);
        }

        RoomEngine.GenerateHallWay(map, Random.Range(2, 4), roomList[roomList.Count - 1].origin, roomList[0].origin);

        RoomEngine.GenerateWalls(map);
        RoomEngine.CleanFloorHoles(map);

        //RoomEngine.PlaceDoors(map);

        RoomEngine.PlaceStartOrEndPoint(map, 'S');
        RoomEngine.PlaceStartOrEndPoint(map, 'E');

        return map;
    }
}