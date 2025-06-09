import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        RootView(store: store)
//        LayoutsListView(store: store.scope(state:\.layoutsList , action: \.layoutsListAction))
    }
}
