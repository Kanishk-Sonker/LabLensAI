import Foundation
import CoreGraphics

/// Real-time result emitted by the Vision + Core ML pipeline
public struct ScanResult: Identifiable, Equatable {
    public let id: UUID
    public let label: String
    public let confidence: Float
    public let boundingBox: CGRect?
    public let inferenceLatencyMs: Double
    public let matchedEquipmentId: String?
    public let timestamp: Date
    public let hardwareTarget: String
    
    public init(
        id: UUID = UUID(),
        label: String,
        confidence: Float,
        boundingBox: CGRect? = nil,
        inferenceLatencyMs: Double,
        matchedEquipmentId: String?,
        timestamp: Date = Date(),
        hardwareTarget: String = "Apple Neural Engine (ANE)"
    ) {
        self.id = id
        self.label = label
        self.confidence = confidence
        self.boundingBox = boundingBox
        self.inferenceLatencyMs = inferenceLatencyMs
        self.matchedEquipmentId = matchedEquipmentId
        self.timestamp = timestamp
        self.hardwareTarget = hardwareTarget
    }
}
