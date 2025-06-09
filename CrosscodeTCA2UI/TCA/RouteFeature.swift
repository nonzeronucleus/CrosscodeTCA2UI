enum NavTab: Equatable, Encodable {
    case play
    case edit
}


import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct RouteFeature {
    @ObservableState
    struct State: Equatable {
        var tab: NavTab = .edit
    }
    
    enum Action: Equatable {
        case setTab(NavTab)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .setTab(let tab):
                    state.tab = tab
                    return .none
            }
        }
    }
}

