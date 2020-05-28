
namespace World
{
    using UnityEngine;
    
    public struct Vector
    {
        private static int RoundSingle(float f)
        {
            var sign = f > 0 ? 1 : -1;
            var value = f * sign + 0.5f;
            return (int)value * sign;
        }
        
        public static float R(float f, float precision = CVar.LENGTH_MUL)
        {
            return (int)(f * precision + 0.5f) / precision;
            //return RoundSingle(f / precision) * precision;
        }

        public static Vector R(Vector v, float precision = CVar.LENGTH_MUL)
        {
            return new Vector(R(v.x, precision), R(v.y, precision), R(v.z, precision));
        }

        public float x, y, z;

        public int ix { get { return (int)(x * CVar.LENGTH_MUL); } }
        public int iy { get { return (int)(y * CVar.LENGTH_MUL); } }
        public int iz { get { return (int)(z * CVar.LENGTH_MUL); } }

        public Vector(float x, float z) : this()
        {
            this.x = x;
            this.y = 0;
            this.z = z;
        }
        
        public Vector(float x, float y, float z) : this()
        {
            this.x = x;
            this.y = y;
            this.z = z;
        }

        public static Vector zero = new Vector(0f, 0f, 0f);
        public static Vector one = new Vector(1f, 1f, 1f);
        public static Vector forward = new Vector(0f, 0f, 1f);

        public Vector normalized {
            get {
                return ((Vector3)this).normalized;
            }
        }

        public float magnitude {
            get {
                return (float)System.Math.Sqrt(sqrMagnitude);
            }
        }

        public float sqrMagnitude {
            get {
                return x * x + y * y + z * z;
            }
        }

        public void Normalize()
        {
            var v3 = normalized;
            x = v3.x;
            y = v3.y;
            z = v3.z;
        }
        
        public override bool Equals(object obj)
        {
            if (obj is Vector) {
                return (Vector)obj == this;
            }

            if (obj is Vector3) {
                return (Vector3)obj == (Vector3)this;
            }

            return false;
        }

        public override int GetHashCode()
        {
            return ((Vector3)this).GetHashCode();
        }

        public override string ToString()
        {
            return string.Format("({0}, {1}, {2})", x, y, z);
        }

        public string ToXZ()
        {
            return string.Format("({0:F3}, {1:F3})", x, z);
        }

        public static Vector ClampMagnitude(Vector vec, float maxLength)
        {
            return Vector3.ClampMagnitude(vec, maxLength);
        }

        public static Vector Lerp(Vector a, Vector b, float t)
        {
            return Vector3.Lerp(a, b, t);
        }

        public static float Dot(Vector a, Vector b)
        {
            return Vector3.Dot(a, b);
        }

        public static Vector Forward(Vector from, Vector to)
        {
            return (to - from).normalized;
        }

        public static float Distance(Vector a, Vector b)
        {
            return (a - b).magnitude;
        }

        public static Vector RotateOffset(Vector current, Vector forward)
        {
            if (current != zero && forward != zero) {
                var rot = Quaternion.LookRotation(forward, Vector3.up);
                return rot * current;
            }
            return current;
        }

        public static Vector RotateOffset(Vector current, float rotAngle)
        {
            if (current != zero && forward != zero)
            {
                return Quaternion.Euler(0, rotAngle, 0) * current;
            }
            return current;
        }

        public static Vector MoveTowards(Vector current, Vector target, float maxDistanceDelta)
        {
            return Vector3.MoveTowards(current, target, maxDistanceDelta);
        }

        public static Vector RotateTowards(Vector current, Vector target, float maxRadiansDelta, float maxMagnitudeDelta)
        {
            return Vector3.RotateTowards(current, target, maxRadiansDelta, maxMagnitudeDelta);
        }

        public static bool operator ==(Vector a, Vector b)
        {
            return Math.IsEqual(a.x, b.x) && Math.IsEqual(a.y, b.y) && Math.IsEqual(a.z, b.z);
        }

        public static bool operator !=(Vector a, Vector b)
        {
            return !(a == b);
        }

        public static Vector operator +(Vector a, Vector b)
        {
            return new Vector(a.x + b.x, a.y + b.y, a.z + b.z);
        }

        public static Vector operator -(Vector a, Vector b)
        {
            return new Vector(a.x - b.x, a.y - b.y, a.z - b.z);
        }

        public static Vector operator *(Vector a, float f)
        {
            return new Vector(a.x * f, a.y * f, a.z * f);
        }

        public static Vector operator /(Vector a, float f)
        {
            return new Vector(a.x / f, a.y / f, a.z / f);
        }
        
        public static implicit operator Vector2(Vector vector)
        {
            return new Vector2(vector.x, vector.z);
        }

        public static implicit operator Vector(Vector2 vector)
        {
            return new Vector(vector.x, 0, vector.y);
        }

        public static implicit operator Vector3(Vector vector)
        {
            return new Vector3(vector.x, vector.y, vector.z);
        }

        public static implicit operator Vector(Vector3 vector)
        {
            return new Vector(vector.x, vector.y, vector.z);
        }
    }
}
