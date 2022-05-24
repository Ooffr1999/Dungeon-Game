using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Unity.Mathematics;
using Unity.Jobs;

public class JobTest : MonoBehaviour
{
    [SerializeField] 
    bool useJobs;
    private void Update()
    {
        float startTime = Time.realtimeSinceStartup;

        if (!useJobs)
            ReallyToughtTask();
        else
        {

            JobHandle jobHandle = ReallyToughTaskJob();
            jobHandle.Complete();
        }
        Debug.Log(((Time.realtimeSinceStartup - startTime) * 1000f) + "ms");
    }

    void ReallyToughtTask()
    {
        float value = 0f;
        for (int i = 0; i < 300000; i++)
        {
            value = math.exp10(math.sqrt(value));
        }
    }

    JobHandle ReallyToughTaskJob()
    {
        ReallyToughJob job = new ReallyToughJob();
        return job.Schedule();
    }
}

public struct ReallyToughJob : IJob
{
    public void Execute()
    {
        float value = 0f;
        for (int i = 0; i < 50000; i++)
        {
            value = math.exp10(math.sqrt(value));
        }
    }
}
