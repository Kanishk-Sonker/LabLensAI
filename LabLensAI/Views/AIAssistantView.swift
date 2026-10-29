import SwiftUI

public struct AIAssistantView: View {
    @StateObject private var viewModel = AIAssistantViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Safety Guardrail Disclaimer Banner
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.shield.fill")
                        .foregroundColor(.blue)
                    Text("Guarded Assistant: Verifies queries against OSHA, ISO & laboratory SOP standards.")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
                
                // Chat Message Stream
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { msg in
                                ChatBubbleView(message: msg)
                            }
                            
                            if viewModel.isGenerating {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Synthesizing laboratory safety protocols...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastId = viewModel.messages.last?.id {
                            withAnimation {
                                proxy.scrollTo(lastId, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Rapid Suggested Prompts
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        SuggestionPill(title: "Centrifuge Balancing") {
                            viewModel.inputText = "Why is dynamic balancing critical in high-speed centrifuges?"
                            viewModel.sendMessage()
                        }
                        SuggestionPill(title: "Pipette Calibration") {
                            viewModel.inputText = "Explain the gravimetric calibration procedure for micropipettes."
                            viewModel.sendMessage()
                        }
                        SuggestionPill(title: "Ethidium Bromide Safety") {
                            viewModel.inputText = "What is the emergency first aid protocol for ethidium bromide skin contact?"
                            viewModel.sendMessage()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                }
                
                Divider()
                
                // Bottom Input Field
                HStack(spacing: 8) {
                    TextField("Ask LabLens AI (e.g. SOPs, PPE, safety)...", text: $viewModel.inputText)
                        .padding(10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(20)
                    
                    Button(action: {
                        viewModel.sendMessage()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .blue)
                    }
                    .disabled(viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isGenerating)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .navigationTitle("Lab AI Assistant")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ChatBubbleView: View {
    let message: AIAssistantViewModel.ChatMessage
    
    var body: some View {
        HStack {
            if message.sender == .user {
                Spacer()
                Text(message.text)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.blue)
                    .cornerRadius(16)
                    .frame(maxWidth: 280, alignment: .trailing)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("LabLens Guardrail")
                            .font(.caption2.bold())
                            .foregroundColor(.blue)
                    }
                    Text(message.text)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                .padding(12)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                .frame(maxWidth: 300, alignment: .leading)
                Spacer()
            }
        }
    }
}

struct SuggestionPill: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.bold())
                .foregroundColor(.blue)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.12))
                .cornerRadius(14)
        }
    }
}
