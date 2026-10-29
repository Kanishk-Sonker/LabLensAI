import SwiftUI

@main
struct LabLensAIApp: App {
    init() {
        // Initialize Core Data / Bundled Laboratory Databases
        _ = DatabaseService.shared
        _ = VisionClassifierService.shared
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
