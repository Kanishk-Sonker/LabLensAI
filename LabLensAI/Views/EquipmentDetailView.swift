import SwiftUI

public struct EquipmentDetailView: View {
    public let equipment: Equipment
    @Environment(\.presentationMode) var presentationMode
    @State private var showingSOP = false
    
    public init(equipment: Equipment) {
        self.equipment = equipment
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text(equipment.category.rawValue.uppercased())
                            .font(.caption.bold())
                            .foregroundColor(.blue)
                        
                        Text(equipment.name)
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        
                        HStack {
                            Label(equipment.primaryHazardLevel.rawValue, systemImage: "shield.checkerboard")
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.15))
                                .foregroundColor(.orange)
                                .cornerRadius(6)
                            
                            Spacer()
                            
                            Text("ID: \(equipment.id)")
                                .font(.caption2.monospaced())
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Purpose & Working Principle
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "Purpose & Application", icon: "target")
                        Text(equipment.purpose)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Divider().padding(.vertical, 4)
                        
                        SectionHeader(title: "Working Principle", icon: "waveform.path.ecg")
                        Text(equipment.workingPrinciple)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Step-by-Step Usage Guidelines
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Standard Operational Guidelines", icon: "list.number")
                        ForEach(Array(equipment.usageGuidelines.enumerated()), id: \.offset) { idx, step in
                            HStack(alignment: .top, spacing: 10) {
                                Text("\(idx + 1)")
                                    .font(.caption.bold())
                                    .frame(width: 20, height: 20)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                Text(step)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Safety Precautions
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Safety Precautions & Hazard Controls", icon: "exclamationmark.octagon.fill")
                        ForEach(equipment.safetyPrecautions, id: \.self) { warning in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                Text(warning)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.red.opacity(0.08))
                    .cornerRadius(12)
                    
                    // Maintenance & Calibration
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "Maintenance & Routine Calibration", icon: "wrench.and.screwdriver.fill")
                        ForEach(equipment.maintenanceInfo, id: \.self) { item in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(item)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Technical Specifications
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "Technical Specifications", icon: "gauge.with.needle.fill")
                        ForEach(equipment.technicalSpecs.sorted(by: { $0.key < $1.key }), id: \.key) { key, val in
                            HStack {
                                Text(key)
                                    .font(.caption.bold())
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(val)
                                    .font(.caption.monospaced())
                                    .foregroundColor(.primary)
                            }
                            Divider()
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // SOP Access Button
                    if let sopId = equipment.associatedSOPIds.first {
                        NavigationLink(destination: SOPProtocolDetailView(sopId: sopId)) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                Text("Open Linked SOP (\(sopId))")
                                    .fontWeight(.bold)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Instrument Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

public struct EquipmentDirectoryView: View {
    @StateObject private var viewModel = EquipmentViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List(viewModel.filteredEquipment) { eq in
                NavigationLink(destination: EquipmentDetailView(equipment: eq)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(eq.name)
                            .font(.headline)
                        Text(eq.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text(eq.purpose)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 4)
                }
            }
            .searchable(text: $viewModel.searchQuery, prompt: "Search instruments or categories...")
            .navigationTitle("Lab Instruments")
        }
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(title)
                .font(.headline)
        }
    }
}
