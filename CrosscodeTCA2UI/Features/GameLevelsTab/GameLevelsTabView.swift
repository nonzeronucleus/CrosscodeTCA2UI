import SwiftUI
import ComposableArchitecture
import CrosscodeDataLibrary

struct GameLevelsTabView: View {
    @Bindable var store: StoreOf<GameLevelsTabFeature>
    
    init(store: StoreOf<GameLevelsTabFeature>) {
        self.store = store
    }
    
    var body: some View {
        ZStack {
            // Background with subtle animation
            
            NavigationStack {
                VStack {
                    TitleBarView(
                        title: "Levels",
                        color: .cyan,
//                        importAction:{ store.send(.importButtonPressed) },
                        exportAction:{ store.send(.exportButtonPressed) },
//                        addItemAction: nil,
                        showSettingsAction: { store.send(.delegate(.settingsButtonPressed)) }
                    )
                    
                    PackView(store: store.scope(state: \.pack, action: \.pack))
                    
                    // Level grid
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 16)], spacing: 20) {
                            ForEach(store.levels) { level in
                                LevelCard(level: level) {
                                    store.send(.itemSelected(level.id))
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                Spacer()
            }
            .onAppear {
                store.send(.pageLoaded)
            }
            .fullScreenCover(
                item: $store.scope(state: \.playGame, action: \.playGame)
            ) { store in
                PlayGameView(store: store)
            }
        }
    }
}


// Custom level card view
struct LevelCard: View {
    let level: GameLevel
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Image("ButtonBackground") // Add this image to your asset catalog
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)

                Text("\(level.number ?? 0)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.6), radius: 2, x: 1, y: 1)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 120, height: 120) // Adjust size as needed
    }
}

// Button press animation
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
            
#Preview {
    let levels = [
        GameLevel(layout: Layout(id: UUID(0), number: 1, gridText: "..|..|", letterMap: nil), id: UUID(0), number:0)
    ]
    
    let store = Store(
        initialState: GameLevelsTabFeature.State(levels: IdentifiedArray(uniqueElements: levels)),
        reducer: { GameLevelsTabFeature() }
    )

    
    GameLevelsTabView(
        store: store,
//        prefs: Store (
//            initialState: GameLevelsTabFeature.State(),
//            reducer: { GameLevelsTabFeature() }
//        )
    )
//    .onAppear {
//        let packDefinition = GameLevelsTabFeature()
//        store.send(.loadLevels(packDefinition))
//    }
}






//import SwiftUI
//import ComposableArchitecture
//import CrosscodeDataLibrary
//
//struct GameLevelsTabView: View {
//    @Bindable var store: StoreOf<GameLevelsTabFeature>
//    
//    var body: some View {
//        VStack {
////            if let currentPack = store.currentPack {
////                Text("Current pack \(currentPack.id)")
////            }
////            else {
////                Text("No current pack")
////            }
////            ManifestView()
//            List {
//                ForEach(store.layouts, id: \.self) { level in
//                    Text("\(level.name)")
//                        .onTapGesture {
////                            store.send(.didSelectLevel(level))
//                        }
//                }
//            }
//        }
////        .fullScreenCover(
////            item: $store.scope(state: \.editView, action: \.editView)
////        ) { store in
////            LayoutEditView(store: store)
////        }
//    }
//}
//            
//#Preview {
//    let levels:[GameLevel] = [
//        GameLevel(id: UUID(0), number: 1, packId: UUID(0), gridText: "..|..|")
//    ]
//    
//    GameLevelsTabView(
//        store: Store(
//            initialState: GameLevelsTabFeature.State(
//                layouts: IdentifiedArrayOf<GameLevel>(uniqueElements: levels)
//            ),
//            reducer: { GameLevelsTabFeature() }
//        )
//    )
//}
