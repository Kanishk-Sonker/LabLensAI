import Foundation
import Combine
import SwiftUI
import AVFoundation

/// Coordinates live camera capture state, vision inference results, and navigation events
public final class CameraScannerViewModel: ObservableObject {
    @Published public var detectedEquipment: Equipment?
    @Published public var currentScanResult: ScanResult?
    @Published public var isScanningActive: Bool = true
    @Published public var isTorchOn: Bool = false
    @Published public var capturedFramesCount: Int = 0
    @Published public var fpsValue: Double = 29.8
    @Published public var activeModalEquipment: Equipment?
    @Published public var activeModalChemical: Chemical?
    
    private let visionService = VisionClassifierService.shared
    private let databaseService = DatabaseService.shared
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        bindVisionFeed()
    }
    
    private func bindVisionFeed() {
        visionService.$latestResult
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                self.currentScanResult = result
                self.capturedFramesCount += 1
                
                if let matchedId = result.matchedEquipmentId,
                   let equipment = self.databaseService.findEquipment(byIdentifier: matchedId) {
                    self.detectedEquipment = equipment
                }
            }
            .store(in: &cancellables)
            
        visionService.$currentInferenceFps
            .receive(on: DispatchQueue.main)
            .sink { [weak self] fps in
                self?.fpsValue = fps
            }
            .store(in: &cancellables)
    }
    
    /// Simulates/Triggers mock scan test for validation suites or desktop UI testing
    public func simulateEquipmentDetection(equipmentId: String) {
        if let eq = databaseService.findEquipment(byIdentifier: equipmentId) {
            let mockScan = ScanResult(
                label: eq.name,
                confidence: 0.942,
                boundingBox: CGRect(x: 0.2, y: 0.25, width: 0.6, height: 0.5),
                inferenceLatencyMs: 21.4,
                matchedEquipmentId: eq.id,
                hardwareTarget: "Apple Neural Engine (ANE) - FP16"
            )
            self.currentScanResult = mockScan
            self.detectedEquipment = eq
            self.activeModalEquipment = eq
        }
    }
    
    public func toggleTorch() {
        self.isTorchOn.toggle()
        // AVFoundation hardware torch trigger
    }
    
    public func resetScan() {
        self.detectedEquipment = nil
        self.currentScanResult = nil
        self.activeModalEquipment = nil
    }
}
