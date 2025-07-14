import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct PlayGameFeature {
    @Dependency(\.uuid) var uuid
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.isPresented) var isPresented
    
    @ObservableState
    struct State: Equatable {
        var levelID: UUID
        var level: GameLevel?
        var selectedNumber: Int?
        var usedLetters: Set<Character> {
            get {
                guard let level else { return Set<Character>() }
                
                return Set<Character>(level.attemptedLetters.filter { $0.isLetter })
            }
        }

        
        var checking = false
        var isBusy = false
        var isDirty = false
        var isCompleted = false
        var isExiting: Bool = false
        var error: EquatableError?
    }
    
    enum Action: Equatable {
        case view(View)
        
        case keyboard(KeyboardFeature.Action)
        case playGameCell(PlayGameCellReducer.Action)
        case loadGameLevel(LoadGameLevelReducer.Action)

        enum View : Equatable {
            case pageLoaded
            case backButtonTapped
            case checkToggled
            case revealRequested
        }
    }
    
    var body: some Reducer<State, Action> {
        
        Scope(state: \.self, action: \.loadGameLevel ) { LoadGameLevelReducer() }
        Scope(state: \.self, action: \.playGameCell) { PlayGameCellReducer() }
        Scope(state: \.self, action: \.keyboard) { KeyboardFeature() }

        Reduce { state, action in
            switch action {
                case .view(let viewAction):
                    switch viewAction {
                        case .pageLoaded:
                            state.isDirty = false
                            return .send(.loadGameLevel(.api(.start(state.levelID))))
                            
                        case .backButtonTapped:
                            if isPresented {
                                state.isExiting = true
                                return .run { _ in
                                    await dismiss()
                                }
                            } else {
                                return .none
                            }
                            
                        case .checkToggled:
                            state.checking.toggle()
                            return .none

                        case .revealRequested:
                            return .none
                    }
                    
                case .keyboard(_):
                    state.checking = false
                    return .none
                    
                case let .loadGameLevel(.delegate(delegateAction)):
                    return handleLoadGameLevelDelegate(&state, delegateAction)
                    
                case .playGameCell, .loadGameLevel(.api), .loadGameLevel(.internal):
                    return .none
            }
        }
    }
    
    private func handleLoadGameLevelDelegate(_ state: inout State,_ action: LoadGameLevelReducer.Action.Delegate) -> Effect<Action> {
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

extension PlayGameFeature {
    public enum FeatureError: Error {
        case loadLevelError
        case saveLevelError(_ text:String)
    }
}
