import SwiftUI
import ComposableArchitecture
import CrosscodeDataLibrary



struct RootView: View {
    @Bindable var store: StoreOf<RootFeature>
    
    //    // MARK: - Computed binding for sheet
    
    var body: some View {
        VStack {
            TabView(
                selection: Binding(
                    get: { store.tab },
                    set: { store.send(.setTab($0)) }
                )
            ) {
                // MARK: - Play Tab
                NavigationStack {
                    VStack {
                        TitleBarView(
                            title: "Levels",
                            color: .cyan,
                            addItemAction: nil,
                            showSettingsAction: {store.send(.settingsButtonPressed)}
                        )
                        GameLevelsTabView(store:store.scope(state:\.gameLevelsList , action: \.gameLevelsListAction))
                    }
                }
                .tabItem { Label("Play", systemImage: "gamecontroller") }
                .tag(NavTab.play)
                
                // MARK: - Edit Tab
                LayoutsTabView(store:store.scope(state:\.layoutsList , action: \.layoutsList))
                    .tabItem { Label("Edit", systemImage: "pencil") }
                    .tag(NavTab.edit)
            }
        }
        .fullScreenCover(
            item: $store.scope(state: \.settings, action: \.settings)
        ) { settingsStore in
            SettingsView(store: settingsStore)
        }

    }
}



//        .fullScreenCover(
//            item: $store.scope(state: \.settings, action: \.settings)
//        ) { settingsStore in
//            SettingsView(store: settingsStore)
//        }




//import SwiftUI
//import ComposableArchitecture
//import CrosscodeDataLibrary
//
//
//
//struct RootView: View {
//    let store: StoreOf<RootFeature>
////    let navStore: StoreOf<RouteFeature>
//
////    // MARK: - Computed binding for sheet
////    private var modalRouteBinding: Binding<Route?> {
////        Binding<Route?>(
////            get: { presentedRoute?.asModal },
////            set: { newValue in
////                if newValue == nil {
////                    store.dispatch(action: NavigationActions.dismissPresentedRoute())
////                }
////            }
////        )
////    }
//
//    var body: some View {
//        VStack {
//            TabView(
//                selection: Binding(
//                    get: { store.tab },
//                    set: { store.send(.setTab($0)) }
//                )
//            ) {
//                // MARK: - Play Tab
//                NavigationStack {
//                    VStack {
//                        TitleBarView(
//                            title: "Levels",
//                            color: .cyan,
//                            addItemAction: nil,
//                            showSettingsAction: { /*store.dispatch(action: NavigationActions.showSettings()*/ }
//                        )
//                        
////                        PlayableLevelsListView()
////                            .navigationDestination(for: UUID.self) { id in
////                                VStack {
////                                    Text("\(id)")
//////                                    LayoutEditView(layoutID: id)
//////                                        .toolbar(.hidden, for: .tabBar)
////                                }
////                            }
////
//                    }
//                }
//                .tabItem { Label("Play", systemImage: "gamecontroller") }
//                .tag(NavTab.play)
//
//                // MARK: - Edit Tab
//                NavigationStack(/*path: $navigationPath*/) {
//                    VStack {
//                        TitleBarView(
//                            title: "Layouts",
//                            color: .cyan,
//                            addItemAction: { store.send( .layoutsListAction(.addLayout(.start)) ) },
//                            showSettingsAction: { /*store.dispatch(action: NavigationActions.showSettings())*/ }
//                        )
//                        
//                        LayoutsTabView(store:store.scope(state:\.layoutsList , action: \.layoutsListAction))
////                            .navigationDestination(for: UUID.self) { id in
////                                VStack {
////                                    Text("\(id)")
////                                    LayoutEditView(layoutID: id)
////                                        .toolbar(.hidden, for: .tabBar)
//                                }
//                            }
//                    }
//                }
////                .onChange(of: presentedRoute) { _, newRoute in
////                    switch newRoute {
////                    case .layoutDetail(let id):
////                        if !navigationPath.contains(id) {
////                            navigationPath.append(id)
////                        }
////                    case .settings:
////                        break // handled by .sheet
////                    case nil:
////                        if !navigationPath.isEmpty {
////                            navigationPath.removeLast()
////                        }
////                    }
////                }
//                .tabItem { Label("Edit", systemImage: "pencil") }
//                .tag(NavTab.edit)
////            }
////            .toolbar {
////                ToolbarItem(placement: .navigationBarTrailing) {
////                    Button(action: {
////                        store.dispatch(action: NavigationActions.showSettings())
////                    }) {
////                        Image(systemName: "gearshape")
////                    }
////                }
//            }
//        }
//
//        // MARK: - Modal Sheet for Settings
////        .sheet(item: modalRouteBinding) { route in
////            switch route {
////                case .settings:
////                    SettingsView()
////                default:
////                    EmptyView()
////            }
////        }
//    }
//}
//
