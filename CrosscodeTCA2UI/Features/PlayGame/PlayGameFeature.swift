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
                    
                case .keyboard(_):
                    state.checking = false
                    return .none
                    
                case let .loadGameLevel(.delegate(delegateAction)):
                    checkDelegateError(&state, delegateAction)
                    return .none
                    
                case let .revealLetterReducer(.delegate(delegateAction)):
                    checkDelegateError(&state, delegateAction)
                    return .none
                    
                case .playGameCell,
                        .loadGameLevel(.api), .loadGameLevel(.internal),
                        .revealLetterReducer(.api), .revealLetterReducer(.internal):
                    return .none
            }
        }
    }
    

}



extension PlayGameFeature {
    public enum FeatureError: Error {
        case loadLevelError
        case saveLevelError(_ text:String)
    }
}
