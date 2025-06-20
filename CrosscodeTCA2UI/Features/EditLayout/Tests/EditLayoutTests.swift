import Testing
@testable import CrosscodeTCA2UI
import ComposableArchitecture
import CrosscodeDataLibrary
import Factory

struct EditLayoutTests {
    
    //    @MainActor
    @Test func testPageLoaded() async throws {
        setupTestLib(#function)
        defer { tearDownTestLib(#function) }

        let mockLayout = Layout.mock
        
        let mockAPI:APIClient =  APIClient(
            layoutsAPI: MockLayoutsAPI(levels: [mockLayout]),
            gameLevelsAPI: MockGameLevelsAPI(/*levels: GameLevel.mocks*/)
        )
        
        let store = await TestStore(
            initialState: EditLayoutFeature.State(layoutID: UUID(0))
        ) {
            EditLayoutFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.apiClient = mockAPI
        }
        
        await store.send(EditLayoutFeature.Action.pageLoaded)
        
        await store.receive(EditLayoutFeature.Action.loadLayout(.start(UUID(0)))) {
            $0.isBusy = true
        }
        await store.receive(EditLayoutFeature.Action.loadLayout(.success(mockLayout))) {
            $0.layout = mockLayout
            $0.isBusy = false
        }
    }
    
    
    @Test func testToggle() async throws {
        @Dependency(\.uuid) var uuid
        
        let layout = Layout(id: UUID(), number: 1, gridText: "...|...|...|")
        
        
        let state = EditLayoutFeature.State(layoutID: layout.id, layout: layout)
        
        let store = await TestStore(initialState: state) {
            EditLayoutFeature()
        }
        
        
        #expect(state.layout != nil)
        
        // Grid should be all nil (off)
        await #expect(store.state.layout?.crossword[0,0].letter == nil)
        await #expect(store.state.layout?.crossword[1,1].letter == nil)
        await #expect(store.state.layout?.crossword[2,2].letter == nil)
        
        let cellID = (state.layout?.crossword[0,0].id)!
        await store.send(EditLayoutFeature.Action.cell(.cellClicked(cellID))) {
            $0.layout!.crossword[0,0].letter = " "
            $0.layout?.crossword[2,2].letter = " "
            $0.isDirty = true
        }
        
        await store.send(EditLayoutFeature.Action.cell(.cellClicked(cellID))) {
            $0.layout!.crossword[0,0].letter = nil
            $0.layout?.crossword[2,2].letter = nil
        }
    }
}
