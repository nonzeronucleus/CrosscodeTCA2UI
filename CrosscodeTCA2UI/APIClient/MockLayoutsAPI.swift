import Dependencies
import IdentifiedCollections
import Foundation
import CrosscodeDataLibrary

class MockLayoutsAPI: LayoutsAPI {
    func cancelPopulation() async {
        
    }
    
    
    func importLayouts() async throws -> [Layout] {
        return []
    }
    
    @Dependency(\.uuid) var uuid
    
    var levels: IdentifiedArrayOf<Layout> = []
    var exportedLayouts:[Layout]? = nil

    init(levels: [Layout]) {
        self.levels = IdentifiedArray(uniqueElements: levels)
    }

    func exportLayouts() async throws {
        exportedLayouts = levels.elements
    }
    

    func populateCrossword(crosswordLayout: String) async throws -> (String, String) {
        fatalError("\(#function) not implemented")
    }
    
    func depopulateCrossword(crosswordLayout: String) async throws -> (String, String) {
        fatalError("\(#function) not implemented")
    }
    
    func addNewLayout(crosswordLayout: String?) async throws {
        self.levels.append(
            Layout(
                id: uuid(),
                number: 1,
                gridText: "A-|--|"
            )
        )
    }
    
    func importLevels() async throws {
        fatalError("\(#function) not implemented")
    }
    
    func fetchLevel(id: UUID) async throws -> (any Level)? {
        if self.levels.isEmpty { return nil }
        
        return self.levels.first! 
    }
    
    func fetchAllLevels() async throws -> [any Level] {
        return levels.elements
    }
    
    func deleteLevel(id: UUID) async throws {
        fatalError("\(#function) not implemented")
    }
    
    func saveLevel(level: any Level) async throws {
        guard let layout = level as? Layout else {
            fatalError("\(#function) wrong type")
        }
        
        levels[id: layout.id] = layout
    }
    
    func cancel() async {
        fatalError("\(#function) not implemented")
    }
    
    func printTest() {
        fatalError("\(#function) not implemented")
    }
}

extension Layout {
    static var mock: Layout { get {
        return Layout(
            id: UUID(0),
            number: 1,
            gridText:"    .    .. ...| ..  .. ... . .| .. ... ...    |    ..    ... .|. .  ... .... .|. ....   .... .|       .      .|...... . ......|.      .       |. ....   .... .|. .... ...  . .|. ...    ..    |    ... ... .. |. . ... ..  .. |... ..    .    |"
            
        )
    }}
    
    static func shortMock() -> Layout {
        return Layout(
            id: UUID(0),
            number: 1,
            gridText:". | .|"
        )
    }
}

