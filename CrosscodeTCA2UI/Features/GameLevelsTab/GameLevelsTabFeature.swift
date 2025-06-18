import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct GameLevelsTabFeature {
    @Dependency(\.uuid) var uuid
    
    @ObservableState
    struct State: Equatable {
        var levels: IdentifiedArrayOf<GameLevel> = []
        var isBusy: Bool = false
        var error: EquatableError?
    }
    
    enum Action: Equatable {
        case pageLoaded
        case loadLayout(LoadGameLevelsReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.self, action: \.loadLayout) { LoadGameLevelsReducer() }

        Reduce { state, action in
            switch action {
                case .pageLoaded:
                    return .send(.loadLayout(.start))
                    
                case .loadLayout(_):
                    return .none
            }
        }
    }
}


//        @Presents var editLayout: EditLayoutFeature.State?

