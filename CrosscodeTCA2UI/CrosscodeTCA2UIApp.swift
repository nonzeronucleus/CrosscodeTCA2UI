import SwiftUI
import ComposableArchitecture

@main
struct CrosscodeTCA2UIApp: App {
    let store = Store(initialState: RootFeature.State()) {
        RootFeature()
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}

