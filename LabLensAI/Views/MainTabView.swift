import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab: TabItem = .scanner
    
    public enum TabItem: Hashable {
        case scanner
        case equipment
        case chemicals
        case sops
        case aiAssistant
    }
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            CameraScanView()
                .tabItem {
                    Label("Lab Scanner", systemImage: "viewfinder.circle.fill")
                }
                .tag(TabItem.scanner)
            
            EquipmentDirectoryView()
                .tabItem {
                    Label("Instruments", systemImage: "cube.box.fill")
                }
                .tag(TabItem.equipment)
            
            ChemicalSafetyView()
                .tabItem {
                    Label("Chemicals", systemImage: "flame.fill")
                }
                .tag(TabItem.chemicals)
            
            SOPLibraryView()
                .tabItem {
                    Label("SOP Library", systemImage: "doc.text.magnifyingglass")
                }
                .tag(TabItem.sops)
            
            AIAssistantView()
                .tabItem {
                    Label("AI Assistant", systemImage: "sparkles.rectangle.stack.fill")
                }
                .tag(TabItem.aiAssistant)
        }
        .accentColor(.blue)
    }
}
