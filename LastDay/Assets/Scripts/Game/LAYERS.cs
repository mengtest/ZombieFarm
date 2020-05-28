using UnityEngine;
/// <summary>
/// 定义Unity GameObject Layer的mask值
/// </summary>
public static class LAYERS
{
    public static readonly int iDefault = LayerMask.NameToLayer("Default");
    public static readonly int iUI = LayerMask.NameToLayer("UI");
    public static readonly int iGround = LayerMask.NameToLayer("Ground");
    public static readonly int iFurniture = LayerMask.NameToLayer("Furniture");
    public static readonly int iBuilding = LayerMask.NameToLayer("Building");
    public static readonly int iRole = LayerMask.NameToLayer("Role");
    public static readonly int iFX = LayerMask.NameToLayer("FX");
    public static readonly int iPlant = LayerMask.NameToLayer("Plant");
    public static readonly int iOverUI = LayerMask.NameToLayer("OverUI");
    public static readonly int iInvisible = LayerMask.NameToLayer("Invisible");

    public static readonly int Default = 1 << iDefault;
    public static readonly int UI = 1 << iUI;
    public static readonly int Ground = 1 << iGround;
    public static readonly int Furniture = 1 << iFurniture;
    public static readonly int Building = 1 << iBuilding;
    public static readonly int Role = 1 << iRole;
    public static readonly int FX = 1 << iFX;
    public static readonly int Plant = 1 << iPlant;
    public static readonly int OverUI = 1 << iOverUI;
    public static readonly int Invisible = 1 << iInvisible;
}
