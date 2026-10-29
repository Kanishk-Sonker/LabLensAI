import Foundation
import AVFoundation

/// Handles real-time laboratory asset QR code detection and standard resource parsing
public final class QRScannerService: NSObject, ObservableObject {
    public static let shared = QRScannerService()
    
    @Published public private(set) var scannedCode: String?
    @Published public private(set) var scannedPayloadType: PayloadType?
    
    public enum PayloadType: Equatable {
        case equipmentTag(id: String)
        case chemicalTag(cas: String)
        case sopProtocol(sopId: String)
        case rawUrl(URL)
    }
    
    public func parseCode(_ stringValue: String) {
        self.scannedCode = stringValue
        
        if stringValue.hasPrefix("LABLENS:EQUIP:") {
            let id = stringValue.replacingOccurrences(of: "LABLENS:EQUIP:", with: "")
            self.scannedPayloadType = .equipmentTag(id: id)
        } else if stringValue.hasPrefix("LABLENS:CHEM:") {
            let cas = stringValue.replacingOccurrences(of: "LABLENS:CHEM:", with: "")
            self.scannedPayloadType = .chemicalTag(cas: cas)
        } else if stringValue.hasPrefix("LABLENS:SOP:") {
            let sopId = stringValue.replacingOccurrences(of: "LABLENS:SOP:", with: "")
            self.scannedPayloadType = .sopProtocol(sopId: sopId)
        } else if let url = URL(string: stringValue), url.scheme == "https" {
            self.scannedPayloadType = .rawUrl(url)
        } else {
            self.scannedPayloadType = .equipmentTag(id: stringValue)
        }
    }
}
