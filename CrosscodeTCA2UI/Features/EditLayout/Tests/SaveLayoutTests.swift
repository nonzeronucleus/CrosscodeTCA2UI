import Testing
@testable import CrosscodeTCA2UI
import ComposableArchitecture
import CrosscodeDataLibrary
import Factory

struct SaveLayoutTests {
    
    @Test func testLayoutSaved() async throws {
        setupTestLib(#function)
        defer { tearDownTestLib(#function) }

        let mockLayout = Layout.mock
        
        let mockAPI:APIClient =  APIClient(
            layoutsAPI: MockLayoutsAPI(levels: [mockLayout]),
            gameLevelsAPI: MockGameLevelsAPI(levels:[])
        )
        
        let store = await TestStore(
            initialState: EditLayoutFeature.State(layoutID: UUID(0), layout: mockLayout, isDirty: true)
        ) {
            SaveLayoutReducer()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.apiClient = mockAPI
        }
        
        await store.send(SaveLayoutReducer.Action.start) {
            $0.isBusy = true
        }
        
        await store.receive(SaveLayoutReducer.Action.delegate(.success))
    }
    
    @Test func testLayoutSaveErrorForNoLayout() async throws {
        setupTestLib(#function)
        defer { tearDownTestLib(#function) }

        let mockLayout = Layout.mock
        
        let mockAPI:APIClient =  APIClient(
            layoutsAPI: MockLayoutsAPI(levels: [mockLayout]),
            gameLevelsAPI: MockGameLevelsAPI(levels:[])
        )
        
        let store = await TestStore(
            initialState: EditLayoutFeature.State(layoutID: UUID(0), isDirty: true)
        ) {
            SaveLayoutReducer()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.apiClient = mockAPI
        }
        
        await store.send(SaveLayoutReducer.Action.start) {
            $0.isBusy = true
        }
        
        await store.receive(SaveLayoutReducer.Action.delegate(.failure(EquatableError(EditLayoutError.saveLayoutError("Some text"))))) 
    }
    
    @Test func tesPopulatedLayoutNotSavedWhenSaveTriggered() async throws {
        // Should create new game level
        setupTestLib(#function)
        defer { tearDownTestLib(#function) }

        let mockLayout = Layout.mock
        let mockGameLevelsAPI:MockGameLevelsAPI = MockGameLevelsAPI(levels:[])
        
        let mockAPI:APIClient =  APIClient(
            layoutsAPI: MockLayoutsAPI(levels: [mockLayout]),
            gameLevelsAPI: mockGameLevelsAPI
        )
        
        let store = await TestStore(
            initialState: EditLayoutFeature.State(layoutID: UUID(0), layout: mockLayout, isDirty:true, isPopulated: true)
        ) {
            SaveLayoutReducer()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.apiClient = mockAPI
        }
        
        await store.send(SaveLayoutReducer.Action.start)
        await store.receive(SaveLayoutReducer.Action.delegate(.success))
    }
    
    
    @Test func tesPopulatedLayoutExported() async throws {
        // Should create new game level
        setupTestLib(#function)
        defer { tearDownTestLib(#function) }

        let mockLayout = Layout.mock
        let mockGameLevelsAPI:MockGameLevelsAPI = MockGameLevelsAPI(levels:[])
        
        let mockAPI:APIClient =  APIClient(
            layoutsAPI: MockLayoutsAPI(levels: [mockLayout]),
            gameLevelsAPI: mockGameLevelsAPI
        )
        
        let store = await TestStore(
            initialState: EditLayoutFeature.State(layoutID: UUID(0), layout: mockLayout, isDirty:true, isPopulated: true)
        ) {
            CreateGameLevelReducer()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.apiClient = mockAPI
        }
        
        await store.send(CreateGameLevelReducer.Action.api(.start)) {
            $0.isBusy = true
        }

        await store.receive(CreateGameLevelReducer.Action.internal(.success)) {
            $0.isBusy = false
        }
        
        await store.receive(CreateGameLevelReducer.Action.delegate(.success))

//
//        #expect(mockGameLevelsAPI.levels.count == 1)
//        #expect(mockGameLevelsAPI.levels[0].id == mockLayout.id)
    }
}
