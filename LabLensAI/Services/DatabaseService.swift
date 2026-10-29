import Foundation
import Combine

/// Manages retrieval and caching of verified laboratory equipment, chemical safety, and SOP data
public final class DatabaseService: ObservableObject {
    public static let shared = DatabaseService()
    
    @Published public private(set) var equipmentList: [Equipment] = []
    @Published public private(set) var chemicalsList: [Chemical] = []
    @Published public private(set) var sopList: [SOPProtocol] = []
    
    private init() {
        loadBundledData()
    }
    
    public func loadBundledData() {
        self.equipmentList = loadDecodable(from: "equipment_db") ?? Self.sampleEquipmentData
        self.chemicalsList = loadDecodable(from: "chemicals_db") ?? Self.sampleChemicalsData
        self.sopList = loadDecodable(from: "sops_db") ?? Self.sampleSOPData
    }
    
    private func loadDecodable<T: Decodable>(from filename: String) -> T? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }
    
    public func findEquipment(byIdentifier identifier: String) -> Equipment? {
        let normalized = identifier.lowercased().replacingOccurrences(of: " ", with: "_")
        return equipmentList.first {
            $0.id.lowercased() == normalized ||
            $0.modelIdentifier.lowercased() == normalized ||
            $0.name.lowercased().contains(identifier.lowercased())
        }
    }
    
    public func findChemical(byQuery query: String) -> [Chemical] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return chemicalsList }
        let q = query.lowercased()
        return chemicalsList.filter {
            $0.commonName.lowercased().contains(q) ||
            $0.chemicalFormula.lowercased().contains(q) ||
            $0.casRegistryNumber.contains(q)
        }
    }
    
    public func getSOPs(forEquipmentId equipmentId: String) -> [SOPProtocol] {
        return sopList.filter { $0.targetEquipmentId == equipmentId }
    }
    
    // MARK: - Built-in verified sample repository (Offline Fallback)
    public static let sampleEquipmentData: [Equipment] = [
        Equipment(
            id: "micropipette",
            name: "Single-Channel Micropipette (P200 / P1000)",
            modelIdentifier: "micropipette",
            category: .liquidHandling,
            purpose: "Precision volumetric measurement and liquid transfer in the range of 20 µL to 1000 µL for biochemical assays.",
            workingPrinciple: "Air displacement principle: Depression of a plunger displaces a defined column of air inside a piston cylinder, aspirating liquid upon release via positive/negative atmospheric differential.",
            usageGuidelines: [
                "Always affix a sterile aerosol-barrier pipette tip before liquid aspiration.",
                "Depress plunger to the first stop before immersing tip 2-3 mm into liquid.",
                "Slowly release plunger to avoid cavitation and aerosol generation.",
                "Depress to second blowout stop when dispensing into vessel.",
                "Eject tip immediately into designated biohazard sharps container."
            ],
            safetyPrecautions: [
                "Never invert or lay down a micropipette with liquid in the tip to prevent corrosive liquid ingress into the internal piston.",
                "Do not exceed the minimum or maximum calibrated volume limits stamped on the dial.",
                "Decontaminate body with 70% isopropanol between protocol transitions."
            ],
            maintenanceInfo: [
                "Annual gravimetric calibration using ASTM E1154 ten-replicate weighing protocol.",
                "Inspect O-rings and piston shaft monthly for grease degradation or scoring.",
                "Autoclave shaft only if manufacturer specifies autoclavable construction (121°C, 15 psi, 20 min)."
            ],
            associatedSOPIds: ["SOP-LH-001"],
            technicalSpecs: [
                "Accuracy (Inaccuracy %)" : "±0.8% at nominal volume",
                "Precision (Imprecision %)" : "<0.3% CV",
                "Stroke Mechanism" : "Friction-reduced stainless steel piston"
            ],
            primaryHazardLevel: .low
        ),
        Equipment(
            id: "optical_microscope",
            name: "Binocular Compound Optical Microscope",
            modelIdentifier: "optical_microscope",
            category: .opticalImaging,
            purpose: "Magnified visual inspection and cellular morphology examination of specimen glass slides under transmitted brightfield illumination.",
            workingPrinciple: "Two-stage optical magnification utilizing objective lens sets (4x, 10x, 40x, 100x oil immersion) coupled with an ocular lens system (10x), focusing Kohler-illuminated light through an Abbe condenser.",
            usageGuidelines: [
                "Always initiate specimen focusing using the lowest power objective (4x) and coarse adjustment knob.",
                "Transition to fine focus knob when switching to 40x or 100x magnification.",
                "When using the 100x oil immersion objective, place exactly one drop of Type A immersion oil on the coverslip.",
                "Clean oil residue immediately after examination using lens paper moistened with sparkle lens solution."
            ],
            safetyPrecautions: [
                "Do not force objective lenses against the glass stage; mechanical collision will shatter slides and score front lenses.",
                "Turn dimmer to minimum before powering off halogen light sources to prevent filament thermal shock."
            ],
            maintenanceInfo: [
                "Clean ocular and objective lenses strictly with optical lens paper, never Kimwipes or tissue.",
                "Check alignment of Abbe condenser centering screws quarterly.",
                "Cover with antistatic vinyl dust cover when not in active operation."
            ],
            associatedSOPIds: ["SOP-OI-002"],
            technicalSpecs: [
                "Total Magnification" : "40x – 1000x",
                "Condenser" : "Abbe Condenser N.A. 1.25 with iris diaphragm",
                "Illumination" : "3W Kohler LED / 6V 30W Halogen"
            ],
            primaryHazardLevel: .low
        ),
        Equipment(
            id: "benchtop_centrifuge",
            name: "High-Speed Refrigerated Microcentrifuge",
            modelIdentifier: "benchtop_centrifuge",
            category: .separationCentrifugation,
            purpose: "Centrifugal separation of cellular lysates, nucleic acids, and precipitated proteins based on sedimentation density.",
            workingPrinciple: "Rotational acceleration creates a centrifugal force field (RCF = 1.118 × 10^-5 × r × RPM^2) that forces particles of higher density outward toward tube bottoms.",
            usageGuidelines: [
                "Crucial: Balance tubes symmetrically with matching mass across the rotor axis (within ±0.05 grams).",
                "Fasten aerosol-tight rotor lid securely prior to closing centrifuge canopy.",
                "Pre-chill chamber to 4°C for RNA and enzyme stability before high-speed spins."
            ],
            safetyPrecautions: [
                "Never operate with an unbalanced rotor load; rotor oscillation at high angular velocities can shatter the drive shaft.",
                "Do not attempt manual lid opening or override the electronic lid safety interlock while rotor is decelerating.",
                "In case of abnormal acoustic vibration or screeching, press Emergency Stop immediately."
            ],
            maintenanceInfo: [
                "Inspect anodized aluminum rotor for micro-cracks or pitting corrosion weekly.",
                "Lubricate rotor O-rings and drive spindle with silicone lubricant monthly.",
                "Clean condensation tray after refrigerated operations to avoid microbial biofilm formation."
            ],
            associatedSOPIds: ["SOP-SC-003"],
            technicalSpecs: [
                "Max Speed" : "15,000 RPM (21,300 × g)",
                "Temperature Range" : "-10°C to +40°C",
                "Rotor Capacity" : "24 × 1.5 / 2.0 mL microcentrifuge tubes"
            ],
            primaryHazardLevel: .moderate
        ),
        Equipment(
            id: "thermal_cycler_pcr",
            name: "Gradient Thermal Cycler (PCR Machine)",
            modelIdentifier: "thermal_cycler_pcr",
            category: .thermalAmplification,
            purpose: "Automated in vitro amplification of DNA fragments through enzymatic thermal cycling (denaturation, annealing, extension).",
            workingPrinciple: "Thermoelectric Peltier effect modules rapidly ramp temperature up and down across calibrated wells with an electrically heated lid to prevent sample vapor condensation.",
            usageGuidelines: [
                "Use optical 0.2 mL thin-walled PCR reaction tubes or 96-well plates sealed with optical adhesive films.",
                "Tighten heated lid clamping mechanism to 105°C to avoid evaporation.",
                "Set gradient annealing temperatures based on primer melting temperature (Tm - 5°C)."
            ],
            safetyPrecautions: [
                "Heated lid surfaces exceed 105°C; do not touch inner block surfaces while cycle is running.",
                "Ensure ventilation grills on side and rear maintain a minimum 10 cm clearance to prevent Peltier overheating."
            ],
            maintenanceInfo: [
                "Perform temperature verification using thermal probe calibration block biannually.",
                "Decontaminate sample blocks with 10% bleach followed by sterile deionized water.",
                "Inspect cooling fan filter for dust accumulation monthly."
            ],
            associatedSOPIds: ["SOP-TA-004"],
            technicalSpecs: [
                "Ramping Rate" : "Up to 5.0°C/sec heating, 4.0°C/sec cooling",
                "Temperature Range" : "4.0°C to 99.9°C",
                "Heated Lid Temp" : "Up to 110°C"
            ],
            primaryHazardLevel: .moderate
        ),
        Equipment(
            id: "co2_incubator",
            name: "Laboratory Cell Culture / Bacteriological Incubator",
            modelIdentifier: "co2_incubator",
            category: .incubationCulture,
            purpose: "Controlled environmental incubation maintaining constant 37°C temperature, 5% CO2 atmospheric partial pressure, and 95% humidity for eukaryotic cell viability.",
            workingPrinciple: "Direct-heat or water-jacketed air circulation with infrared (IR) CO2 sensor feedback and PID microprocessor heating controls.",
            usageGuidelines: [
                "Check water pan level weekly; replenish only with sterile autoclaved deionized water containing 0.01% copper sulfate.",
                "Minimize door opening duration to prevent gas stratification and temperature drops.",
                "Inspect CO2 gas cylinder inlet pressure regulator (maintain 15–20 psi supply)."
            ],
            safetyPrecautions: [
                "CO2 displacement hazard: Ensure lab has ambient O2 monitoring if multiple incubators share confined rooms.",
                "Biohazard Class II containment protocols apply to all cultivated primary mammalian cultures."
            ],
            maintenanceInfo: [
                "Run 180°C high-heat dry air decontamination cycle quarterly or following culture contamination.",
                "Calibrate CO2 zero point using external Fyrite / infrared sensor annually.",
                "Replace internal HEPA air filter every 6 months."
            ],
            associatedSOPIds: ["SOP-IC-005"],
            technicalSpecs: [
                "Chamber Volume" : "170 Liters",
                "CO2 Concentration Range" : "0.1% to 20.0% (±0.1%)",
                "Temperature Uniformity" : "±0.25°C at 37°C"
            ],
            primaryHazardLevel: .moderate
        ),
        Equipment(
            id: "uv_vis_spectrophotometer",
            name: "UV-Visible Double-Beam Spectrophotometer",
            modelIdentifier: "uv_vis_spectrophotometer",
            category: .analyticalSpectroscopy,
            purpose: "Quantitative measurement of light absorption or transmission across UV and visible spectra (190 nm – 1100 nm) for nucleic acid purity (A260/A280) and protein concentration.",
            workingPrinciple: "Beer-Lambert Law (A = ε·c·l): Deuterium (UV) and Tungsten-halogen (Vis) lamps emit collimated light through a monochromator diffraction grating; transmitted photons are quantified by silicon photodiode detectors.",
            usageGuidelines: [
                "Always use high-purity quartz cuvettes for wavelength measurements below 340 nm; optical polystyrene absorbs UV.",
                "Handle cuvettes only by frosted side surfaces; optical faces must remain pristine.",
                "Perform baseline auto-zero calibration with matching blank solvent before analyte acquisition."
            ],
            safetyPrecautions: [
                "Deuterium discharge lamps emit intense UV-C radiation. Never operate housing with lamp cover removed.",
                "Inspect cuvette compartment for fluid leakage to prevent corrosive damage to internal mirror galvanometers."
            ],
            maintenanceInfo: [
                "Check wavelength accuracy using Holmium oxide filter calibration test annually (±0.3 nm).",
                "Record cumulative deuterium lamp operating hours (replace after 2,000 operational hours).",
                "Store cuvettes in padded protective cases after cleaning with spectroscopic-grade ethanol."
            ],
            associatedSOPIds: ["SOP-AS-006"],
            technicalSpecs: [
                "Wavelength Range" : "190 nm to 1100 nm",
                "Spectral Bandwidth" : "1.0 nm",
                "Photometric Range" : "-0.3 to 3.0 Abs"
            ],
            primaryHazardLevel: .low
        ),
        Equipment(
            id: "laboratory_glassware",
            name: "Borosilicate Glassware (Erlenmeyer, Graduated Cylinder, Beaker)",
            modelIdentifier: "laboratory_glassware",
            category: .laboratoryGlassware,
            purpose: "Reagent containment, liquid volumetric measurements, dissolution, stoichiometric titration, and heating reactions.",
            workingPrinciple: "Low thermal expansion Type 3.3 borosilicate glass resisting thermal shock gradients up to 160°C and offering broad chemical inertness to mineral acids and organic solvents.",
            usageGuidelines: [
                "Inspect glass bodies for star-cracks, edge chips, or strain scratches before applying vacuum or direct heat.",
                "Read liquid meniscus strictly at eye level at the bottom of the curve for aqueous wetting fluids.",
                "Graduated cylinders and beakers are approximate; use volumetric flasks for analytical precision calibration."
            ],
            safetyPrecautions: [
                "Never expose chipped glassware to vacuum filtration; catastrophic implosion risk.",
                "Allow hot glassware to cool on ceramic heat-resistant pads; never quench hot Pyrex in cold water sinks."
            ],
            maintenanceInfo: [
                "Wash with non-abrasive laboratory detergent (Alconox 1%) followed by triple deionized water rinse.",
                "Dry in dedicated 60°C laboratory drying ovens.",
                "Discard scored or chipped units immediately into dedicated Broken Glass Disposal bins."
            ],
            associatedSOPIds: ["SOP-GW-007"],
            technicalSpecs: [
                "Glass Material" : "Borosilicate 3.3 Glass (ISO 3585)",
                "Thermal Shock Resistance" : "ΔT = 100 K",
                "Maximum Safe Temperature" : "500°C"
            ],
            primaryHazardLevel: .low
        )
    ]
    
    public static let sampleChemicalsData: [Chemical] = [
        Chemical(
            id: "chem-ethidium-bromide",
            commonName: "Ethidium Bromide (1% Aqueous Solution)",
            chemicalFormula: "C21H20BrN3",
            casRegistryNumber: "1239-45-8",
            ghsHazardClasses: ["Acute Toxicity (Oral/Inh) 2", "Germ Cell Mutagenicity 1B", "Carcinogenicity 2"],
            signalWord: .danger,
            hazardStatements: [
                "H330: Fatal if inhaled",
                "H340: May cause genetic defects",
                "H351: Suspected of causing cancer"
            ],
            precautionaryStatements: [
                "P201: Obtain special instructions before use",
                "P280: Wear protective gloves and eye protection",
                "P304+P340: IF INHALED: Remove person to fresh air"
            ],
            requiredPPE: [.nitrileGloves, .splashGoggles, .flameResistantLabCoat, .fumeHood],
            storageRequirements: Chemical.StorageCondition(
                temperature: "15°C - 25°C Room Temp",
                flammabilityCabinet: false,
                lightSensitive: true,
                incompatibilityGroups: ["Strong oxidizing agents"]
            ),
            emergencyFirstAid: Chemical.FirstAidProtocols(
                skinContact: "Wash immediately with soap and copious running water for 15 minutes. Discard contaminated gloves into biohazard waste.",
                eyeContact: "Irrigate eyes immediately at eyewash fountain for 15+ minutes holding eyelids wide open. Seek immediate medical attention.",
                inhalation: "Evacuate contaminated area immediately to fresh air. Administer oxygen if breathing is labored.",
                ingestion: "Do NOT induce vomiting. Rinse mouth thoroughly with water. Contact poison control immediately."
            ),
            wasteDisposalCategory: "Hazardous Chemical Mutagen Waste (Pass through activated charcoal filtration de-staining columns or incinerate via licensed contractor)."
        ),
        Chemical(
            id: "chem-isopropanol",
            commonName: "Isopropanol (2-Propanol / 70% Disinfection Grade)",
            chemicalFormula: "C3H8O",
            casRegistryNumber: "67-63-0",
            ghsHazardClasses: ["Flammable Liquids 2", "Eye Irritation 2A", "Specific Target Organ Toxicity Single Exposure 3"],
            signalWord: .danger,
            hazardStatements: [
                "H225: Highly flammable liquid and vapor",
                "H319: Causes serious eye irritation",
                "H336: May cause drowsiness or dizziness"
            ],
            precautionaryStatements: [
                "P210: Keep away from heat, hot surfaces, sparks, and open flames",
                "P233: Keep container tightly closed"
            ],
            requiredPPE: [.nitrileGloves, .splashGoggles, .flameResistantLabCoat],
            storageRequirements: Chemical.StorageCondition(
                temperature: "15°C - 25°C",
                flammabilityCabinet: true,
                lightSensitive: false,
                incompatibilityGroups: ["Strong oxidizers", "Acids", "Halogens", "Aluminum"]
            ),
            emergencyFirstAid: Chemical.FirstAidProtocols(
                skinContact: "Rinse skin with water. Apply moisturizer if dryness occurs.",
                eyeContact: "Flush cautiously with water for several minutes. Remove contact lenses if present.",
                inhalation: "Move to fresh air. Keep at rest in position comfortable for breathing.",
                ingestion: "Rinse mouth. Do not induce vomiting. Seek medical evaluation."
            ),
            wasteDisposalCategory: "Non-halogenated organic flammable solvent waste."
        ),
        Chemical(
            id: "chem-sodium-hydroxide",
            commonName: "Sodium Hydroxide Pellets (10N Solution)",
            chemicalFormula: "NaOH",
            casRegistryNumber: "1310-73-2",
            ghsHazardClasses: ["Skin Corrosion 1A", "Serious Eye Damage 1", "Corrosive to Metals 1"],
            signalWord: .danger,
            hazardStatements: [
                "H314: Causes severe skin burns and serious eye damage",
                "H290: May be corrosive to metals"
            ],
            precautionaryStatements: [
                "P260: Do not breathe dust or mist",
                "P280: Wear protective gloves/clothing/eye protection/face shield"
            ],
            requiredPPE: [.nitrileGloves, .splashGoggles, .faceShield, .flameResistantLabCoat],
            storageRequirements: Chemical.StorageCondition(
                temperature: "15°C - 30°C",
                flammabilityCabinet: false,
                lightSensitive: false,
                incompatibilityGroups: ["Strong acids", "Water (exothermic)", "Aluminum", "Zinc"]
            ),
            emergencyFirstAid: Chemical.FirstAidProtocols(
                skinContact: "Immediately wash under safety shower for 20 minutes while stripping contaminated clothing.",
                eyeContact: "Copious eyewash irrigation for 20 minutes; alkaline ocular burns require urgent ophthalmologic intervention.",
                inhalation: "Remove to fresh air. Provide artificial respiration if not breathing.",
                ingestion: "Never induce vomiting. Administer 1-2 glasses of water if conscious. Urgent hospital transport."
            ),
            wasteDisposalCategory: "Inorganic alkaline caustic waste. Neutralize carefully with weak acid before sewer disposal if permitted."
        )
    ]
    
    public static let sampleSOPData: [SOPProtocol] = [
        SOPProtocol(
            id: "SOP-LH-001",
            title: "Standard Operating Procedure: Pipetting Accuracy & Calibration Verification",
            standardCode: "ISO 8655-2",
            targetEquipmentId: "micropipette",
            estimatedDurationMinutes: 25,
            prerequisiteTraining: "Biosafety Level 1 Training & Pipette Handling Primer",
            ppeChecklist: ["Nitrile Gloves", "Safety Goggles", "Lab Coat"],
            executionSteps: [
                SOPProtocol.ProtocolStep(
                    id: 1,
                    stageTitle: "Equipment & Balance Pre-conditioning",
                    instruction: "Place analytical balance (0.0001g resolution) and deionized water in a draft-free enclosure at 20°C ± 1°C for 2 hours.",
                    safetyWarning: "Avoid direct sunlight on balance chamber.",
                    timerDurationSeconds: 120
                ),
                SOPProtocol.ProtocolStep(
                    id: 2,
                    stageTitle: "Pre-wetting Pipette Tip",
                    instruction: "Aspirate and dispense nominal volume 3 consecutive times to equilibrate vapor pressure within the tip dead air volume.",
                    safetyWarning: nil,
                    timerDurationSeconds: 15
                ),
                SOPProtocol.ProtocolStep(
                    id: 3,
                    stageTitle: "Aspiration Technique",
                    instruction: "Immerse tip vertically 2-3 mm beneath surface. Depress to first stop, release slowly over 2 seconds, pause 1 second before withdrawing.",
                    safetyWarning: "Never tilt pipette greater than 20 degrees during aspiration.",
                    timerDurationSeconds: 10
                ),
                SOPProtocol.ProtocolStep(
                    id: 4,
                    stageTitle: "Dispensing & Taring",
                    instruction: "Touch tip at a 45° angle to the tare vessel inner wall. Depress to first stop, pause, depress to blowout stop. Tare balance.",
                    safetyWarning: nil,
                    timerDurationSeconds: 10
                )
            ],
            qualityControlNotes: [
                "Perform 10 replicate weighings at 10%, 50%, and 100% of nominal volume.",
                "Convert mass to volume using Z-factor calculation: V = W * Z."
            ],
            version: "v2.1"
        ),
        SOPProtocol(
            id: "SOP-SC-003",
            title: "Standard Operating Procedure: Cell Pellet Harvesting via High-Speed Centrifugation",
            standardCode: "OSHA 1910.1450 / SOP-BIO-04",
            targetEquipmentId: "benchtop_centrifuge",
            estimatedDurationMinutes: 20,
            prerequisiteTraining: "Centrifuge Safety Certification",
            ppeChecklist: ["Nitrile Gloves", "Splash Goggles", "Lab Coat"],
            executionSteps: [
                SOPProtocol.ProtocolStep(
                    id: 1,
                    stageTitle: "Tube Mass Matching & Counterbalancing",
                    instruction: "Fill centrifuge tubes with equal volume. Place on precision balance; pair tubes to within ±0.02 grams variance.",
                    safetyWarning: "Operating an unbalanced rotor risks catastrophic drive shaft failure.",
                    timerDurationSeconds: 60
                ),
                SOPProtocol.ProtocolStep(
                    id: 2,
                    stageTitle: "Symmetric Rotor Loading",
                    instruction: "Place matched tubes directly opposite one another across rotor diameter (e.g. position 1 and position 13).",
                    safetyWarning: "Ensure aerosol-tight lid is threaded securely on the rotor.",
                    timerDurationSeconds: 30
                ),
                SOPProtocol.ProtocolStep(
                    id: 3,
                    stageTitle: "Parameter Configuration & Spin Execution",
                    instruction: "Set speed to 12,000 RPM (14,000 × g), chamber temperature to 4°C, duration to 10 minutes. Press Start.",
                    safetyWarning: "Stand clear of centrifuge during initial 60-second ramp-up.",
                    timerDurationSeconds: 600
                ),
                SOPProtocol.ProtocolStep(
                    id: 4,
                    stageTitle: "Supernatant Aspiration & Pellet Inspection",
                    instruction: "Aspirate supernatant carefully without disrupting the clear pellet at the tube bottom.",
                    safetyWarning: "Dispose supernatant into appropriate biohazard waste.",
                    timerDurationSeconds: 180
                )
            ],
            qualityControlNotes: [
                "Verify rotor seal integrity before starting.",
                "Log spin hours into centrifuge maintenance register."
            ],
            version: "v3.0"
        )
    ]
}
