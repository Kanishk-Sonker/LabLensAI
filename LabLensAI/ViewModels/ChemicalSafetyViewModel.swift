import Foundation
import Combine

public final class ChemicalSafetyViewModel: ObservableObject {
    @Published public var chemicals: [Chemical] = []
    @Published public var searchQuery: String = ""
    @Published public var selectedHazardClass: String?
    
    private let databaseService = DatabaseService.shared
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        databaseService.$chemicalsList
            .sink { [weak self] list in
                self?.chemicals = list
            }
            .store(in: &cancellables)
    }
    
    public var filteredChemicals: [Chemical] {
        databaseService.findChemical(byQuery: searchQuery)
    }
}
