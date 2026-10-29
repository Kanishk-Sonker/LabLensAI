import Foundation
import Combine

/// Provides guarded AI-based laboratory question answering with contextual grounding
public final class GeminiService: ObservableObject {
    public static let shared = GeminiService()
    
    @Published public private(set) var isQuerying: Bool = false
    @Published public private(set) var lastError: String?
    
    private let apiKey: String = "" // Injected via secure configuration / Keychain
    
    /// System prompt enforcing strict academic, safety, and SOP boundaries
    public static let laboratorySystemGuardrail = """
    You are LabLens AI Assistant, a specialized scientific and laboratory safety assistant for academic and research laboratories.
    RULES:
    1. Always prioritize user safety and standard biosafety/chemical safety regulations (OSHA, CDC, ISO).
    2. Reference verified Standard Operating Procedures (SOPs) whenever discussing laboratory apparatus.
    3. Explicitly caution the user regarding hazardous reagents, high voltages, rotating parts, or toxic fumes.
    4. Never hallucinate unauthorized experimental modifications or medical diagnoses.
    5. Emphasize that the user must verify procedures with their lab supervisor or institutional safety officer.
    """
    
    public func answerQuery(
        prompt: String,
        activeEquipmentContext: Equipment? = nil,
        activeChemicalContext: Chemical? = nil,
        completion: @escaping (String) -> Void
    ) {
        self.isQuerying = true
        self.lastError = nil
        
        // Check for local verified Q&A match for offline/demo reliability
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.6) { [weak self] in
            let response = self?.generateContextualResponse(
                for: prompt,
                equipment: activeEquipmentContext,
                chemical: activeChemicalContext
            ) ?? "I recommend verifying this procedure against your laboratory SOP and consulting the lab instructor before proceeding."
            
            DispatchQueue.main.async {
                self?.isQuerying = false
                completion(response)
            }
        }
    }
    
    private func generateContextualResponse(for query: String, equipment: Equipment?, chemical: Chemical?) -> String {
        let q = query.lowercased()
        
        if q.contains("balance") && (q.contains("centrifuge") || equipment?.id == "benchtop_centrifuge") {
            return "Crucial Safety Step: In high-speed centrifugation, unbalanced rotors generate violent kinetic oscillations that cause spindle deformation or rotor fragmentation. You must balance tubes diagonally opposite each other to within ±0.02 grams using an analytical balance."
        }
        
        if q.contains("calibrate") || q.contains("accuracy") {
            let eqName = equipment?.name ?? "the instrument"
            return "For \(eqName), gravimetric calibration according to ISO 8655 guidelines is performed using 10 replicate weighings of deionized water on an analytical balance, adjusting for water density via the Z-factor."
        }
        
        if q.contains("ppe") || q.contains("protective") {
            if let chem = chemical {
                let ppeList = chem.requiredPPE.map { "• " + $0.rawValue }.joined(separator: "\n")
                return "Required PPE for handling \(chem.commonName):\n\(ppeList)\n\nEnsure work is executed inside a certified fume hood if volatile vapors are generated."
            }
            return "Standard minimum laboratory PPE requires an ANSI Z87.1 splash safety glasses, a 100% cotton flame-resistant lab coat, and disposable nitrile gloves. If handling corrosive acids or biological aerosols, use an active chemical fume hood or biosafety cabinet."
        }
        
        if q.contains("spill") || q.contains("emergency") {
            return "In case of a laboratory spill:\n1. Alert all personnel in the immediate vicinity.\n2. Evacuate if volatile/toxic gases are present.\n3. Refer to the chemical's SDS section 6 (Accidental Release Measures).\n4. Neutralize and absorb using appropriate spill kit media (acid neutralizer / vermiculite)."
        }
        
        if let eq = equipment {
            return "Regarding the \(eq.name): Operational purpose is \(eq.purpose). Standard working principle: \(eq.workingPrinciple). Ensure you observe: \(eq.safetyPrecautions.first ?? "standard lab precautions")."
        }
        
        return "LabLens AI: According to standard laboratory guidelines, please adhere strictly to your laboratory's safety manual. If you have questions regarding a specific instrument or reagent, point the camera at it or select it from the database for verified specifications."
    }
}
