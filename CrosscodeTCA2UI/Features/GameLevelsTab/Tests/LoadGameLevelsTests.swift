//import Testing
//@testable import CrosscodeTCA2UI
//import ComposableArchitecture
//import CrosscodeDataLibrary
//import Factory
//
//struct LoadGameLevelsTests {
//    
//    @Test func testLoadGameLevels() async throws {
//        let _ = Container.shared.uuid
//            .register { IncrementingUUIDProvider() }
//            .singleton
//        
////        let mockLayout = Layout.mock
////        
//        let mockAPI:APIClient =  APIClient(
//            layoutsAPI: MockLayoutsAPI(levels:[]),
//            gameLevelsAPI: MockGameLevelsAPI(levels: GameLevel.mocks)
//        )
//        
//        let store = await TestStore(
//            initialState: GameLevelsTabFeature.State()
//        ) {
//            GameLevelsTabFeature()
//        } withDependencies: {
//            $0.uuid = .incrementing
//            $0.apiClient = mockAPI
//        }
//        
//        await store.send(GameLevelsTabFeature.Action.pageLoaded) {
//            $0.isBusy = true
//        }
//        
////        await store.receive(GameLevelsTabFeature.Action.success) {
////            $0.isBusy = false
////        }
//    }
//}
//    
