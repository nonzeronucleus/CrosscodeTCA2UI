import Testing
@testable import CrosscodeTCA2UI
import ComposableArchitecture
import CrosscodeDataLibrary
import Factory

struct LayoutsTabTests {

    @Test func testFetchAllSuccessReducer() async throws {
        await withDependencies {
            $0.uuid = .incrementing
        } operation: {
            @Dependency(\.uuid) var uuid
            
            let store = await TestStore(
                initialState: LayoutsTabFeature.State()
            ) {
                LayoutsTabFeature()
            }
            
            let layouts = [Layout(
                id: uuid(),
                number: 1,
                gridText: "--|--|"
            )]
            
            await #expect(store.state.layouts.count == 0)

            await store.send(LayoutsTabFeature.Action.fetchLayouts(.success(layouts))) {
                $0.layouts = IdentifiedArray(uniqueElements: layouts)
            }
            
            await #expect(store.state.layouts.count == 1)
        }
    }
    
    @Test func testFetchAllEffectWithSuccess() async throws {
        setupTestLib(#function)
        defer { tearDownTestLib(#function) }

        let mock:APIClient = withDependencies {
            $0.uuid = UUIDGenerator.incrementing
        } operation: {
            .mock
        }
        
        await withDependencies {
            $0.uuid = .incrementing
            $0.apiClient = mock
        } operation: {
            @Dependency(\.uuid) var uuid
            
            let store = await TestStore(
                initialState: LayoutsTabFeature.State()
            ) {
                LayoutsTabFeature()
            }
            
            let layouts = [Layout(
                id: uuid(),
                number: 1,
                gridText: "--|--|"
            )]
            
            guard let mockLayoutAPI = mock.layoutsAPI as? MockLayoutsAPI else { return }
            
            mockLayoutAPI.levels = IdentifiedArray(uniqueElements: layouts)
            
            await #expect(store.state.layouts.count == 0)

            await store.send(LayoutsTabFeature.Action.fetchLayouts(.start))
            
            await store.receive(LayoutsTabFeature.Action.fetchLayouts(.success(layouts))) {
                $0.layouts = IdentifiedArray(uniqueElements: layouts)
            }

            await #expect(store.state.layouts.count == 1)
        }
    }
}

