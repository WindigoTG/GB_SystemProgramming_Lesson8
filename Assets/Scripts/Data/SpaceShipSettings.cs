using UnityEngine;
namespace Data
{
    [CreateAssetMenu(fileName = "SpaceShipSettings", menuName =
    "Geekbrains/Settings/Space Ship Settings")]
    public class SpaceShipSettings : ScriptableObject
    {
        public float Acceleration => _acceleration;
        public float ShipSpeed => _shipSpeed;
        public float Faster => _faster;
        public float NormalFov => _normalFov;
        public float FasterFov => _fasterFov;
        public float ChangeFovSpeed => _changeFovSpeed;

        [SerializeField, Range(.01f, 0.1f)] private float _acceleration;
        [SerializeField, Range(1f, 2000f)] private float _shipSpeed;
        [SerializeField, Range(1f, 5f)] private int _faster;
        [SerializeField, Range(.01f, 179)] private float _normalFov = 60;
        [SerializeField, Range(.01f, 179)] private float _fasterFov = 30;
        [SerializeField, Range(.1f, 5f)] private float _changeFovSpeed = .5f;
    }
}
