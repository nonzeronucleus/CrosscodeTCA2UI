import Testing
@testable import CrosscodeTCA2UI
import ComposableArchitecture
import CrosscodeDataLibrary
import Factory

struct LoadGameLevelsTests {
    
    @Test func testLoadGameLevels() async throws {
        setupTestLib(#function)
        defer { tearDownTestLib(#function) }
        
        //        let mockLayout = Layout.mock
        //
        let mockAPI:APIClient =  APIClient(
            layoutsAPI: MockLayoutsAPI(levels:[]),
            gameLevelsAPI: MockGameLevelsAPI(packs: GameLevel.mockPacks, levels: GameLevel.mocks)
        )
        
        let store = await TestStore(
            initialState: GameLevelsTabFeature.State()
        ) {
            GameLevelsTabFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.apiClient = mockAPI
        }
        
        await store.send(GameLevelsTabFeature.Action.view(.pageLoaded))
    }
    
    @Test func testSelectFirstPack() async throws {
        setupTestLib(#function)
        defer { tearDownTestLib(#function) }
        
        //        let mockLayout = Layout.mock
        //
        let mockAPI:APIClient =  APIClient(
            layoutsAPI: MockLayoutsAPI(levels:[]),
            gameLevelsAPI: MockGameLevelsAPI(packs: GameLevel.mockPacks, levels: GameLevel.mocks)
        )
        
        let store = await TestStore(
            initialState: GameLevelsTabFeature.State()
        ) {
            GameLevelsTabFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.apiClient = mockAPI
        }
        
        let selectedPack = GameLevel.mockPacks.first!
        
        await store.send(GameLevelsTabFeature.Action.pack(.delegate(.didChangePack(selectedPack))))
        
        await store.receive(\.loadGameLevels.api.start, UUID(0)) {
            $0.isBusy = true
        }
        
        await store.receive(\.loadGameLevels.internal.success, GameLevel.mocks) {
            $0.isBusy = false
            $0.levels = IdentifiedArray(uniqueElements:GameLevel.mocks)
        }
    }
}

extension LoadGameLevelsTests {
    static let shortMock: GameLevel = GameLevel(layout: Layout(
                                    id: UUID(0),
                                    number: 1,
                                    gridText:". | .|"
        ), id: UUID(0), number: 1)
    
    static let longMock = GameLevel(layout: Layout(
                                    id: UUID(1),
                                    number: 1,
                                    gridText:". .| ..|   |"
        ), id: UUID(1), number: 2)
    
    
    static var mocks: [GameLevel] = [shortMock, longMock]
}
    
