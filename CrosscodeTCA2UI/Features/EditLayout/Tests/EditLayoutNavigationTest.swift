import Testing
@testable import CrosscodeTCA2UI
import ComposableArchitecture
import CrosscodeDataLibrary
import Factory

struct EditLayoutNavigationTests {
    
    @Test func testChangedLayoutSavedWhenExit() async throws {
        setupTestLib(#function)
        defer { tearDownTestLib(#function) }

        let mockLayout:Layout = Layout.mock
        
        let mockGameLevelsAPI:MockGameLevelsAPI = MockGameLevelsAPI(levels:[])
        
        let mockAPI:APIClient =  APIClient(
            layoutsAPI: MockLayoutsAPI(levels: [mockLayout]),
            gameLevelsAPI: mockGameLevelsAPI
        )
        
        let store = await TestStore(
            initialState: EditLayoutFeature.State(layoutID: UUID(0), layout: mockLayout, isPopulated: false)
        ) {
            EditLayoutFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.apiClient = mockAPI
        }
        
        let cellUUID = await store.state.layout!.crossword[0,0].id
        
        await store.send(EditLayoutFeature.Action.cell(.cellClicked(cellUUID))) {
            $0.layout!.crossword[0,0].letter = nil
            $0.layout!.crossword[14,14].letter = nil
            $0.isDirty = true
        }
        
        
        await store.send(EditLayoutFeature.Action.backButtonTapped){
            $0.isExiting = true
        }
        
        await store.receive(EditLayoutFeature.Action.saveLayout(.start)){
            $0.isBusy = true
        }
        
        await store.receive(EditLayoutFeature.Action.saveLayout(.delegate(.success))){
            $0.isBusy = false
            $0.isDirty = false
        }
    }
    
    @Test func testUnchangedLayoutNotSavedWhenExit() async throws {
        setupTestLib(#function)
        defer { tearDownTestLib(#function) }
        
        let mockLayout:Layout = Layout.mock
        
        let mockGameLevelsAPI:MockGameLevelsAPI = MockGameLevelsAPI(levels:[])
        
        let mockAPI:APIClient =  APIClient(
            layoutsAPI: MockLayoutsAPI(levels: [mockLayout]),
            gameLevelsAPI: mockGameLevelsAPI
        )
        
        let store = await TestStore(
            initialState: EditLayoutFeature.State(layoutID: UUID(0), layout: mockLayout, isPopulated: false)
        ) {
            EditLayoutFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.apiClient = mockAPI
        }
        
        await store.send(EditLayoutFeature.Action.backButtonTapped){
            $0.isExiting = true
        }
        
        await store.receive(EditLayoutFeature.Action.saveLayout(.start))

        await store.receive(EditLayoutFeature.Action.saveLayout(.delegate(.success)))

//
    }
}
