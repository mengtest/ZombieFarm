using UnityEngine;
using System.Collections;
using System;

namespace ASL.FogOfWar
{
    [System.Serializable]
    public class FOWPregenerationMapData : MonoBehaviour, IFOWMapData
    {
        public bool isPregeneration {
            get { return false; }
        }

        public byte this[int i, int j] {
            get { return m_MapData[j * width + i]; }
        }

        public int width;
        public int height;
        [SerializeField]
        private byte[] m_MapData;

        public bool IsObstacle(int i, int j, int centX, int centY)
        {
            return m_MapData[j * width + i] != 0;
        }

        public void GenerateMapData(float beginx, float beginy, float deltax, float deltay, float heightRange)
        {
            m_MapData = new byte[width * height];
            for (int i = 0; i < width; i++) {
                for (int j = 0; j < height; j++) {
                    var obstacle = FOWUtils.IsObstacle(beginx, beginy, deltax, deltay, heightRange, i, j);
                    m_MapData[j * width + i] = (byte)(obstacle ? 1 : 0);
                }
            }
        }
    }
}