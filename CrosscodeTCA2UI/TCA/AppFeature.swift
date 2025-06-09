import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct AppFeature {
    @Dependency(\.uuid) var uu
    
    @ObservableState
    struct State: Equatable {
        var layoutsList =  LayoutsListFeature.State()
        var route = RouteFeature.State()
    }
    
    enum Action: Equatable {
        case layoutsListAction(LayoutsListFeature.Action)
        case routeAction(RouteFeature.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .layoutsListAction(_):
                    return .none
                case .routeAction(_):
                    return .none
            }
        }
        
        Scope(
            state: \.layoutsList,
            action: \.layoutsListAction
        ) {
            LayoutsListFeature()
        }
        
        Scope(
            state: \.route,
            action: \.routeAction
        ) {
            RouteFeature()
        }

    }
}
