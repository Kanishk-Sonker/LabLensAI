import Foundation

/// Represents validated Standard Operating Procedures (SOPs) linked to instruments and protocols
public struct SOPProtocol: Identifiable, Codable, Equatable, Hashable {
    public let id: String
    public let title: String
    public let standardCode: String
    public let targetEquipmentId: String
    public let estimatedDurationMinutes: Int
    public let prerequisiteTraining: String
    public let ppeChecklist: [String]
    public let executionSteps: [ProtocolStep]
    public let qualityControlNotes: [String]
    public let version: String
    
    public struct ProtocolStep: Identifiable, Codable, Equatable, Hashable {
        public let id: Int
        public let stageTitle: String
        public let instruction: String
        public let safetyWarning: String?
        public let timerDurationSeconds: Int?
    }
}
