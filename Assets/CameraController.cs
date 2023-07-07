using System;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.InputSystem;

public class CameraController : MonoBehaviour
{
    [SerializeField] private Transform Camera;
    [SerializeField] private Transform Body;
    [SerializeField] private float MaxCameraRotationX = 90;
    [SerializeField] private float MinCameraRotationX = -90;

    private void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
    }

    public void OnLook(InputAction.CallbackContext context)
    {
        Debug.Log("OnLook");
        Vector2 delta = context.action.ReadValue<Vector2>();

        float rotationY = delta.x * Time.deltaTime;
        float rotationX = -delta.y * Time.deltaTime;


        Body.transform.Rotate(0, rotationY, 0);

        Camera.transform.Rotate(rotationX, 0, 0);
        Vector3 rotation = Camera.transform.localRotation.eulerAngles;
        if (Camera.transform.localRotation.eulerAngles.x > MaxCameraRotationX)
            Camera.transform.localRotation = Quaternion.Euler(MaxCameraRotationX, rotation.y, rotation.z);
        else if (Camera.transform.localRotation.eulerAngles.x < MinCameraRotationX)
            Camera.transform.localRotation = Quaternion.Euler(MinCameraRotationX, rotation.y, rotation.z);
    }
}