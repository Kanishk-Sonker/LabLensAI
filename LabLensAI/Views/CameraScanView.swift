import SwiftUI

public struct CameraScanView: View {
    @StateObject private var viewModel = CameraScannerViewModel()
    @State private var showingDetailSheet = false
    @State private var showingQuickTestMenu = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                // Background Viewfinder simulation / camera canvas
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Telemetry Header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("LABLENS AI VISION")
                                .font(.system(size: 11, weight: .black, design: .monospaced))
                                .foregroundColor(.cyan)
                            Text("Hardware: Apple Neural Engine (ANE)")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        HStack(spacing: 8) {
                            Label(String(format: "%.1f FPS", viewModel.fpsValue), systemImage: "bolt.fill")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.green)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(6)
                            
                            Button(action: { showingQuickTestMenu.toggle() }) {
                                Image(systemName: "flask.fill")
                                    .foregroundColor(.yellow)
                                    .padding(8)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    Spacer()
                    
                    // Viewfinder Target Bounding Frame
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                viewModel.currentScanResult != nil ? Color.green : Color.white.opacity(0.4),
                                style: StrokeStyle(lineWidth: 2, dash: viewModel.currentScanResult != nil ? [] : [10, 5])
                            )
                            .frame(maxWidth: 320, maxHeight: 320)
                            .overlay(
                                // Reticle corners
                                ReticleCorners()
                            )
                        
                        if let result = viewModel.currentScanResult {
                            VStack(spacing: 4) {
                                Text(result.label.uppercased())
                                    .font(.system(size: 14, weight: .heavy, design: .monospaced))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.85))
                                    .cornerRadius(6)
                                
                                HStack(spacing: 6) {
                                    Text(String(format: "Conf: %.1f%%", result.confidence * 100))
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    Text("•")
                                    Text(String(format: "%.1f ms", result.inferenceLatencyMs))
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.black.opacity(0.75))
                                .cornerRadius(4)
                            }
                            .offset(y: -140)
                        } else {
                            Text("Center laboratory instrument in frame")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    Spacer()
                    
                    // Bottom Context Card (Displays when an instrument is locked)
                    if let eq = viewModel.detectedEquipment {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(eq.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(eq.category.rawValue)
                                        .font(.caption)
                                        .foregroundColor(.blue.opacity(0.9))
                                }
                                Spacer()
                                Button(action: { showingDetailSheet = true }) {
                                    HStack(spacing: 4) {
                                        Text("Open Guide")
                                        Image(systemName: "chevron.right")
                                    }
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                                }
                            }
                            
                            Text(eq.purpose)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.85))
                                .lineLimit(2)
                            
                            // Safety Alert Bar
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Safety: \(eq.safetyPrecautions.first ?? "Standard PPE required.")")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.orange.opacity(0.95))
                                    .lineLimit(1)
                            }
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.orange.opacity(0.15))
                            .cornerRadius(6)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground).opacity(0.95).colorInvert())
                        .cornerRadius(16)
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        // Quick Action Buttons
                        HStack(spacing: 12) {
                            Button(action: {
                                viewModel.simulateEquipmentDetection(equipmentId: "micropipette")
                            }) {
                                Label("Detect Pipette", systemImage: "pipette")
                                    .font(.caption.bold())
                                    .padding(10)
                                    .background(Color.white.opacity(0.15))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                viewModel.simulateEquipmentDetection(equipmentId: "benchtop_centrifuge")
                            }) {
                                Label("Detect Centrifuge", systemImage: "arrow.triangle.2.circlepath")
                                    .font(.caption.bold())
                                    .padding(10)
                                    .background(Color.white.opacity(0.15))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingDetailSheet) {
                if let eq = viewModel.detectedEquipment {
                    EquipmentDetailView(equipment: eq)
                }
            }
            .actionSheet(isPresented: $showingQuickTestMenu) {
                ActionSheet(
                    title: Text("Simulate Real-time Model Inference"),
                    message: Text("Select an instrument class to test Vision-to-SOP workflow"),
                    buttons: [
                        .default(Text("1. Micropipette")) { viewModel.simulateEquipmentDetection(equipmentId: "micropipette") },
                        .default(Text("2. Optical Microscope")) { viewModel.simulateEquipmentDetection(equipmentId: "optical_microscope") },
                        .default(Text("3. High-Speed Centrifuge")) { viewModel.simulateEquipmentDetection(equipmentId: "benchtop_centrifuge") },
                        .default(Text("4. Thermal Cycler (PCR)")) { viewModel.simulateEquipmentDetection(equipmentId: "thermal_cycler_pcr") },
                        .default(Text("5. CO2 Incubator")) { viewModel.simulateEquipmentDetection(equipmentId: "co2_incubator") },
                        .default(Text("6. UV-Vis Spectrophotometer")) { viewModel.simulateEquipmentDetection(equipmentId: "uv_vis_spectrophotometer") },
                        .default(Text("7. Borosilicate Glassware")) { viewModel.simulateEquipmentDetection(equipmentId: "laboratory_glassware") },
                        .cancel(Text("Reset Viewfinder")) { viewModel.resetScan() }
                    ]
                )
            }
        }
    }
}

struct ReticleCorners: View {
    var body: some View {
        GeometryReader { geo in
            let length: CGFloat = 24
            let thickness: CGFloat = 3
            
            // Top-left
            Path { path in
                path.move(to: CGPoint(x: 0, y: length))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: length, y: 0))
            }
            .stroke(Color.cyan, lineWidth: thickness)
            
            // Top-right
            Path { path in
                path.move(to: CGPoint(x: geo.size.width - length, y: 0))
                path.addLine(to: CGPoint(x: geo.size.width, y: 0))
                path.addLine(to: CGPoint(x: geo.size.width, y: length))
            }
            .stroke(Color.cyan, lineWidth: thickness)
            
            // Bottom-left
            Path { path in
                path.move(to: CGPoint(x: 0, y: geo.size.height - length))
                path.addLine(to: CGPoint(x: 0, y: geo.size.height))
                path.addLine(to: CGPoint(x: length, y: geo.size.height))
            }
            .stroke(Color.cyan, lineWidth: thickness)
            
            // Bottom-right
            Path { path in
                path.move(to: CGPoint(x: geo.size.width - length, y: geo.size.height))
                path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height - length))
            }
            .stroke(Color.cyan, lineWidth: thickness)
        }
    }
}
