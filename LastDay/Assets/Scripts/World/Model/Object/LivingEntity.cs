//
//  EntityLiving.cs
//  survive
//
//  Created by xingweizhen on 10/12/2017.
//
//

using System.Collections.Generic;

namespace World
{
    public class LivingEntity : Living, IEntity
    {
        public LivingEntity() : base()
        {
        }
        
        public override bool IsSelectable(IObj by)
        {
            return operId < CVar.INTERACT_ID;
        }
    }
}
