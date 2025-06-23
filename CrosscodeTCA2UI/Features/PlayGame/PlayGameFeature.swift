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
        case pageLoaded
        case backButtonTapped
        case checkToggled
        case revealRequested
        case keyboard(KeyboardFeature.Action)
        case loadGameLevel(LoadGameLevelReducer.Action)
        case playGameCell(PlayGameCellReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.self, action: \.loadGameLevel) { LoadGameLevelReducer() }
        Scope(state: \.self, action: \.playGameCell) { PlayGameCellReducer() }
        Scope(state: \.self, action: \.keyboard) { KeyboardFeature() }

        Reduce { state, action in
            switch action {
                case .pageLoaded:
                    state.isDirty = false
                    return .send(.loadGameLevel(.start(state.levelID)))
                    
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
                    return .none
                case .revealRequested:
                    return .none
//                case .keyboard(.delegate(.letterSelected(let letter))):
//                    guard let selectedNumber = state.selectedNumber else { return .none }
//                    state.level!.attemptedLetters[selectedNumber] = letter
//                    return .none
                case .keyboard(_):
                    return .none
                case .loadGameLevel(_):
                    return .none
//                case .playGameCell(.letterSelected(let char)):
//                    return .run { send in
//                        await send(.keyboard(.letterSelectedInGrid(char)))
//                    }
                case .playGameCell(_):
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
