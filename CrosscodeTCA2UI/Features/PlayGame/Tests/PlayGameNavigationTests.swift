import Testing
@testable import CrosscodeTCA2UI
import ComposableArchitecture
import CrosscodeDataLibrary
import Factory

struct PlayGameNavigationTests {
    
    @Test func testLoadLevelOnAppear() async throws {
        let mockGame:GameLevel = GameLevel.shortMock
            
        let mockAPI:APIClient =  APIClient(
            layoutsAPI: MockLayoutsAPI(levels: []),
            gameLevelsAPI: MockGameLevelsAPI(levels:[mockGame])
        )
        
        let store = await TestStore(
            initialState: PlayGameFeature.State(levelID: mockGame.id)
        ) {
            PlayGameFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.apiClient = mockAPI
        }
        
        await store.send(.view(.pageLoaded))
        
        await store.receive(\.loadGameLevel.api.start, mockGame.id) {
            $0.isBusy = true
        }

        await store.receive(\.loadGameLevel.internal.finished) {
            $0.isBusy = false
            $0.level = mockGame
        }

        await store.receive(\.loadGameLevel.delegate.finished)

    }
    
    
    @Test func testDisappearOnBackButton() async throws {
        let mockGame:GameLevel = GameLevel.shortMock
            
        let mockAPI:APIClient =  APIClient(
            layoutsAPI: MockLayoutsAPI(levels: []),
            gameLevelsAPI: MockGameLevelsAPI(levels:[mockGame])
        )
        
        let store = await TestStore(
            initialState: PlayGameFeature.State(levelID: mockGame.id)
        ) {
            PlayGameFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.apiClient = mockAPI
        }
        
        await store.send(.view(.backButtonTapped)) {
            $0.isExiting = true
        }
    }
}
