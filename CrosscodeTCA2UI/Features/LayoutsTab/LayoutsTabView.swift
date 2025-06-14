import SwiftUI
import ComposableArchitecture
import CrosscodeDataLibrary

struct LayoutsTabView: View {
    @Bindable var store: StoreOf<LayoutsTabFeature>
    
    var body: some View {
        WithViewStore(store, observe: \.layouts) { viewStore in
            VStack {
                List {
                    ForEach(viewStore.state, id: \.id) { layout in
                        Button {
                            store.send(.itemSelected(layout.id))
                        } label: {
                            Text("\(layout.name)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                store.send(.deleteButtonPressed(layout.id))
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .onAppear {
                store.send(.pageLoaded)
            }
        }
        .fullScreenCover(
            item: $store.scope(state: \.editLayout, action: \.editLayout)
        ) { editStore in
            EditLayoutView(store: editStore)
//            CoverView(store: coverStore)
        }
//        .fullScreenCover(
//            store: store.scope(state: \.$editLayout, action: \.editLayout)
//        ) { editStore in
//            EditLayoutView(store: editStore)
//                .presentationBackground(LinearGradient(
//                    gradient: Gradient(colors: [.purple.opacity(1.0), .blue.opacity(1.0)]),
//                                    startPoint: .topLeading,
//                                    endPoint: .bottomTrailing
//                                ))
//        }
    }
}

//struct LayoutsTabView: View {
//    let store: StoreOf<LayoutsTabFeature>
//    
//    var body: some View {
//        WithViewStore(store, observe: { $0 }) { viewStore in
//            ZStack {
//                // Main content
//                VStack {
//                    List {
//                        ForEach(viewStore.layouts, id: \.id) { layout in
//                            Button {
//                                viewStore.send(.itemSelected(layout.id))
//                            } label: {
//                                Text(layout.name)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .contentShape(Rectangle())
//                            }
//                            .swipeActions(edge: .trailing) {
//                                Button(role: .destructive) {
//                                    viewStore.send(.deleteButtonPressed(layout.id))
//                                } label: {
//                                    Label("Delete", systemImage: "trash")
//                                }
//                            }
//                        }
//                    }
//                }
//                .onAppear { viewStore.send(.pageLoaded) }
//                
//                // Custom presentation
//                IfLetStore(
//                    store.scope(
//                        state: \.$editLayout,
//                        action: \.editLayout
//                    )
//                ) { editStore in
//                    EditLayoutView(store: editStore)
//                        .transition(.move(edge: .trailing))
//                        .zIndex(1)
//                }
//            }
//            .animation(.default, value: viewStore.editLayout)
//        }
//    }
//}
//
//#Preview {
//    let mock:APIClient = withDependencies {
//        $0.uuid = UUIDGenerator.incrementing
//    } operation: {
//        .mock
//    }
//
//    let store = Store(initialState: .init()) {
//        LayoutsTabFeature()
//    } withDependencies: {
//        $0.uuid = .incrementing
//        $0.apiClient = mock
//    }
//    
//    LayoutsTabView(store: store)
//}


extension AnyTransition {
    static var slideInOut: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .trailing)
        )
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
