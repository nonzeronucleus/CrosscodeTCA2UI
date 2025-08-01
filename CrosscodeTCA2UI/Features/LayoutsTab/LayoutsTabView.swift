import SwiftUI
import ComposableArchitecture
import CrosscodeDataLibrary

struct LayoutsTabView: View {
    @Bindable var store: StoreOf<LayoutsTabFeature>
    
    var body: some View {
        WithViewStore(store, observe: \.layouts) { viewStore in
            NavigationStack() {
                VStack {
                    TitleBarView(
                        title: "Layouts",
                        color: .cyan,
                        importAction:{ store.send(.view(.importButtonPressed)) },
                        exportAction:{ store.send(.view(.exportButtonPressed)) },
                        addItemAction: { store.send(.addLayout(.api(.start(nil)))) },
                        showSettingsAction: { store.send(.delegate(.settingsButtonPressed)) }
                    )
                    
                    List {
                        ForEach(viewStore.state, id: \.id) { layout in
                            Button {
                                store.send(.view(.itemSelected(layout.id)))
                            } label: {
                                Text("\(layout.name)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    store.send(.view(.deleteButtonPressed(layout.id)))
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    store.send(.view(.pageLoaded))
                }
            }
            .fullScreenCover(
                item: $store.scope(state: \.editLayout, action: \.editLayout)
            ) { editStore in
                EditLayoutView(store: editStore)
            }
        }
    }
}




extension AnyTransition {
    static var slideInOut: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .trailing)
        )
    }
}

#Preview {
    Text("Test")
}
