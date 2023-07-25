using UnityEngine;

public class WaterFloatingObject : MonoBehaviour
{
    [SerializeField] private Transform FloatingPointA;
    [SerializeField] private Transform FloatingPointB;
    [SerializeField] private Transform FloatingPointC;

    [Range(0f, 1)] [SerializeField] private float positionDampen = .8f;
    [Range(0f, 1)] [SerializeField] private float rotationDampen = .8f;

    private void FixedUpdate()
    {
        UpdateFloatingPointPosition(FloatingPointA);
        UpdateFloatingPointPosition(FloatingPointB);
        UpdateFloatingPointPosition(FloatingPointC);

        Vector3 lastBoatPosition = transform.position;
        Quaternion lastBoatRotation = transform.rotation;

        Vector3 a = FloatingPointA.position;
        Vector3 b = FloatingPointB.position;
        Vector3 c = FloatingPointC.position;

        Vector3 ab = b - a;
        Vector3 ac = c - a;;
        Vector3 targetPosition = (a + b + c) / 3;

        Vector3 targetUpwardDirection = Vector3.Cross(ac, ab);
        Vector3 targetForwardDirection = a - targetPosition;
        Quaternion targetRotation = Quaternion.LookRotation(targetForwardDirection, targetUpwardDirection);

        Vector3 dampenedPosition = Vector3.Lerp(lastBoatPosition, targetPosition, positionDampen);
        Quaternion dampenedRotation = Quaternion.Lerp(lastBoatRotation, targetRotation, rotationDampen);

        transform.SetPositionAndRotation(dampenedPosition, dampenedRotation);
    }

    private void UpdateFloatingPointPosition(Transform point)
    {
        Vector3 pos = point.position;
        float waterLine = GerstnerWavesPhysics.Instance.GetWaterLineAtPos(pos);

        point.transform.position = new Vector3(pos.x, waterLine, pos.z);
    }
}