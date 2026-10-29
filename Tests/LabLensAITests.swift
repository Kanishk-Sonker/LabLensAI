import XCTest
@testable import LabLensAI

final class LabLensAITests: XCTestCase {
    
    var database: DatabaseService!
    var visionService: VisionClassifierService!
    var qrService: QRScannerService!
    
    override func setUp() {
        super.setUp()
        database = DatabaseService.shared
        visionService = VisionClassifierService.shared
        qrService = QRScannerService.shared
    }
    
    // Test Case TC-01: Equipment Database Integrity
    func testEquipmentDatabaseLoading() {
        XCTAssertFalse(database.equipmentList.isEmpty, "Equipment list should load bundled records")
        XCTAssertEqual(database.equipmentList.count, 7, "Expected exactly 7 initial laboratory instruments")
        
        let pipette = database.findEquipment(byIdentifier: "micropipette")
        XCTAssertNotNil(pipette, "Micropipette must be retrievable by ID")
        XCTAssertEqual(pipette?.category, .liquidHandling)
        XCTAssertEqual(pipette?.primaryHazardLevel, .low)
    }
    
    // Test Case TC-02: Chemical SDS Safety Lookup
    func testChemicalDatabaseLookup() {
        let results = database.findChemical(byQuery: "Ethidium")
        XCTAssertEqual(results.count, 1)
        
        let ethidium = results.first!
        XCTAssertEqual(ethidium.casRegistryNumber, "1239-45-8")
        XCTAssertEqual(ethidium.signalWord, .danger)
        XCTAssertTrue(ethidium.requiredPPE.contains(.fumeHood))
    }
    
    // Test Case TC-03: SOP Association Verification
    func testSOPAssociation() {
        let sops = database.getSOPs(forEquipmentId: "benchtop_centrifuge")
        XCTAssertFalse(sops.isEmpty, "Centrifuge must have linked SOP protocols")
        
        let centrifugeSOP = sops.first!
        XCTAssertEqual(centrifugeSOP.id, "SOP-SC-003")
        XCTAssertTrue(centrifugeSOP.executionSteps.count >= 4)
    }
    
    // Test Case TC-04: QR Code Decoding Logic
    func testQRCodeTagParsing() {
        qrService.parseCode("LABLENS:EQUIP:optical_microscope")
        XCTAssertEqual(qrService.scannedPayloadType, .equipmentTag(id: "optical_microscope"))
        
        qrService.parseCode("LABLENS:CHEM:1239-45-8")
        XCTAssertEqual(qrService.scannedPayloadType, .chemicalTag(cas: "1239-45-8"))
        
        qrService.parseCode("LABLENS:SOP:SOP-LH-001")
        XCTAssertEqual(qrService.scannedPayloadType, .sopProtocol(sopId: "SOP-LH-001"))
    }
    
    // Test Case TC-05: Vision Post-Processing & Confidence Thresholding
    func testVisionSmoothingAndThreshold() {
        visionService.confidenceThreshold = 0.75
        
        // Spurious prediction below threshold should NOT trigger a scan result
        visionService.postProcessPrediction(rawLabel: "optical_microscope", confidence: 0.62, latencyMs: 22.0)
        XCTAssertNil(visionService.latestResult)
        
        // Consistent predictions above threshold (3 frames)
        visionService.postProcessPrediction(rawLabel: "optical_microscope", confidence: 0.94, latencyMs: 20.5)
        visionService.postProcessPrediction(rawLabel: "optical_microscope", confidence: 0.96, latencyMs: 21.0)
        visionService.postProcessPrediction(rawLabel: "optical_microscope", confidence: 0.93, latencyMs: 19.8)
        
        XCTAssertNotNil(visionService.latestResult)
        XCTAssertEqual(visionService.latestResult?.matchedEquipmentId, "optical_microscope")
        XCTAssertGreaterThanOrEqual(visionService.latestResult?.confidence ?? 0, 0.90)
    }
}
