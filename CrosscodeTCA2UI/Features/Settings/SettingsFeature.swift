import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct SettingsFeature {
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.isPresented) var isPresented
    
    @ObservableState
    struct State: Equatable {
        var settings = Settings()
//        @Shared(.appStorage("isEditMode")) var isEditMode: Bool = false
        var error: EquatableError?
    }
    
    enum Action: BindableAction, Equatable {
        case pageLoaded
        case backButtonTapped
        case binding(BindingAction<State>)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
                case .pageLoaded:
                    return .none
                case .backButtonTapped:
                    return handleBackButton(&state)
                case .binding(_):
                    return .none
            }
        }
    }
    
    func handleBackButton(_ state: inout State) -> Effect<Action> {
        if isPresented {
//            state.isExiting = true
//            if state.isPopulated {
                return .run { _ in await dismiss() }
//            }
//            return .send(.saveLayout(.start))
        } else {
            return .none
        }
    }
}

extension SettingsFeature {
    public enum FeatureError: Error {
        case loadLevelError
        case saveLevelError(_ text:String)
    }
}
