import Testing
@testable import CrosscodeTCA2UI
import ComposableArchitecture
import CrosscodeDataLibrary
import Factory

struct PopulateTests {
    
    @Test func testSuccessfulPopulation() async throws {
        let uuidGen:IncrementingUUIDProvider = IncrementingUUIDProvider()
        
        let _ = Container.shared.uuid
            .register { uuidGen }
        
        await withDependencies {
            $0.uuid = .incrementing
        } operation: {

            
            @Dependency(\.uuid) var uuid
            let mockAPI:APIClient =  APIClient(
                layoutsAPI: MockLayoutsAPI(levels: []),
                gameLevelsAPI: MockGameLevelsAPI(levels:[])
            )
            
            let layout = Layout(id: UUID(0), number: 1, gridText:  "--|--|")
            
            let store = await TestStore(
                initialState: EditLayoutFeature.State(layoutID: UUID(0),layout: layout)
            ) {
                EditLayoutFeature()
            } withDependencies: {
                $0.uuid = .incrementing
                $0.apiClient = mockAPI
            }
            
            
            await store.send(\.view.populateButtonTapped)
            
            uuidGen.increase(-5) // Fudge to work around value being created in actual layout

            let expectedLetterMapx = "{\"Z\":13,\"D\":2,\"X\":25,\"V\":0,\"J\":6,\"Q\":12,\"L\":22,\"H\":14,\"A\":8,\"W\":20,\"E\":21,\"G\":18,\"U\":10,\"F\":19,\"T\":4,\"O\":3,\"C\":7,\"M\":23,\"P\":1,\"N\":16,\"R\":15,\"B\":9,\"K\":24,\"Y\":5,\"S\":11,\"I\":17}"

            let expectedLayout = Layout(id: uuid(), number: 1, gridText: "AS|SO", letterMap: expectedLetterMapx)
                

            await store.receive(\.populate.api.start) { state in
                state.isBusy = true
            }
            
            await store.receive(\.populate.internal.finished) { state in
                state.isPopulated = true
                state.isBusy = false
                state.layout = expectedLayout
            }
            await store.receive(\.populate.delegate.finished)
        }
    }
}
