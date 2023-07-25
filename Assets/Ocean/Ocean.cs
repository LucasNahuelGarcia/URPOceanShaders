using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Ocean : MonoBehaviour
{
    private Material WavesMaterial;
    private int WaveAID;
    private int WaveBID;
    private int WaveCID;
    
    // ReSharper disable Unity.PerformanceAnalysis
    public List<Vector4> GetWaves()
    {
        WavesMaterial ??= GetComponent<MeshRenderer>().material;
        List<Vector4> Waves = new List<Vector4>();

        Waves.Add(WavesMaterial.GetVector("_WaveA"));
        Waves.Add(WavesMaterial.GetVector("_WaveB"));
        Waves.Add(WavesMaterial.GetVector("_WaveC"));
        Waves.Add(WavesMaterial.GetVector("_WaveD"));
        Waves.Add(WavesMaterial.GetVector("_WaveE"));
        
        return Waves;
    }
}
