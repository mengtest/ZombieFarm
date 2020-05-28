using UnityEngine;
using System.Collections;

public static class CollectionTools
{
    public static void AddOrReplace(this IDictionary self, object key, object value)
    {
        if (self.Contains(key)) {
            self[key] = value;
        } else {
            self.Add(key, value);
        }
    }

    public static void AddNotExist(this IDictionary self, object key, object value)
    {
        if (!self.Contains(key)) {
            self.Add(key, value);
        }
    }
}
