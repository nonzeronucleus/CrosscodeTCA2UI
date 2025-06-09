import SwiftUI
import ComposableArchitecture
import CrosscodeDataLibrary

struct LayoutsListView: View {
    let store: StoreOf<LayoutsListFeature>
    
    var body: some View {
        let layouts = store.state.layouts
        VStack{
            List {
                ForEach(layouts, id: \.id) { layout in
                    NavigationLink(value: layout.id) {
                        Text("\(layout.id)")
                    }
                    .simultaneousGesture(
                        TapGesture().onEnded {
//                            store.dispatch(action: NavigationActions.navigateToDetail(payload: layout.id))
                        }
                    )
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
//                            layoutToDelete = layout.id
//                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
//        .alert("Delete Layout",
//               isPresented: $showDeleteAlert,
//               presenting: layoutToDelete) { id in
//            Button("Cancel", role: .cancel) {}
//            Button("Delete", role: .destructive) {
////                store.dispatch(action: LayoutsActions.deleteLayout(payload: id))
//                store.dispatch(action: LevelListActions<LevelLayout>.Delete.start(payload: id))
//            }
//        } message: { id in
//            Text("Are you sure you want to delete this layout?")
//        }
        .onAppear() {
            store.send(LayoutsListFeature.Action.fetchAll(.start))
        }
        
        
        
        
        
//        VStack {
//            ForEach(store.layouts, id: \.self) { level in
//                Text("\(level.id)")
//                    .onTapGesture {
//                        //                        store.send(.didSelectLevel(level))
//                    }
//            }
//
//                
//            
//        }
//        .onAppear {
////            store.send(LayoutsListFeature.Action.addLayout(.start))
//            store.send(LayoutsListFeature.Action.fetchAll(.start))
//        }
    }
}

#Preview {
    let mock:APIClient = withDependencies {
        $0.uuid = UUIDGenerator.incrementing
    } operation: {
        .mock
    }

    let store = Store(initialState: .init()) {
        LayoutsListFeature()
    } withDependencies: {
        $0.uuid = .incrementing
        $0.apiClient = mock
    }
    
    LayoutsListView(store: store)
}
