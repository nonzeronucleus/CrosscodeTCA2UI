import Dependencies
import Foundation
import CrosscodeDataLibrary


//protocol LayoutsAPI {
//    func fetchAllLevels() async throws -> [any Level]
//    func addNewLayout() async throws
//    func importLevels() async throws
//    func fetchLevel(id: UUID) async throws -> (any Level)?
//}
//
class MockLayoutsAPI: LayoutsAPI {
    @Dependency(\.uuid) var uuid
    
    var levels: [any Level] = []
    
    init() {
        levels = [Layout.mock()]
    }
    
    func populateCrossword(crosswordLayout: String) async throws -> (String, String) {
        fatalError("\(#function) not implemented")
    }
    
    func depopulateCrossword(crosswordLayout: String) async throws -> (String, String) {
        fatalError("\(#function) not implemented")
    }
    
    func addNewLayout() async throws {
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
        return levels
    }
    
    func deleteLevel(id: UUID) async throws {
        fatalError("\(#function) not implemented")
    }
    
    func saveLevel(level: any Level) async throws {
        fatalError("\(#function) not implemented")
    }
    
    func cancel() async {
        fatalError("\(#function) not implemented")
    }
    
    func printTest() {
        fatalError("\(#function) not implemented")
    }
}

extension Layout {
    static func mock() -> Layout {
        @Dependency(\.uuid) var uuid

        return Layout(
            id: uuid(),
            number: 1,
            gridText:"    .    .. ...| ..  .. ... . .| .. ... ...    |    ..    ... .|. .  ... .... .|. ....   .... .|       .      .|...... . ......|.      .       |. ....   .... .|. .... ...  . .|. ...    ..    |    ... ... .. |. . ... ..  .. |... ..    .    |"
            
        )
    }
}
