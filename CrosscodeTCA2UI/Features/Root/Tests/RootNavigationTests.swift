import Testing
@testable import CrosscodeTCA2UI
import ComposableArchitecture
import CrosscodeDataLibrary
import Factory

struct RootNavigationTests {
    
    @Test func testTabChanges() async throws {
        let store = await TestStore(
            initialState: RootFeature.State(tab: .edit)
        ) {
            RootFeature()
        }
        
        await store.send(.setTab(.play)) {
            $0.tab = .play
        }
        await store.send(.setTab(.edit)) {
            $0.tab = .edit
        }
    }
    
    @Test func testShowSettingsForLayout() async throws {
        let store = await TestStore(
            initialState: RootFeature.State()
        ) {
            RootFeature()
        }
        
        await store.send(.layoutsList(.delegate(.settingsButtonPressed))) {
            $0.settings = SettingsFeature.State()
        }
        
        await store.send(.settings(.presented(.backButtonTapped)))
        
        await store.receive(.settings(.dismiss)) {
            $0.settings = nil
        }
    }
    
    @Test func testShowSettingsForGames() async throws {
        let store = await TestStore(
            initialState: RootFeature.State()
        ) {
            RootFeature()
        }
        
        await store.send(.settingsButtonPressed) {
            $0.settings = SettingsFeature.State()
        }
        
        await store.send(.settings(.presented(.backButtonTapped)))
        
        await store.receive(.settings(.dismiss)) {
            $0.settings = nil
        }
    }

}
