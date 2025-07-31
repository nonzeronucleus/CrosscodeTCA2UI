import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct PlayGameFeature {
    @Dependency(\.uuid) var uuid
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.isPresented) var isPresented
    
    @ObservableState
    struct State: Equatable, ErrorHandling {
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
    
    enum Action {
        case view(View)
        
        case keyboard(KeyboardFeature.Action)
        case playGameCell(PlayGameCellReducer.Action)
        case loadGameLevel(LoadGameLevelReducer.Action)
        case revealLetterReducer(RevealLetterReducer.Action)

        enum View {
            case pageLoaded
            case backButtonTapped
            case checkToggled
            case revealRequested
        }
    }
    
    var body: some Reducer<State, Action> {
        
        Scope(state: \.self, action: \.loadGameLevel ) { LoadGameLevelReducer() }
        Scope(state: \.self, action: \.playGameCell) { PlayGameCellReducer() }
        Scope(state: \.self, action: \.revealLetterReducer) { RevealLetterReducer() }
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
                            return .send(.revealLetterReducer(.api(.start)))
                    }
                    
                case let .loadGameLevel(.delegate(delegateAction)):
                    checkDelegateError(&state, delegateAction)
                    return .none
                    
                case let .revealLetterReducer(.delegate(.finished(result))):
                    return handleLetterAddedDelegateFinished2(&state, result)
                    
//                case let .revealLetterReducer(.delegate(delegateAction)):
//                    return handleRevealLetterReducerDelegate(&state, delegateAction)
                    
                case let .keyboard(.delegate(.finished(result))):
                    return handleLetterAddedDelegateFinished2(&state, result)

                    
                case .playGameCell,
                        .keyboard(.view(_)),
                        .loadGameLevel(.api), .loadGameLevel(.internal),
                        .revealLetterReducer(.api), .revealLetterReducer(.internal):
                    return .none
            }
        }
    }
    
    func handleLetterAddedDelegateFinished2(_ state: inout State, _ result: Result<Int, any Error>) -> Effect<Action> {
//        guard case .finished(let result) = action else {  return .none }
        
        // 2. Switch on the Result
        switch result {
            case .success(let count):
                debugPrint("Revealed \(count) letters so far")
                return .none
            case .failure(let error):
                state.error = EquatableError(error)
                return .none
        }
    }

    
    
    func handleLetterAddedDelegateFinished(_ state: inout State, _ action: RevealLetterReducer.Action.Delegate) -> Effect<Action> {
        guard case .finished(let result) = action else {  return .none }
        
        // 2. Switch on the Result
        switch result {
            case .success(let count):
                debugPrint("Revealed \(count) letters")
                return .none
            case .failure(_):
                checkDelegateError(&state, action)
                return .none
        }
    }

    
    func handleRevealLetterReducerDelegate(_ state: inout State, _ action: RevealLetterReducer.Action.Delegate) -> Effect<Action> {
        guard case .finished(let result) = action else {  return .none }
        
        // 2. Switch on the Result
        switch result {
            case .success(let count):
                debugPrint("Revealed \(count) letters")
                return .none
            case .failure(_):
                checkDelegateError(&state, action)
                return .none
        }
    }
    
    func handleKeyboardReducerDelegate(_ state: inout State, _ action: KeyboardFeature.Action.Delegate) -> Effect<Action> {
        state.checking = false
        guard case .finished(let result) = action else {  return .none }
        
        // 2. Switch on the Result
        switch result {
            case .success(let count):
//                debugPrint("Revealed \(count) letters")
//                do {
//                    guard let letterMap = state.level?.oldLetterMap else { return .none }
//                    
//                    if count == 26 {
//                        if try getNextLetter(letterMap: letterMap, usedLetters: state.usedLetters, attemptedLetters: state.level!.attemptedLetters) == nil {
//                            debugPrint( "YOU WIN!")
//                        }
//                    }
//                }
//                catch(_) {
//                    //ignore error
//                }
                return .none
            case .failure(_):
                checkDelegateError(&state, action)
                return .none
        }
    }
}


//                    state.checking = false
//                    if case .finished(.success(let remainingLetters)) = delegateAction {
//                        debugPrint(remainingLetters)
//                    }
//                    else {
//                        checkDelegateError(&state, delegateAction)
//                    }
//                    return .none



extension PlayGameFeature {
    public enum FeatureError: Error {
        case loadLevelError
        case saveLevelError(_ text:String)
    }
}
