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
//        @Presents var editLayout: EditLayoutFeature.State?

        var isBusy: Bool = false
        var error: EquatableError?
    }
    
    enum Action: Equatable {
        case pageLoaded
        case loadLayout(LoadGameLevelsReducer.Action)
        case itemSelected(UUID)
        case playGame(PresentationAction<PlayGameFeature.Action>)
//        case editLayout(PresentationAction<EditLayoutFeature.Action>)

    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.self, action: \.loadLayout) { LoadGameLevelsReducer() }

        Reduce { state, action in
            switch action {
                case .pageLoaded:
                    return .send(.loadLayout(.start))

                case .itemSelected(let id):
                    state.playGame = PlayGameFeature.State(levelID: id)
                    return .none

                case .loadLayout(_):
                    return .none
                case .playGame(_):
                    return .none
            }
        }
        .ifLet(\.$playGame, action: \.playGame) {
            PlayGameFeature()
        }
    }
}
