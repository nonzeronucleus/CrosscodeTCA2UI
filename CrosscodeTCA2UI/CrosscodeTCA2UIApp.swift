import SwiftUI
import ComposableArchitecture

@main
struct CrosscodeTCA2UIApp: App {
    let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}

