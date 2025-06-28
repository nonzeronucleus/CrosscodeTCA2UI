import Testing
@testable import CrosscodeTCA2UI
import ComposableArchitecture
import CrosscodeDataLibrary
import Factory

struct ExportLayoutsTests {
    
    @Test func testExportButton() async throws {
        let mockLayoutsAPI:MockLayoutsAPI = .init(levels: [])
        let mockAPIClient:APIClient = APIClient(layoutsAPI: mockLayoutsAPI, gameLevelsAPI: MockGameLevelsAPI())
        
        await withDependencies {
            $0.uuid = .incrementing
            $0.apiClient = mockAPIClient
        } operation: {
            @Dependency(\.uuid) var uuid
            let mockLayouts: [Layout] = [.mock]
            
            let store = await TestStore(
                initialState: LayoutsTabFeature.State(layouts:IdentifiedArrayOf(uniqueElements: mockLayouts))
            ) {
                LayoutsTabFeature()
            }
            
            await store.send(.exportButtonPressed)
            
            await store.receive(.exportLayouts(.start))
            await store.receive(.exportLayouts(.success))
            
            #expect(mockLayoutsAPI.exportedLayouts == mockLayouts)
        }
    }
}
