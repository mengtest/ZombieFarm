using UnityEngine;
using UnityEngine.AI;
using System.Collections;

public static class NavMeshTools
{
    private static NavMeshPath _TmpPath;

    public static NavMeshPath TmpPath {
        get { return _TmpPath ?? (_TmpPath = new NavMeshPath()); }
    }

    private static readonly Vector3[] _PathCorners = new Vector3[32];
    public static Vector3[] PathCorners { get { return _PathCorners; } }
    
    private static bool INTERNAL_IsReachable(this NavMeshAgent self, Vector3 dest, float maxDistance)
    {
        NavMeshHit hit;
        if (NavMesh.SamplePosition(dest, out hit, maxDistance, self.areaMask)) {
            dest = hit.position;
            if (self.CalculatePath(dest, TmpPath)) {
                var n = TmpPath.GetCornersNonAlloc(PathCorners);
                return n > 0 && PathCorners[n - 1] == dest;
            }
        }

        return false;
    }
    
    public static bool IsReachable(this NavMeshAgent self, Vector3 dest, float maxDistance)
    {
        var radius = 0.1f;// self.radius / 2;
        return self.INTERNAL_IsReachable(dest, maxDistance)
           || self.INTERNAL_IsReachable(dest + Vector3.forward * radius, maxDistance)
           || self.INTERNAL_IsReachable(dest + new Vector3(-0.866f, 0, -0.5f) * radius, maxDistance)
           || self.INTERNAL_IsReachable(dest + new Vector3(0.866f, 0, -0.5f) * radius, maxDistance);
    }
    
    public static IEnumerator OffMeshLinkNormal(UnityEngine.AI.NavMeshAgent agent, Vector3 endPos)
    {
        var trans = agent.transform;
        var targetDir = (endPos.SetY(trans.position.y) - trans.position).normalized;
        var delta = Time.deltaTime;
        for (; agent && endPos != trans.position;) {
            trans.forward = Vector3.RotateTowards(trans.forward, targetDir, 10 * delta, 0);
            var nextPos = Vector3.MoveTowards(trans.position, endPos, agent.speed * delta);
            trans.position = nextPos;
            yield return null;
        }
    }

    public static IEnumerator Blink(UnityEngine.AI.NavMeshAgent agent, Vector3 endPos)
    {
        agent.transform.position = endPos;
        yield return null;
    }

    public static IEnumerator JumpAcross(UnityEngine.AI.NavMeshAgent agent, Vector3 endPos)
    {
        var trans = agent.transform;
        var targetDir = (endPos.SetY(trans.position.y) - trans.position).normalized;
        var delta = Time.deltaTime;
        for (; agent && endPos != trans.position;) {
            trans.forward = Vector3.RotateTowards(trans.forward, targetDir, 10 * delta, 0);
            var nextPos = Vector3.MoveTowards(trans.position, endPos, agent.speed * delta);
            trans.position = nextPos;
            yield return null;
        }
    }

    public static IEnumerator DropDown(UnityEngine.AI.NavMeshAgent agent, Vector3 endPos)
    {
        var trans = agent.transform;
        var targetDir = (endPos.SetY(trans.position.y) - trans.position).normalized;
        var delta = Time.deltaTime;
        for (; agent && endPos != agent.transform.position;) {
            trans.forward = Vector3.RotateTowards(trans.forward, targetDir, 10 * delta, 0);
            var nextPos = Vector3.MoveTowards(trans.position, endPos, agent.speed * delta);
            trans.position = nextPos;
        }
        yield return null;
    }

    public static IEnumerator JumpDowm(UnityEngine.AI.NavMeshAgent agent, Vector3 endPos, float h, float g)
    {
        var trans = agent.transform;
        var targetDir = (endPos.SetY(trans.position.y) - trans.position).normalized;
        float ls = (endPos.SetY(trans.position.y) - trans.position).magnitude;
        float lh = endPos.y - trans.position.y;
        h = h < lh ? lh : h;
        float vh = Mathf.Sqrt(g * h * 2);
        float vs = ls / (Mathf.Sqrt(2 * h / g) + Mathf.Sqrt(2 * (h - lh) / g));
        for (; agent && (endPos.y < trans.position.y || vh > 0);) {
            var delta = Time.deltaTime;
            trans.forward = Vector3.RotateTowards(trans.forward, targetDir, 10 * delta, 0);
            Vector3 move = targetDir * delta * vs + Vector3.up * (vh * delta - g * delta * delta / 2);
            vh -= g * delta;
            trans.position = trans.position + move;
            yield return null;
        }
    }

    public static void CopyFrom(this UnityEngine.AI.NavMeshAgent self, UnityEngine.AI.NavMeshAgent tarAgent)
    {
        // Agent Size
        self.radius = tarAgent.radius;
        self.height = tarAgent.height;
        self.baseOffset = tarAgent.baseOffset;

        // Steering
        self.speed = tarAgent.speed;
        self.angularSpeed = tarAgent.angularSpeed;
        self.acceleration = tarAgent.acceleration;
        self.stoppingDistance = tarAgent.stoppingDistance;
        self.autoBraking = tarAgent.autoBraking;

        // Obstacle Avoidance
        self.obstacleAvoidanceType = tarAgent.obstacleAvoidanceType;
        self.avoidancePriority = tarAgent.avoidancePriority;

        // Path Finding
        self.autoTraverseOffMeshLink = tarAgent.autoTraverseOffMeshLink;
        self.autoRepath = tarAgent.autoRepath;
        self.areaMask = tarAgent.areaMask;
    }

    public static void CopyFrom(this UnityEngine.AI.NavMeshObstacle self, UnityEngine.AI.NavMeshObstacle tarObstacle)
    {
        self.carving = tarObstacle.carving;
        self.carvingMoveThreshold = tarObstacle.carvingMoveThreshold;
        self.height = tarObstacle.height;
        self.radius = tarObstacle.radius;
        self.velocity = tarObstacle.velocity;
        self.carveOnlyStationary = tarObstacle.carveOnlyStationary;        
        self.carvingTimeToStationary = tarObstacle.carvingTimeToStationary;
        self.center = tarObstacle.center;        
        self.shape = tarObstacle.shape;
        self.size = tarObstacle.size;
    }
}
