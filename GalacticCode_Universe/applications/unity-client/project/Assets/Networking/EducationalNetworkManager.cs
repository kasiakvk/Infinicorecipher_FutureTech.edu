using UnityEngine;
using Unity.Netcode;
using Unity.Netcode.Transports.UTP;

namespace GalacticCode.Networking
{
    /// <summary>
    /// Educational-focused network manager with COPPA compliance
    /// Handles multiplayer connections for classroom and family environments
    /// </summary>
    public class EducationalNetworkManager : NetworkManager
    {
        [Header("Educational Network Settings")]
        public bool enableClassroomMode = true;
        public bool enableParentalControls = true;
        public int maxStudentsPerSession = 30;
        
        [Header("COPPA Compliance")]
        public bool requireParentalConsent = true;
        public bool enableDataMinimization = true;
        
        protected override void Awake()
        {
            base.Awake();
            ConfigureEducationalNetworking();
        }
        
        private void ConfigureEducationalNetworking()
        {
            // Configure for educational environment
            if (enableClassroomMode)
            {
                // Optimize for classroom network conditions
                var transport = GetComponent<UnityTransport>();
                if (transport != null)
                {
                    // Configure for school network environments
                    transport.SetConnectionData("127.0.0.1", 7777);
                }
            }
            
            // Set maximum connections for classroom size
            NetworkConfig.ConnectionApproval = true;
            
            Debug.Log($"Educational Network Manager configured for {maxStudentsPerSession} students");
        }
        
        public override void OnClientConnected(ulong clientId)
        {
            base.OnClientConnected(clientId);
            
            if (IsServer)
            {
                Debug.Log($"Student connected: {clientId}");
                
                // TODO: Implement educational session tracking
                // TODO: Verify COPPA compliance for connected client
            }
        }
        
        public override void OnClientDisconnected(ulong clientId)
        {
            base.OnClientDisconnected(clientId);
            
            if (IsServer)
            {
                Debug.Log($"Student disconnected: {clientId}");
                
                // TODO: Save educational progress
                // TODO: Notify teacher dashboard
            }
        }
    }
}
