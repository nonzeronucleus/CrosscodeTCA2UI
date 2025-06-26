import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct SettingsFeature {
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.isPresented) var isPresented
    
    @ObservableState
    struct State: Equatable {
//        @Shared(.appStorage("isEditMode")) var isEditMode: Bool = false
        var isEditMode: Bool = false
        var error: EquatableError?
    }
    
    enum Action: BindableAction, Equatable {
        case pageLoaded
        case binding(BindingAction<State>)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
                case .pageLoaded:
                    return .none
                case .binding(_):
                    return .none
            }
        }
    }
}

extension SettingsFeature {
    public enum FeatureError: Error {
        case loadLevelError
        case saveLevelError(_ text:String)
    }
}
