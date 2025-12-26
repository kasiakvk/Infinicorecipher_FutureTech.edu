using UnityEngine;
using Unity.Netcode;

namespace GalacticCode.Core
{
    /// <summary>
    /// Main game manager for Galactic Code educational competitive gaming
    /// Handles game state, educational content integration, and COPPA compliance
    /// </summary>
    public class GameManager : NetworkBehaviour
    {
        [Header("Game Configuration")]
        public bool isEducationalMode = true;
        public bool isCOPPACompliant = true;
        
        [Header("Educational Settings")]
        public EducationalLevel targetLevel = EducationalLevel.MiddleSchool;
        public CurriculumStandard[] alignedStandards;
        
        private static GameManager _instance;
        public static GameManager Instance => _instance;
        
        private void Awake()
        {
            if (_instance != null && _instance != this)
            {
                Destroy(gameObject);
                return;
            }
            
            _instance = this;
            DontDestroyOnLoad(gameObject);
            
            InitializeGame();
        }
        
        private void InitializeGame()
        {
            Debug.Log("Galactic Code: Initializing educational competitive gaming platform");
            
            // Initialize educational compliance
            if (isCOPPACompliant)
            {
                InitializeCOPPACompliance();
            }
            
            // Initialize educational content system
            if (isEducationalMode)
            {
                InitializeEducationalSystems();
            }
        }
        
        private void InitializeCOPPACompliance()
        {
            Debug.Log("Initializing COPPA compliance systems");
            // TODO: Implement COPPA compliance initialization
        }
        
        private void InitializeEducationalSystems()
        {
            Debug.Log("Initializing educational content systems");
            // TODO: Implement educational content initialization
        }
        
        public override void OnNetworkSpawn()
        {
            if (IsServer)
            {
                Debug.Log("Game Manager spawned on server");
            }
        }
    }
    
    [System.Serializable]
    public enum EducationalLevel
    {
        Elementary,
        MiddleSchool,
        HighSchool,
        Mixed
    }
    
    [System.Serializable]
    public enum CurriculumStandard
    {
        CommonCoreMath,
        NGSS,
        ComputerScience,
        TwentyFirstCenturySkills
    }
}
