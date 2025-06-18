import Dependencies
import IdentifiedCollections
import Foundation
import CrosscodeDataLibrary

class MockGameLevelsAPI: GameLevelsAPI {
    @Dependency(\.uuid) var uuid
    
    var levels: IdentifiedArrayOf<GameLevel> = []
    
    init(levels: [GameLevel] = []) {
        self.levels = IdentifiedArray(uniqueElements: levels)
    }

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

//extension GameLevel {
//    
//    static let shortMock: GameLevel = GameLevel(layout: Layout(
//                                    id: UUID(0),
//                                    number: 1,
//                                    gridText:". | .|"
//        ), id: UUID(0), number: 1)
//    
//    static let longMock = GameLevel(layout: Layout(
//                                    id: UUID(1),
//                                    number: 1,
//                                    gridText:". .| ..|   |"
//        ), id: UUID(1), number: 2)
//    
//    
//    static var mocks: [GameLevel] = [shortMock, shortMock]
//
//}
