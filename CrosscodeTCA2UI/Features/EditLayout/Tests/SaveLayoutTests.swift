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
        
        await store.receive(SaveLayoutReducer.Action.success) {
            $0.isBusy = false
            $0.isDirty = false
        }
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
        
        await store.receive(SaveLayoutReducer.Action.failure(EquatableError(EditLayoutError.saveLayoutError("Some text")))) {
            $0.isBusy = false
        }
    }
    
    @Test func tesPopulatedLayoutSaved() async throws {
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
        
        await store.send(SaveLayoutReducer.Action.start) {
            $0.isBusy = true
        }
        
        await store.receive(SaveLayoutReducer.Action.success) {
            $0.isBusy = false
            $0.isDirty = false
        }
        
        #expect(mockGameLevelsAPI.levels.count == 1)
        #expect(mockGameLevelsAPI.levels[0].id == mockLayout.id)
    }
}
