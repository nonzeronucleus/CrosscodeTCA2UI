import SwiftUI
import ComposableArchitecture

@main
struct CrosscodeTCA2UIApp: App {
    let store = Store(initialState: RootFeature.State()) {
        RootFeature()
    }
    
    
    var body: some Scene {
        WindowGroup {
            if isTesting {
                Text(verbatim: "Testing")
            }
            else {
                ContentView(store: store)
            }
        }
    }
}


extension ProcessInfo {
    var isTesting: Bool {
        environment["XCTestConfigurationFilePath"] != nil
    }
}

