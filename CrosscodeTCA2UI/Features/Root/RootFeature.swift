import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct RootFeature {
    @Dependency(\.uuid) var uuid
    
    
    @ObservableState
    struct State: Equatable {
        var layoutsList =  LayoutsTabFeature.State()
        var gameLevelsList =  GameLevelsTabFeature.State()
        var tab: NavTab = .play
        @Presents var settings: SettingsFeature.State?
    }
    
    enum Action {
        case layoutsList(LayoutsTabFeature.Action)
        case gameLevelsList(GameLevelsTabFeature.Action)
        case setTab(NavTab)
        case settings(PresentationAction<SettingsFeature.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .setTab(let tab):
                    state.tab = tab
                    return .none

                case let .gameLevelsList(.delegate(delegateAction)):
                    return handleGameLevelsListDelegate(&state, delegateAction)
                    
                case let .layoutsList(.delegate(delegateAction)):
                    return handleLayoutsListDelegate(&state, delegateAction)

                case .layoutsList:
                    return .none
                case .gameLevelsList:
                    return .none
                case .settings:
                    return .none
            }
        }
        .ifLet(\.$settings, action: \.settings) {
            SettingsFeature()
        }
        
        Scope(state: \.layoutsList,action: \.layoutsList) {LayoutsTabFeature()}
        Scope(state: \.gameLevelsList,action: \.gameLevelsList) {GameLevelsTabFeature()}
    }
    
    
    private func handleGameLevelsListDelegate(_ state: inout State,_ action: GameLevelsTabFeature.Action.Delegate) -> Effect<Action> {
        switch action {
            case .settingsButtonPressed:
                state.settings = .init()
                return .none
        }
    }
    
    private func handleLayoutsListDelegate(_ state: inout State,_ action: LayoutsTabFeature.Action.Delegate) -> Effect<Action> {
        switch action {
            case .settingsButtonPressed:
                state.settings = .init()
                return .none
        }
    }
}


