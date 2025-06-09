import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: StoreOf<RootFeature>
    
    var body: some View {
        RootView(store: store)
//        LayoutsListView(store: store.scope(state:\.layoutsList , action: \.layoutsListAction))
    }
}
