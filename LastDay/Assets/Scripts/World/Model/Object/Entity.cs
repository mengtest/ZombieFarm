//
//  Entity.cs
//  survive
//
//  Created by xingweizhen on 10/16/2017.
//
//

namespace World
{
    public class Entity : XObject, IEntity
    {
        public override bool IsSelectable(IObj by)
        {
            return false;
        }
    }
}
