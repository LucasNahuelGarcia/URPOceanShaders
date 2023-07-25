using UnityEngine;
using UnityEngine.Serialization;

public class GerstnerWavesPhysics : MonoBehaviour
{
    public static GerstnerWavesPhysics Instance { get; private set; }

    private void OnEnable()
    {
        Instance ??= this;
    }

    [SerializeField]private Ocean ocean;

    public static float GerstnerWaveLevelAtPoint(Vector4 wave, Vector3 point)
    {
        const float unityPI = 3.14f;
        float steepness = wave.z;
        float wavelength = wave.w;
        float k = 2 * unityPI / wavelength;
        float c = Mathf.Sqrt(9.8f / k);
        Vector2 d = new Vector2(wave.x, wave.y);
        float f = k * (Vector2.Dot(d, new Vector2(point.x, point.z)) - c * Time.time);
        float a = steepness / k;

        return a * Mathf.Sin(f) - 1;
    }

    public float GetWaterLineAtPos(Vector3 pos)
    {
        float waterLine = 0;
        foreach (Vector4 wave in ocean.GetWaves())
            waterLine += GerstnerWaveLevelAtPoint(wave, pos);
        return waterLine;
    }
}