import Testing
@testable import CrosscodeTCA2UI
import ComposableArchitecture
import CrosscodeDataLibrary
import Factory

struct EditLayoutCellReducerTests {
    
    @Test func testToggleCell() async throws {
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
        
        await store.send(EditLayoutFeature.Action.cell(.cellClicked(cellUUID))) {
            $0.layout!.crossword[0,0].letter = " "
            $0.layout!.crossword[14,14].letter = " "
        }

    }
    
    @Test func testToggleCellWhenPopulated() async throws {
        setupTestLib(#function)
        defer { tearDownTestLib(#function) }

        let mockLayout:Layout = Layout.mock
        
        let mockGameLevelsAPI:MockGameLevelsAPI = MockGameLevelsAPI(levels:[])
        
        let mockAPI:APIClient =  APIClient(
            layoutsAPI: MockLayoutsAPI(levels: [mockLayout]),
            gameLevelsAPI: mockGameLevelsAPI
        )
        
        let store = await TestStore(
            initialState: EditLayoutFeature.State(layoutID: UUID(0), layout: mockLayout, isPopulated: true)
        ) {
            EditLayoutFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.apiClient = mockAPI
        }
        
        // It's populated, so there shouldn't be any reaction to the cell being clicked
        await store.send(EditLayoutFeature.Action.cell(.cellClicked(UUID(2))))
        await store.send(EditLayoutFeature.Action.cell(.cellClicked(UUID(2))))
    }
    
    @Test func testToggleCellWithWrongCell() async throws {
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
        
        // It's populated, so there shouldn't be any reaction to the cell being clicked
        await store.send(EditLayoutFeature.Action.cell(.cellClicked(UUID(0))))
        
        let expectedError = EquatableError(EditLayoutCellReducer.FeatureError.couldNotFindCell(UUID(0)))
        
        await store.receive(EditLayoutFeature.Action.cell(.delegate(.failure(expectedError)))) {
            $0.error = expectedError
        }
    }
    
    @Test func testToggleCellWithLevelNil() async throws {
        setupTestLib(#function)
        defer { tearDownTestLib(#function) }

        let mockLayout:Layout = Layout.mock
        
        let mockGameLevelsAPI:MockGameLevelsAPI = MockGameLevelsAPI(levels:[])
        
        let mockAPI:APIClient =  APIClient(
            layoutsAPI: MockLayoutsAPI(levels: [mockLayout]),
            gameLevelsAPI: mockGameLevelsAPI
        )
        
        let store = await TestStore(
            initialState: EditLayoutFeature.State(layoutID: UUID(0), layout: nil, isPopulated: false)
        ) {
            EditLayoutFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.apiClient = mockAPI
        }
        
        // It's populated, so there shouldn't be any reaction to the cell being clicked
        await store.send(EditLayoutFeature.Action.cell(.cellClicked(UUID(0))))
        
        let expectedError = EquatableError(EditLayoutCellReducer.FeatureError.layoutNil)

        await store.receive(EditLayoutFeature.Action.cell(.delegate(.failure(expectedError)))) {
            $0.error = expectedError
        }
    }
}
