import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct GameLevelsTabFeature {
    @Dependency(\.uuid) var uuid
    
    @ObservableState
    struct State: Equatable {
        var levels: IdentifiedArrayOf<GameLevel> = []
        @Presents var playGame: PlayGameFeature.State?

        var isBusy: Bool = false
        var error: EquatableError?
    }
    
    enum Action: Equatable {
        case pageLoaded
        case itemSelected(UUID)
        
        case exportButtonPressed
        case importButtonPressed
        
        case importGameLevels(ImportGameLevelsReducer.Action)
        case exportGameLevels(ExportGameLevelsReducer.Action)
        case loadLayout(LoadGameLevelsReducer.Action)
        case playGame(PresentationAction<PlayGameFeature.Action>)
        
        case delegate(Delegate)
        
        enum Delegate {
            case settingsButtonPressed
        }
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.self, action: \.loadLayout) { LoadGameLevelsReducer() }
        Scope(state: \.self, action: \.exportGameLevels) { ExportGameLevelsReducer() }

        Reduce { state, action in
            switch action {
                case .pageLoaded:
                    return .send(.loadLayout(.start))

                case .itemSelected(let id):
                    state.playGame = PlayGameFeature.State(levelID: id)
                    return .none
                    
                case .importButtonPressed:
                    return .send(.importGameLevels(.start))
                    
                case .exportButtonPressed:
                    return .send(.exportGameLevels(.start))
                    
                case let .exportGameLevels(.delegate(delegateAction)):
                    return handleExportGameLevelsDelegate(&state, delegateAction)

                case let .importGameLevels(.delegate(delegateAction)):
                    return handleImportGameLevelsDelegate(&state, delegateAction)


                case .loadLayout, .playGame, .importGameLevels, .exportGameLevels, .delegate:
                    return .none
            }
        }
        .ifLet(\.$playGame, action: \.playGame) {
            PlayGameFeature()
        }
    }
    private func handleExportGameLevelsDelegate(_ state: inout State,_ action: ExportGameLevelsReducer.Action.Delegate) -> Effect<Action> {
        switch action {
            case .failure(let error):
                return handleError(&state, error: error)
        }
    }
    
    private func handleImportGameLevelsDelegate(_ state: inout State,_ action: ImportGameLevelsReducer.Action.Delegate) -> Effect<Action> {
        switch action {
            case .failure(let error):
                return handleError(&state, error: error)
        }
    }
    
    func handleError(_ state: inout State, error: EquatableError) -> Effect<Action> {
        state.error = error
        state.isBusy = false
        debugPrint("Error: \(error.localizedDescription)")
        return .none
    }
}



