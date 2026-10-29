import SwiftUI

public struct SOPLibraryView: View {
    @ObservedObject private var database = DatabaseService.shared
    @State private var searchQuery: String = ""
    
    public init() {}
    
    public var filteredSOPs: [SOPProtocol] {
        if searchQuery.isEmpty {
            return database.sopList
        }
        return database.sopList.filter {
            $0.title.localizedCaseInsensitiveContains(searchQuery) ||
            $0.standardCode.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    public var body: some View {
        NavigationView {
            List(filteredSOPs) { sop in
                NavigationLink(destination: SOPProtocolDetailView(sopId: sop.id)) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(sop.standardCode)
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.12))
                                .cornerRadius(4)
                            Spacer()
                            Label("\(sop.estimatedDurationMinutes) min", systemImage: "clock")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(sop.title)
                            .font(.headline)
                        
                        Text("Prerequisite: \(sop.prerequisiteTraining)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .searchable(text: $searchQuery, prompt: "Search SOP standard codes or titles...")
            .navigationTitle("SOP Protocols")
        }
    }
}

public struct SOPProtocolDetailView: View {
    public let sopId: String
    @ObservedObject private var database = DatabaseService.shared
    @State private var completedSteps: Set<Int> = []
    @State private var activeTimerSeconds: Int?
    @State private var isTimerActive = false
    
    public init(sopId: String) {
        self.sopId = sopId
    }
    
    private var sop: SOPProtocol? {
        database.sopList.first { $0.id == sopId }
    }
    
    public var body: some View {
        Group {
            if let sop = sop {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // Title Card
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(sop.standardCode)
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(.blue)
                                Spacer()
                                Text("Version: \(sop.version)")
                                    .font(.caption2.monospaced())
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(sop.title)
                                .font(.title3.bold())
                            
                            HStack(spacing: 12) {
                                Label("\(sop.estimatedDurationMinutes) minutes", systemImage: "clock.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Label("SOP Target: \(sop.targetEquipmentId)", systemImage: "cube.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        
                        // PPE Required
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Required Personal Protective Equipment", systemImage: "shield.lefthalf.filled")
                                .font(.headline)
                            HStack {
                                ForEach(sop.ppeChecklist, id: \.self) { ppe in
                                    Text(ppe)
                                        .font(.caption.bold())
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.green.opacity(0.15))
                                        .foregroundColor(.green)
                                        .cornerRadius(6)
                                }
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        
                        // Step-by-Step Interactive Workflow
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Sequential Execution Steps")
                                .font(.headline)
                            
                            ForEach(sop.executionSteps) { step in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Button(action: {
                                            if completedSteps.contains(step.id) {
                                                completedSteps.remove(step.id)
                                            } else {
                                                completedSteps.insert(step.id)
                                            }
                                        }) {
                                            Image(systemName: completedSteps.contains(step.id) ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(completedSteps.contains(step.id) ? .green : .gray)
                                                .font(.title3)
                                        }
                                        
                                        Text("Step \(step.id): \(step.stageTitle)")
                                            .font(.subheadline.bold())
                                            .strikethrough(completedSteps.contains(step.id))
                                        
                                        Spacer()
                                        
                                        if let duration = step.timerDurationSeconds {
                                            Label("\(duration)s", systemImage: "timer")
                                                .font(.caption.monospaced())
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    
                                    Text(step.instruction)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.leading, 32)
                                    
                                    if let warning = step.safetyWarning {
                                        HStack(spacing: 6) {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .foregroundColor(.orange)
                                                .font(.caption)
                                            Text(warning)
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundColor(.orange)
                                        }
                                        .padding(6)
                                        .background(Color.orange.opacity(0.12))
                                        .cornerRadius(6)
                                        .padding(.leading, 32)
                                    }
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                }
            } else {
                Text("Standard Operating Procedure not found.")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("SOP Execution Guide")
        .navigationBarTitleDisplayMode(.inline)
    }
}
