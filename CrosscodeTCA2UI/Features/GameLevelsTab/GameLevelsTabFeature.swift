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
    
    
    @CasePathable
    enum Action {
        case view(View)
        case `internal`(Internal)
        case delegate(Delegate)
        
        @CasePathable
        enum View  {
            case pageLoaded
            case itemSelected(UUID)
            
            case exportButtonPressed
            case importButtonPressed
        }
        
        @CasePathable
        enum Internal  {
        }
        
        case pack(PackFeature.Action)
        case importGameLevels(ImportGameLevelsReducer.Action)
        case exportGameLevels(ExportGameLevelsReducer.Action)
        case loadGameLevels(LoadGameLevelsReducer.Action)
        case playGame(PresentationAction<PlayGameFeature.Action>)
        
        @CasePathable
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
                case let .view(viewAction):
                    return handleViewAction(&state, viewAction)
                    
                case let .internal(internalAction):
                    return handleInternalAction(&state, internalAction)
                    
                case .delegate:
                    return .none
                    
                case let .pack(.delegate(delegateAction)):
                    return handlePackDelegate(&state, delegateAction)

                case let .exportGameLevels(.delegate(delegateAction)):
                    return handleExportGameLevelsDelegate(&state, delegateAction)

                case let .importGameLevels(.delegate(delegateAction)):
                    return handleImportGameLevelsDelegate(&state, delegateAction)
                    
                case .pack, .importGameLevels, .exportGameLevels, .loadGameLevels, .playGame:
                    return .none
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
    
    func handleError(_ state: inout State, error: Error) -> Effect<Action> {
        state.error = EquatableError(error)
        state.isBusy = false
        debugPrint("Error: \(error.localizedDescription)")
        return .none
    }
}

extension GameLevelsTabFeature {
    func handleViewAction(_ state: inout State, _ action: Action.View) -> Effect<Action> {
        switch action {
            case .pageLoaded:
                return .none
                
            case .itemSelected(let id):
                state.playGame = PlayGameFeature.State(levelID: id)
                return .none
                
            case .importButtonPressed:
                return .send(.importGameLevels(.api(.start)))
                
            case .exportButtonPressed:
                return .send(.exportGameLevels(.api(.start)))
                
        }
    }
}

    
// MARK: Internal Actions
extension GameLevelsTabFeature {
    func handleInternalAction(_ state: inout State, _ action: Action.Internal) -> Effect<Action> {
//        switch action {
//        }
    }
}
