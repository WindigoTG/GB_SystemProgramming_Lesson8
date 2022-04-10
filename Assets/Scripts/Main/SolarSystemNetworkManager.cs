using Characters;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.UI;

namespace Main
{
    public class SolarSystemNetworkManager : NetworkManager
    {
        [SerializeField] private string _playerName;
        [SerializeField] InputField _nameInput;
        private short _nameMessage = MsgType.Highest + 1;

        private Dictionary<int, string> _playerNamesByConnID;

        private Dictionary<int, NetworkConnection> _connections;
        private Dictionary<int, short> _playerControllerIDs;

        public static SolarSystemNetworkManager Instance { get; private set; }

        private void Awake()
        {
            Instance = this;
        }

        public override void OnServerAddPlayer(NetworkConnection conn, short playerControllerId)
        {
            _connections.Add(conn.connectionId, conn);
            _playerControllerIDs.Add(conn.connectionId, playerControllerId);
        }

        public Transform GetSpawnPosition()
        {
            return GetStartPosition();
        }

        public override void OnStartServer()
        {
            base.OnStartServer();
            NetworkServer.RegisterHandler(_nameMessage, OnServerReceiveNameMessage);
            _playerNamesByConnID = new Dictionary<int, string>();
            _connections = new Dictionary<int, NetworkConnection>();
            _playerControllerIDs = new Dictionary<int, short>();
            _nameInput.gameObject.SetActive(false);
        }

        private void OnServerReceiveNameMessage(NetworkMessage netMsg)
        {
            NameMessage msg = netMsg.ReadMessage<NameMessage>();
            var name = msg.Name;
            if (string.IsNullOrWhiteSpace(name))
                name = $"Player {netMsg.conn.connectionId}";
            _playerNamesByConnID.Add(netMsg.conn.connectionId, name);

            AddPlayer(netMsg.conn.connectionId);
        }

        private void AddPlayer(int connID)
        {
            var spawnTransform = GetStartPosition();
            var player = Instantiate(playerPrefab, spawnTransform.position, spawnTransform.rotation);

            player.GetComponent<ShipController>().PlayerName = _playerNamesByConnID[connID];

            NetworkServer.AddPlayerForConnection(_connections[connID], player, _playerControllerIDs[connID]);
        }

        public override void OnClientConnect(NetworkConnection conn)
        {
            base.OnClientConnect(conn);
            _nameInput.gameObject.SetActive(false);
            SendNameMessage(_nameInput.text);
        }

        private void SendNameMessage(string name)
        {
            NameMessage msg = new NameMessage();
            msg.Name = name;
            client.Send(_nameMessage, msg);
        }
    }

    public class NameMessage : MessageBase
    {
        public string Name;
    }
}

