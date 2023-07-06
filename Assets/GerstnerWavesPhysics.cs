using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GerstnerWavesPhysics : MonoBehaviour
{
    public Ocean Ocean;
    public GameObject Boat;
    [NonReorderable][SerializeField] private Transform[] BoatForcePoints = new Transform[3];

    public float GerstnerWaveLevelAtPoint(Vector4 wave, Vector3 Point)
    {
        int added = 0;
        float steepness = wave.z;
        float wavelength = wave.w;
        float UNITY_PI = 3.14f;
        float k = 2 * UNITY_PI / wavelength;
        float c = Mathf.Sqrt(9.8f / k);
        Vector2 d = new Vector2(wave.x, wave.y);
        float f = k * (Vector2.Dot(d, new Vector2(Point.x, Point.z)) - c * Time.time);
        float a = steepness / k;

        return a * Mathf.Sin(f) - 1;
    }

    private void FixedUpdate()
    {
        foreach (Transform point in BoatForcePoints)
        {
            Vector3 pos = point.position;
            float waterLine = GetWaterLineAtPos(pos);

            point.transform.position = new Vector3(pos.x, waterLine, pos.z);
        }

        Vector3 a = BoatForcePoints[0].position;
        Vector3 b = BoatForcePoints[1].position;
        Vector3 c = BoatForcePoints[2].position;

        Vector3 ab = b - a;
        Vector3 ac = c - a;
        Vector3 boatPosition = (a + b + c) / 3;
        Vector3 upwardDirection = Vector3.Cross(ac,ab);
        Vector3 forwardDirection = a - boatPosition;

        
        Boat.transform.SetPositionAndRotation(boatPosition, Quaternion.LookRotation(forwardDirection, upwardDirection));
    }

    private float GetWaterLineAtPos(Vector3 pos)
    {
        float waterLine = 0;
        foreach (Vector4 wave in Ocean.GetWaves())
            waterLine += GerstnerWaveLevelAtPoint(wave, pos);
        return waterLine;
    }
}