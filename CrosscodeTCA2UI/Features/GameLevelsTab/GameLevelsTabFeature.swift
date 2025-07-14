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
        var pack = PackFeature.State()

        var isBusy: Bool = false
        var error: EquatableError?
    }
    
    enum Action: Equatable {
        case pageLoaded
        case itemSelected(UUID)
        
        case exportButtonPressed
        case importButtonPressed
        
        case pack(PackFeature.Action)
        case importGameLevels(ImportGameLevelsReducer.Action)
        case exportGameLevels(ExportGameLevelsReducer.Action)
        case loadGameLevels(LoadGameLevelsReducer.Action)
        case playGame(PresentationAction<PlayGameFeature.Action>)
        
        case delegate(Delegate)
        
        enum Delegate {
            case settingsButtonPressed
        }
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.self, action: \.loadGameLevels) { LoadGameLevelsReducer() }
        Scope(state: \.self, action: \.exportGameLevels) { ExportGameLevelsReducer() }
        Scope(state: \.self, action: \.exportGameLevels) { ExportGameLevelsReducer() }
        Scope(state: \.pack, action: \.pack) { PackFeature() }

        Reduce { state, action in
            switch action {
                case .pageLoaded:
                    return .none

                case .itemSelected(let id):
                    state.playGame = PlayGameFeature.State(levelID: id)
                    return .none
                    
                case .importButtonPressed:
                    return .send(.importGameLevels(.start))
                    
                case .exportButtonPressed:
                    return .send(.exportGameLevels(.start))
                    
                case let .pack(.delegate(delegateAction)):
                    return handlePackDelegate(&state, delegateAction)
                    
                case let .exportGameLevels(.delegate(delegateAction)):
                    return handleExportGameLevelsDelegate(&state, delegateAction)

                case let .importGameLevels(.delegate(delegateAction)):
                    return handleImportGameLevelsDelegate(&state, delegateAction)
                    
                case .loadGameLevels(.api), .loadGameLevels(.internal), .playGame, .importGameLevels, .exportGameLevels, .delegate, .pack:
                    return .none
                    
                case let .loadGameLevels(.delegate(delegateAction)):
                    return handleLoadGameLevelDelegate(&state, delegateAction)
                    
            }
        }
        .ifLet(\.$playGame, action: \.playGame) {
            PlayGameFeature()
        }
    }
    
    private func handlePackDelegate(_ state: inout State,_ action: PackFeature.Action.Delegate) -> Effect<Action> {
        switch action {
            case let .didChangePack(pack):
                return .send(.loadGameLevels(.api(.start(pack.id))))
        }
    }
    
    private func handleExportGameLevelsDelegate(_ state: inout State,_ action: ExportGameLevelsReducer.Action.Delegate) -> Effect<Action> {
        switch action {
            case .failure(let error):
                return handleError(&state, error: error)
        }
    }
    
    private func handleLoadGameLevelDelegate(_ state: inout State,_ action: LoadGameLevelsReducer.Action.Delegate) -> Effect<Action> {
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



