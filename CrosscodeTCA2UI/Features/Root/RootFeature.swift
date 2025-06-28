import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct RootFeature {
    @Dependency(\.uuid) var uu
    
    @ObservableState
    struct State {
        var layoutsList =  LayoutsTabFeature.State()
        var gameLevelsList =  GameLevelsTabFeature.State()
        var tab: NavTab = .edit
        @Presents var settings: SettingsFeature.State?
    }
    
    enum Action: Equatable {
        case layoutsList(LayoutsTabFeature.Action)
        case gameLevelsListAction(GameLevelsTabFeature.Action)
        case setTab(NavTab)
        case settingsButtonPressed
        case settings(PresentationAction<SettingsFeature.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .setTab(let tab):
                    state.tab = tab
                    return .none
                    
                case .settingsButtonPressed:
                    state.settings = .init()
                    return .none
                    
                case let .layoutsList(.delegate(delegateAction)):
                    return handleLayoutsListDelegate(&state, delegateAction)

                case .layoutsList:
                    return .none
                case .gameLevelsListAction(_):
                    return .none
                case .settings(_):
                    return .none
            }
        }
        .ifLet(\.$settings, action: \.settings) {
            SettingsFeature()
        }
        
        Scope(state: \.layoutsList,action: \.layoutsList) {LayoutsTabFeature()}
        Scope(state: \.gameLevelsList,action: \.gameLevelsListAction) {GameLevelsTabFeature()}
    }
    
    
    private func handleLayoutsListDelegate(_ state: inout State,_ action: LayoutsTabFeature.Action.Delegate) -> Effect<Action> {
        switch action {
            case .settingsButtonPressed:
                state.settings = .init()
                return .none
        }
    }
}


