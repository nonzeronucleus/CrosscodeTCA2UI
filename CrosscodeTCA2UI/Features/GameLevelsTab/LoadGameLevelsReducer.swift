import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct LoadGameLevelsReducer {
    @Dependency(\.apiClient) var apiClient

    enum Action: Equatable {
        case start(UUID)
        case success([GameLevel])
        case failure(EquatableError)
    }

    var body: some Reducer<GameLevelsTabFeature.State, Action> {
        Reduce { state, action in
            switch action {
                case let .start(id):
                    state.isBusy = true
                    return loadGameLevels(&state, id:id)

                case .success(let levels):
                    state.levels = IdentifiedArray(uniqueElements: levels)
                    state.isBusy = false
                    return .none

                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    return .none
            }
        }
    }

    private func loadGameLevels(_ state: inout GameLevelsTabFeature.State, id: UUID) -> Effect<Action> {
        return .run { send in
            do {
                let result = try await apiClient.gameLevelsAPI.fetchGameLevels(packId: id)

                await send(.success(result))
            }
            catch {
                await send(.failure(EquatableError(error)))
            }
        }
    }
}
