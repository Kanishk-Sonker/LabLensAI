import Foundation

/// Represents chemical reagent hazard profiles and standard handling requirements
public struct Chemical: Identifiable, Codable, Equatable, Hashable {
    public let id: String
    public let commonName: String
    public let chemicalFormula: String
    public let casRegistryNumber: String
    public let ghsHazardClasses: [String]
    public let signalWord: SignalWord
    public let hazardStatements: [String]
    public let precautionaryStatements: [String]
    public let requiredPPE: [PPEItem]
    public let storageRequirements: StorageCondition
    public let emergencyFirstAid: FirstAidProtocols
    public let wasteDisposalCategory: String
    
    public enum SignalWord: String, Codable {
        case danger = "DANGER"
        case warning = "WARNING"
        case nonHazardous = "CAUTION / NON-HAZARDOUS"
    }
    
    public enum PPEItem: String, Codable {
        case nitrileGloves = "Nitrile Gloves (4 mil+)"
        case splashGoggles = "ANSI Z87.1 Splash Goggles"
        case flameResistantLabCoat = "100% Cotton / Flame-Resistant Lab Coat"
        case fumeHood = "Certified Chemical Fume Hood (>100 FPM)"
        case faceShield = "Full Face Shield (Cryogenic/Splash)"
        case thermalGloves = "Thermal Resistant Autoclave Gloves"
    }
    
    public struct StorageCondition: Codable, Equatable, Hashable {
        public let temperature: String
        public let flammabilityCabinet: Bool
        public let lightSensitive: Bool
        public let incompatibilityGroups: [String]
    }
    
    public struct FirstAidProtocols: Codable, Equatable, Hashable {
        public let skinContact: String
        public let eyeContact: String
        public let inhalation: String
        public let ingestion: String
    }
}
