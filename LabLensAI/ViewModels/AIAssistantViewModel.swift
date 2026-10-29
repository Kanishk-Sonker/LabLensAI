import Foundation
import Combine

public final class AIAssistantViewModel: ObservableObject {
    public struct ChatMessage: Identifiable, Equatable {
        public let id = UUID()
        public let sender: MessageSender
        public let text: String
        public let timestamp: Date = Date()
        
        public enum MessageSender {
            case user
            case assistant
        }
    }
    
    @Published public var messages: [ChatMessage] = []
    @Published public var inputText: String = ""
    @Published public var isGenerating: Bool = false
    @Published public var activeEquipmentContext: Equipment?
    
    private let geminiService = GeminiService.shared
    
    public init() {
        // Welcome greeting with standard laboratory advisory
        messages.append(
            ChatMessage(
                sender: .assistant,
                text: "Hello! I am LabLens AI. Point your camera at an instrument, scan a chemical reagent, or ask any question regarding SOPs, safety precautions, or equipment handling."
            )
        )
    }
    
    public func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        messages.append(ChatMessage(sender: .user, text: trimmed))
        inputText = ""
        isGenerating = true
        
        geminiService.answerQuery(prompt: trimmed, activeEquipmentContext: activeEquipmentContext) { [weak self] reply in
            guard let self = self else { return }
            self.isGenerating = false
            self.messages.append(ChatMessage(sender: .assistant, text: reply))
        }
    }
}
