import Dependencies
import IdentifiedCollections
import Foundation
import CrosscodeDataLibrary

class MockGameLevelsAPI: GameLevelsAPI {
    @Dependency(\.uuid) var uuid
    
    var levels: IdentifiedArrayOf<GameLevel> = []

    func addNewLevel(layout: Layout) async throws {
        levels[id: layout.id] = GameLevel(layout:layout, id: layout.id, number: levels.count)
    }
    
    func importLevels() async throws {
        fatalError("\(#function) not implemented")
    }
    
    func fetchLevel(id: UUID) async throws -> (any Level)? {
        fatalError("\(#function) not implemented")
    }
    
    func fetchAllLevels() async throws -> [any Level] {
        return levels.elements
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
