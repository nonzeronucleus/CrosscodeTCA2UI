import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct PlayGameFeature {
    @Dependency(\.uuid) var uuid
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.isPresented) var isPresented
    @Dependency(\.apiClient) var apiClient

    
    @ObservableState
    struct State: Equatable, ErrorHandling, LevelState {
        var levelID: UUID
        var level: GameLevel?
        var selectedNumber: Int?
        var usedLetters: Set<Character> {
            get {
                guard let level else { return Set<Character>() }
                
                return level.usedLetters
            }
        }
        
        var checking = false
        var isBusy = false
        var isDirty = false
        var isCompleted: Bool {
            get {
                level?.numCorrectLetters == 26 || false
            }
        }
        
        var showCompletionDialog: Bool = false
        var isExiting: Bool = false
        var error: EquatableError?
    }
    
    enum Action {
        case view(View)
        
        case keyboard(KeyboardFeature.Action)
        case playGameCell(PlayGameCellReducer.Action)
        case loadGameLevel(LoadGameLevelReducer.Action)
        case revealLetterReducer(RevealLetterReducer.Action)
        case saveLevel(SaveLevelReducer<PlayGameFeature>.Action)


        enum View {
            case pageLoaded
            case backButtonTapped
            case checkToggled
            case revealRequested
            case completionDialogDismissTapped
        }
    }
    
    var body: some Reducer<State, Action> {
        
        Scope(state: \.self, action: \.loadGameLevel ) { LoadGameLevelReducer() }
        Scope(state: \.self, action: \.playGameCell) { PlayGameCellReducer() }
        Scope(state: \.self, action: \.revealLetterReducer) { RevealLetterReducer() }
        Scope(state: \.self, action: \.keyboard) { KeyboardFeature() }
        Scope(state: \.self, action: \.saveLevel) { SaveLevelReducer(levelAPI: apiClient.gameLevelsAPI) }


        Reduce { state, action in
            switch action {
                case .view(let viewAction):
                    switch viewAction {
                        case .pageLoaded:
                            state.isDirty = false
                            return .send(.loadGameLevel(.api(.start(state.levelID))))
                            
                        case .backButtonTapped:
                            return handleBackButton(&state)
                            
                        case .checkToggled:
                            state.checking.toggle()
                            return .none

                        case .revealRequested:
                            return .send(.revealLetterReducer(.api(.start)))
                            
                        case .completionDialogDismissTapped:
                            state.showCompletionDialog = false
                            return .none
                    }
                    
                case let .loadGameLevel(.delegate(delegateAction)):
                    if state.isCompleted {
                        state.showCompletionDialog = true
                    }

                    checkDelegateError(&state, delegateAction)
                    return .none
                    
                case let .revealLetterReducer(.delegate(.finished(result))):
                    return handleLetterAddedDelegateFinished(&state, result)
                    
                case let .keyboard(.delegate(.finished(result))):
                    return handleLetterAddedDelegateFinished(&state, result)
                    
                case .saveLevel(.delegate(let delegateAction)):
                    return handleSaveLevelDelegate(&state, delegateAction)

                    
                case .playGameCell,
                        .keyboard(.view(_)),
                        .loadGameLevel(.api), .loadGameLevel(.internal),
                        .revealLetterReducer(.api), .revealLetterReducer(.internal), 
                        .saveLevel(.api), .saveLevel(.internal):
                    return .none
            }
        }
    }
    
    func handleLetterAddedDelegateFinished(_ state: inout State, _ result: Result<Void, any Error>) -> Effect<Action> {
        switch result {
            case .success:
                state.checking = false
                if state.isCompleted {
                    state.showCompletionDialog = true
                }
                return .none
            case .failure(let error):
                state.error = EquatableError(error)
                return .none
        }
    }
    
    func handleBackButton(_ state: inout State) -> Effect<Action> {
        guard isPresented else { return .none }
        state.isExiting = true
        //        return state.isPopulated ? .run { _ in await dismiss() } :
        return .send(.saveLevel(.api(.start)))
    }
        
        
        //send(.saveLeve(.api(.start)))
//            state.isExiting = true
//            return .run { _ in
//                await dismiss()
//            }
//    }
}

extension PlayGameFeature {
    func handleSaveLevelDelegate(_ state: inout State, _ action: SaveLevelReducer<PlayGameFeature>.Action.Delegate) -> Effect<Action> {
        guard case .finished(let result) = action else {  return .none }
        
        // 2. Switch on the Result
        switch result {
            case .success:
                state.isBusy = false
                state.isDirty = false
                return state.isExiting ? .run { _ in await dismiss() } : .none
                
            case .failure(let error):
                // Handle failure
                state.isExiting = false
                state.error = EquatableError(error)
                return .none
        }
    }
}


extension PlayGameFeature {
    public enum FeatureError: Error {
        case loadLevelError
        case saveLevelError(_ text:String)
    }
}
