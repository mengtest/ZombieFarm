using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ASL.FogOfWar
{
    internal class StageFOVCalc : FOVCalculator
    {
        protected override void RayCast(FOWMap map, FOWMapPos pos, int centX, int centZ, FOWFieldData field)
        {
            var offsetX = pos.x - centX;
            var offsetY = pos.y - centZ;
            
            FOWMapPos begin, end;
            Vector2 p1, p2;
            if (offsetX == 0) {
                var py = pos.y + (offsetY < 0 ? -0.5f : 0.5f);
                p1 = new Vector2(pos.x - 0.5f, py);
                p2 = new Vector2(pos.x + 0.5f, py);
            } else if (offsetY == 0) {
                var px = pos.x + (offsetX < 0 ? -0.5f : 0.5f);
                p1 = new Vector2(px, pos.y - 0.5f);
                p2 = new Vector2(px, pos.y + 0.5f);
            } else {
                var m = offsetX * offsetY;
                if (m > 0) {
                    p1 = new Vector2(pos.x - 0.5f, pos.y + 0.5f);
                    p2 = new Vector2(pos.x + 0.5f, pos.y - 0.5f);
                } else {
                    p1 = new Vector2(pos.x - 0.5f, pos.y - 0.5f);
                    p2 = new Vector2(pos.x + 0.5f, pos.y + 0.5f);
                }
            }
            
            var kp = offsetX != 0 ? (float)offsetY / offsetX : 0;
            var k1 = (p1.y - centZ) / (p1.x - centX);
            var k2 = (p2.y - centZ) / (p2.x - centX);
            if (k1 > k2) {
                var kt = k1; k1 = k2; k2 = kt;
            }

            var radius = (int)(field.radius * map.invDeltaX);
            if (offsetX == 0) {
                begin.x = centX - radius;
                end.x = centX + radius;
            } else if (offsetX < 0) {
                begin.x = centX - radius;
                end.x = pos.x;
            } else {
                begin.x = pos.x;
                end.x = centX + radius;
            }

            if (offsetY == 0) {
                begin.y = centZ - radius;
                end.y = centZ + radius;
            } else if (offsetY < 0) {
                begin.y = centZ - radius;
                end.y = pos.y;
            } else {
                begin.y = pos.y;
                end.y = centZ + radius;
            }

            map.ClampPoint(ref begin);
            map.ClampPoint(ref end);

            if (offsetX != 0 && kp > k1 && kp < k2) {
                // 与原点连线斜率在(k1, k2)内的为被遮挡区域
                for (int i = begin.x; i <= end.x; ++i) {
                    for (int j = begin.y; j <= end.y; ++j) {
                        var k = ((float)j - centZ) / (i - centX);
                        if (k > k1 && k < k2) {
                            SetInvisibleAtPosition(map, i, j);
                        }
                    }
                }
            } else {
                // 与原点连线斜率在[k1, k2]外的为被遮挡区域
                for (int i = begin.x; i <= end.x; ++i) {
                    for (int j = begin.y; j <= end.y; ++j) {
                        var k = ((float)j - centZ) / (i - centX);
                        if (k < k1 || k > k2) {
                            SetInvisibleAtPosition(map, i, j);
                        }
                    }
                }
            }
        }
    }
}
