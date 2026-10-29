import Foundation

/// Represents a laboratory instrument recognized by the LabLens AI Vision system
public struct Equipment: Identifiable, Codable, Equatable, Hashable {
    public let id: String
    public let name: String
    public let modelIdentifier: String
    public let category: EquipmentCategory
    public let purpose: String
    public let workingPrinciple: String
    public let usageGuidelines: [String]
    public let safetyPrecautions: [String]
    public let maintenanceInfo: [String]
    public let associatedSOPIds: [String]
    public let technicalSpecs: [String: String]
    public let primaryHazardLevel: HazardLevel
    
    public enum EquipmentCategory: String, Codable {
        case liquidHandling = "Liquid Handling"
        case opticalImaging = "Optical Imaging"
        case separationCentrifugation = "Separation & Centrifugation"
        case thermalAmplification = "Thermal Amplification"
        case incubationCulture = "Incubation & Cell Culture"
        case analyticalSpectroscopy = "Analytical Spectroscopy"
        case laboratoryGlassware = "Volumetric & General Glassware"
    }
    
    public enum HazardLevel: String, Codable {
        case low = "Low Risk (Standard PPE)"
        case moderate = "Moderate Risk (Specific Operational Training Required)"
        case high = "High Risk (Biohazard / High Voltage / Thermal Hazard)"
    }
}
