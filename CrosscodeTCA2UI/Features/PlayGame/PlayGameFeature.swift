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
        var keyboard: KeyboardFeature.State = .init()
        
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
    }
    
    var body: some Reducer<State, Action> {
        
        Scope(state: \.self, action: \.loadGameLevel) { LoadGameLevelReducer() }
        
        Reduce { state, action in
            switch action {
                case .pageLoaded:
                    state.isDirty = false
                    return .send(.loadGameLevel(.start(state.levelID)))
                    
                case .backButtonTapped:
                    if isPresented {
                        state.isExiting = true
                        return .run { _ in
                            debugPrint("Need to implement handler  here.")
                            await dismiss()
                        }
                        
                        //                        return .send(.saveLayout(.start))
                    } else {
                        return .none
                    }
                    
                case .checkToggled:
                    return .none
                case .revealRequested:
                    return .none
                case .keyboard(_):
                    return .none
                case .loadGameLevel(_):
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
