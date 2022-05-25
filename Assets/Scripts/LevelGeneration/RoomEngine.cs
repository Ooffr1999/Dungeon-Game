using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

namespace RoomGen
{
    public static class RoomEngine
    {
        //Generate the shape of a room
        public static Room CreateRoom(char[,] map, Vector2Int pos, Vector2Int dimension)
        {
            //Generate room width and ensure it doesn't break the game
            int width = dimension.x;
            if (pos.x + width > map.GetLength(0) - 1)
                pos.x -= pos.x + dimension.x - map.GetLength(0) + 1;

            //Generate room height and ensure it doesn't break the game
            int height = dimension.y;
            if (pos.y + height > map.GetLength(1) - 1)
                pos.y -= pos.y + dimension.y - map.GetLength(1) + 1;

            for (int y = pos.y; y < pos.y + dimension.y; y++)
                for (int x = pos.x; x < pos.x + dimension.x; x++)
                    if (map[x, y] == '\0')
                        map[x, y] = '.';

            Room newRoom = new Room();

            newRoom.origin = pos;
            newRoom.dimensions = dimension;
            newRoom.center = new Vector2Int(pos.x + Mathf.FloorToInt(dimension.x / 2), pos.y + Mathf.FloorToInt(dimension.y / 2));

            return newRoom;
        }

        //Check if a space is already obscured
        public static bool CheckSpace(char[,] map, Vector2Int pos, Vector2Int dimension)
        {
            int startX = pos.x - 1;
            int startY = pos.y - 1;
            int width = pos.x + dimension.x;
            int height = pos.y + dimension.y;

            if (startX < 1)
                startX = 1;
            if (startY < 1)
                startY = 1;
            if (width > map.GetLength(0))
                width = map.GetLength(0);
            if (height > map.GetLength(1))
                height = map.GetLength(1);

            for (int y = startY; y < height; y++)
                for (int x = startX; x < width; x++)
                    if (map[x, y] != '\0')
                        return false;
                    

            return true;
        }

        //Generate Walls around existing rooms
        public static void GenerateWalls(char[,] map)
        {
            for (int y = 0; y < map.GetLength(1); y++)
                for(int x = 0; x < map.GetLength(0); x++)
                {
                    int index = MarchThroughMap(map, '.', x, y);
                    if (map[x, y] == '\0')
                    switch(index)
                    {
                        case 1:
                            map[x, y] = '#';
                            break;

                        case 2:
                            map[x, y] = '#';
                            break;

                        case 3:
                            map[x, y] = '#';
                            break;

                        case 4:
                            map[x, y] = '#';
                            break;

                        case 5:
                            map[x, y] = '#';
                            break;

                        case 6:
                            map[x, y] = '#';
                            break;

                        case 8:
                            map[x, y] = '#';
                            break;

                        case 9:
                            map[x, y] = '#';
                            break;

                        case 10:
                            map[x, y] = '#';
                            break;

                        case 12:
                            map[x, y] = '#';
                            break;
                    }               
                }
        }

        //Clean holes in floors
        public static void CleanFloorHoles(char[,] map)
        {
            for (int y = 0; y < map.GetLength(1); y++)
                for(int x = 0; x < map.GetLength(0); x++)
                {
                    int index = MarchThroughMap(map, '.', x, y);

                    if (map[x, y] == '\0')
                        switch(index)
                        {
                            case 7:
                                map[x, y] = '.';
                                break;

                            case 11:
                                map[x, y] = '.';
                                break;

                            case 13:
                                map[x, y] = '.';
                                break;

                            case 14:
                                map[x, y] = '.';
                                break;

                            case 15:
                                map[x, y] = '.';
                                break;
                        }
                }
        }

        //Begin to fill out an area with a room
        public static Room FillRoom(char[,] map)
        {
            int x = 0; 
            int y = 0;

            for(int i = 0; i < 100; i++)
            {
                x = UnityEngine.Random.Range(0, map.GetLength(0));
                y = UnityEngine.Random.Range(0, map.GetLength(1));

                if (map[x, y] == '\0')
                    break;
            }

            Vector2Int origin = new Vector2Int(x, y);

            for (int i = 2; i < 20; i++)
            {
                if (CheckSpace(map, origin, Vector2Int.one * i))
                    continue;
                
                if (i >= 13)
                    return CreateRoom(map, origin, Vector2Int.one * i);
            }

            return null;
        }
        
        //Generate a hallway between two rooms
        public static void GenerateHallWay(char[,] map, int width, Vector2Int startPoint, Vector2Int endPoint)
        {
            int x = startPoint.x;
            int y = startPoint.y;
            
            while(x != endPoint.x)
            {
                PlaceHallTileMain(map, x, y);

                if (width > 1)
                    for (int w = 2; w < width + 1; w++)
                    {
                        int increment = Mathf.FloorToInt(w / 2);

                        if (w % 2 == 1)
                            increment *= -1;

                        if (y + increment > -1 && y + increment < map.GetLength(1))
                            PlaceHallTileSecondary(map, x, y + increment);
                    }

                if (x > endPoint.x)
                    x--;
                else if (x < endPoint.x)
                    x++;
            }
            
            while(y != endPoint.y)
            {
                PlaceHallTileMain(map, x, y);

                if (width > 1)
                    for (int w = 2; w < width + 1; w++)
                    {
                        int increment = Mathf.FloorToInt(w / 2);

                        if (w % 2 == 1)
                            increment *= -1;

                        if (x + increment > -1 && x + increment < map.GetLength(0))
                            PlaceHallTileSecondary(map, x + increment, y);
                    }

                if (y > endPoint.y)
                    y--;
                else if (y < endPoint.y)
                    y++;
            }
        }
        
        //Reference tiles when making main hallway
        static void PlaceHallTileMain(char[,] map, int x, int y)
        {
            switch (map[x, y])
            {
                case '\0':
                    map[x, y] = '.';
                    break;

                case '#':
                    map[x, y] = '.';
                    break;
            }
        }

        //Place hall tiles around main path
        static void PlaceHallTileSecondary(char[,] map, int x, int y)
        {
            switch (map[x, y])
            {
                case '\0':
                    map[x, y] = '.';
                    break;

                case '#':
                    map[x, y] = '#';
                    break;
            }
        }

        //Place doors on map
        public static void PlaceDoors(char[,] map)
        {
            for (int y = 0; y < map.GetLength(1); y++)
                for (int x = 0; x < map.GetLength(0); x++)
                {
                    if (map[x, y] != '.')
                        continue;

                    int index = 0;

                    index += MarchThroughMap(map, '#', x, y);
                    index += MarchThroughMap(map, 'D', x, y);

                    switch(index)
                    {
                        case 5:
                            map[x, y] = 'D';
                            break;

                        case 10:
                            map[x, y] = 'D';
                            break;
                    }
                }
        }

        //Makes a player start point
        public static void PlaceStartOrEndPoint(char[,] map, char pointToSet)
        {
            while(true)
            {
                Vector2Int startPoint = new Vector2Int(UnityEngine.Random.Range(0, map.GetLength(0)), UnityEngine.Random.Range(0, map.GetLength(1)));

                if (map[startPoint.x, startPoint.y] == '.' &&
                    MarchThroughMap(map, '.', startPoint.x, startPoint.y) == 15)
                {
                    map[startPoint.x, startPoint.y] = pointToSet;
                    break;
                }
            }
        }

        //March through the map and generate an index based on surrounding tiles. The tiletype to look for is fed into the function
        public static int MarchThroughMap(char[,] map, char valueToSearchFor, int xPos, int yPos)
        {
            int mapIndex = 0;

            if (yPos + 1 < map.GetLength(1))
                if (map[xPos, yPos + 1] == valueToSearchFor) mapIndex |= 1;
            if (xPos + 1 < map.GetLength(0))
                if (map[xPos + 1, yPos] == valueToSearchFor) mapIndex |= 2;
            if (yPos - 1 > -1)
                if (map[xPos, yPos - 1] == valueToSearchFor) mapIndex |= 4;
            if (xPos - 1 > -1)
                if (map[xPos - 1, yPos] == valueToSearchFor) mapIndex |= 8;

            return mapIndex;
        }

        //Count every open tile in a map
        public static int CountTiles(char[,] map)
        {
            int count = 0;

            for (int y = 0; y < map.GetLength(1); y++)
                for (int x = 0; x < map.GetLength(0); x++)
                    if (map[x, y] != '\0')
                        count++;

            return count;
        }

        public static Vector2Int getRandomMapPos(char[,] map)
        {
            int randX = UnityEngine.Random.Range(0, map.GetLength(0));
            int randY = UnityEngine.Random.Range(0, map.GetLength(1));

            return new Vector2Int(randX, randY);
        }
    }

    //Room class for referencing rooms
    public class Room
    {
        public Vector2Int origin;
        public Vector2Int dimensions;
        public Vector2Int center;
    }
}