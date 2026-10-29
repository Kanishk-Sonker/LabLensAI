import Foundation

/// Active countdown timer for sequential multi-stage laboratory procedures
public struct ExperimentTimer: Identifiable, Codable, Equatable {
    public let id: UUID
    public var protocolTitle: String
    public var stepName: String
    public var totalDurationSeconds: Int
    public var remainingSeconds: Int
    public var isRunning: Bool
    public var isCompleted: Bool
    public var startedAt: Date?
    
    public init(id: UUID = UUID(), protocolTitle: String, stepName: String, totalDurationSeconds: Int) {
        self.id = id
        self.protocolTitle = protocolTitle
        self.stepName = stepName
        self.totalDurationSeconds = totalDurationSeconds
        self.remainingSeconds = totalDurationSeconds
        self.isRunning = false
        self.isCompleted = false
        self.startedAt = nil
    }
}
