import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct RootFeature {
    @Dependency(\.uuid) var uu
    
    @ObservableState
    struct State: Equatable {
        var layoutsList =  LayoutsTabFeature.State()
        var gameLevelsList =  GameLevelsTabFeature.State()
        var tab: NavTab = .play
    }
    
    enum Action: Equatable {
        case layoutsListAction(LayoutsTabFeature.Action)
        case gameLevelsListAction(GameLevelsTabFeature.Action)
        case setTab(NavTab)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .setTab(let tab):
                    state.tab = tab
                    return .none
                case .layoutsListAction(_):
                    return .none
                case .gameLevelsListAction(_):
                    return .none
            }
        }
        
        Scope(state: \.layoutsList,action: \.layoutsListAction) {LayoutsTabFeature()}
        Scope(state: \.gameLevelsList,action: \.gameLevelsListAction) {GameLevelsTabFeature()}
    }
}


