import SwiftUI

public struct ChemicalSafetyView: View {
    @StateObject private var viewModel = ChemicalSafetyViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List(viewModel.filteredChemicals) { chem in
                NavigationLink(destination: ChemicalDetailCardView(chemical: chem)) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(chem.commonName)
                                .font(.headline)
                            Spacer()
                            Text(chem.signalWord.rawValue)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(chem.signalWord == .danger ? .red : .orange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background((chem.signalWord == .danger ? Color.red : Color.orange).opacity(0.15))
                                .cornerRadius(4)
                        }
                        
                        HStack(spacing: 8) {
                            Text("Formula: \(chem.chemicalFormula)")
                                .font(.caption.monospaced())
                                .foregroundColor(.secondary)
                            Text("•")
                            Text("CAS: \(chem.casRegistryNumber)")
                                .font(.caption.monospaced())
                                .foregroundColor(.secondary)
                        }
                        
                        Text(chem.hazardStatements.first ?? "Standard laboratory reagent precautions.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    .padding(.vertical, 4)
                }
            }
            .searchable(text: $viewModel.searchQuery, prompt: "Search by chemical name, formula, or CAS...")
            .navigationTitle("Chemical Safety")
        }
    }
}

public struct ChemicalDetailCardView: View {
    public let chemical: Chemical
    
    public init(chemical: Chemical) {
        self.chemical = chemical
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Chemical Header
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(chemical.signalWord.rawValue)
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(chemical.signalWord == .danger ? Color.red : Color.orange)
                            .cornerRadius(6)
                        Spacer()
                        Text("CAS: \(chemical.casRegistryNumber)")
                            .font(.caption.monospaced())
                            .foregroundColor(.secondary)
                    }
                    
                    Text(chemical.commonName)
                        .font(.title2.bold())
                    
                    Text(chemical.chemicalFormula)
                        .font(.title3.monospaced())
                        .foregroundColor(.blue)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                
                // GHS Hazard Statements
                VStack(alignment: .leading, spacing: 8) {
                    Label("GHS Hazard Statements", systemImage: "flame.fill")
                        .font(.headline)
                        .foregroundColor(.red)
                    
                    ForEach(chemical.hazardStatements, id: \.self) { stmt in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                            Text(stmt)
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                .background(Color.red.opacity(0.08))
                .cornerRadius(12)
                
                // Required PPE Checklist
                VStack(alignment: .leading, spacing: 8) {
                    Label("Required PPE Prior to Handling", systemImage: "person.fill.viewfinder")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    ForEach(chemical.requiredPPE, id: \.self) { ppe in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundColor(.green)
                            Text(ppe.rawValue)
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                
                // Storage Guidelines
                VStack(alignment: .leading, spacing: 8) {
                    Label("Storage & Incompatibility", systemImage: "archivebox.fill")
                        .font(.headline)
                    
                    HStack {
                        Text("Temperature:")
                            .font(.caption.bold())
                        Text(chemical.storageRequirements.temperature)
                            .font(.caption)
                    }
                    
                    HStack {
                        Text("Flammables Cabinet:")
                            .font(.caption.bold())
                        Text(chemical.storageRequirements.flammabilityCabinet ? "Required" : "Standard Cabinet")
                            .font(.caption)
                    }
                    
                    Text("Incompatible with: " + chemical.storageRequirements.incompatibilityGroups.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                
                // Emergency First-Aid Protocols
                VStack(alignment: .leading, spacing: 10) {
                    Label("Emergency First-Aid Measures", systemImage: "cross.case.fill")
                        .font(.headline)
                        .foregroundColor(.red)
                    
                    FirstAidRow(title: "Eye Contact", text: chemical.emergencyFirstAid.eyeContact)
                    FirstAidRow(title: "Skin Contact", text: chemical.emergencyFirstAid.skinContact)
                    FirstAidRow(title: "Inhalation", text: chemical.emergencyFirstAid.inhalation)
                    FirstAidRow(title: "Ingestion", text: chemical.emergencyFirstAid.ingestion)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                
                // Waste Disposal
                VStack(alignment: .leading, spacing: 6) {
                    Label("Waste Disposal Protocol", systemImage: "trash.slash.fill")
                        .font(.headline)
                    Text(chemical.wasteDisposalCategory)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Chemical SDS Card")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FirstAidRow: View {
    let title: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption.bold())
                .foregroundColor(.red)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
