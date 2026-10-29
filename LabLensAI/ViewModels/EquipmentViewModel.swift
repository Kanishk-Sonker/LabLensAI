import Foundation
import Combine

public final class EquipmentViewModel: ObservableObject {
    @Published public var equipmentList: [Equipment] = []
    @Published public var searchQuery: String = ""
    @Published public var selectedCategory: Equipment.EquipmentCategory?
    
    private let databaseService = DatabaseService.shared
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        databaseService.$equipmentList
            .sink { [weak self] list in
                self?.equipmentList = list
            }
            .store(in: &cancellables)
    }
    
    public var filteredEquipment: [Equipment] {
        equipmentList.filter { item in
            let matchesQuery = searchQuery.isEmpty ||
                item.name.localizedCaseInsensitiveContains(searchQuery) ||
                item.purpose.localizedCaseInsensitiveContains(searchQuery)
            
            let matchesCategory = selectedCategory == nil || item.category == selectedCategory
            return matchesQuery && matchesCategory
        }
    }
}
