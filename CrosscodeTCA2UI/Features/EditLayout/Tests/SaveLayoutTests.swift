import Testing
@testable import CrosscodeTCA2UI
import ComposableArchitecture
import CrosscodeDataLibrary
import Factory

struct SaveLayoutTests {
    
    @Test func testLayoutSaved() async throws {
        @Dependency(\.apiClient) var apiClient

        setupTestLib(#function)
        defer { tearDownTestLib(#function) }

        let mockLayout = Layout.mock
        
        let mockAPI:APIClient =  APIClient(
            layoutsAPI: MockLayoutsAPI(levels: [mockLayout]),
            gameLevelsAPI: MockGameLevelsAPI(levels:[])
        )
        
        let store = await TestStore(
            initialState: EditLayoutFeature.State(layoutID: UUID(0), level: mockLayout, isDirty: true)
        ) {
            SaveLevelReducer<EditLayoutFeature>(levelAPI:apiClient.layoutsAPI)
        } withDependencies: {
            $0.uuid = .incrementing
            $0.apiClient = mockAPI
        }
        
        await store.send(\.api.start) {
            $0.isBusy = true
        }
        
        await store.receive(\.internal.finished) { state in
            state.isBusy = false
            state.isDirty = false
        }
        
        await store.receive(\.delegate.finished)

    }
    
//    @Test func testLayoutSaveErrorForNoLayout() async throws {
//        setupTestLib(#function)
//        defer { tearDownTestLib(#function) }
//
//        let mockLayout = Layout.mock
//        
//        let mockAPI:APIClient =  APIClient(
//            layoutsAPI: MockLayoutsAPI(levels: [mockLayout]),
//            gameLevelsAPI: MockGameLevelsAPI(levels:[])
//        )
//        
//        let store = await TestStore(
//            initialState: EditLayoutFeature.State(layoutID: UUID(0), isDirty: true)
//        ) {
//            EditLayoutFeature()
//        } withDependencies: {
//            $0.uuid = .incrementing
//            $0.apiClient = mockAPI
//        }
//        
//        await store.send(EditLayoutFeature.Action.saveLayout(.api(.start))) {
//            $0.isBusy = true
//        }
//        
//        let expectedError:Error = EditLayoutError.saveLayoutError("Some text")
//        
//        let expectedEquatableError: EquatableError = .init(expectedError)
//        
//        await store.receive(\.saveLayout.delegate.failure)  {
//            $0.error = expectedEquatableError
//            $0.isBusy = false
//        }
//    }
//    
//    @Test func tesPopulatedLayoutNotSavedWhenSaveTriggered() async throws {
//        // Should create new game level
//        setupTestLib(#function)
//        defer { tearDownTestLib(#function) }
//
//        let mockLayout = Layout.mock
//        let mockGameLevelsAPI:MockGameLevelsAPI = MockGameLevelsAPI(levels:[])
//        
//        let mockAPI:APIClient =  APIClient(
//            layoutsAPI: MockLayoutsAPI(levels: [mockLayout]),
//            gameLevelsAPI: mockGameLevelsAPI
//        )
//        
//        let store = await TestStore(
//            initialState: EditLayoutFeature.State(layoutID: UUID(0), layout: mockLayout, isDirty:true, isPopulated: true)
//        ) {
//            SaveLayoutReducer()
//        } withDependencies: {
//            $0.uuid = .incrementing
//            $0.apiClient = mockAPI
//        }
//        
//        await store.send(SaveLayoutReducer.Action.api(.start))
//        await store.receive(\.delegate.success)
//    }
//    
//    
//    @Test func tesPopulatedLayoutExported() async throws {
//        // Should create new game level
//        setupTestLib(#function)
//        defer { tearDownTestLib(#function) }
//
//        let mockLayout = Layout.mock
//        let mockGameLevelsAPI:MockGameLevelsAPI = MockGameLevelsAPI(levels:[])
//        
//        let mockAPI:APIClient =  APIClient(
//            layoutsAPI: MockLayoutsAPI(levels: [mockLayout]),
//            gameLevelsAPI: mockGameLevelsAPI
//        )
//        
//        let store = await TestStore(
//            initialState: EditLayoutFeature.State(layoutID: UUID(0), layout: mockLayout, isDirty:true, isPopulated: true)
//        ) {
//            CreateGameLevelReducer()
//        } withDependencies: {
//            $0.uuid = .incrementing
//            $0.apiClient = mockAPI
//        }
//        
//        await store.send(\.api.start) {
//            $0.isBusy = true
//        }
//
//        await store.receive(\.internal.finished) { state in
//            state.isBusy = false
//        }
//        
//        await store.receive(\.delegate.finished)
//
//        #expect(mockGameLevelsAPI.levels.count == 1)
//        #expect(mockGameLevelsAPI.levels[0].id == mockLayout.id)
//    }
}
