import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct LoadGameLevelsReducer {
    @Dependency(\.apiClient) var apiClient

    enum Action: Equatable {
        case start
        case success([GameLevel])
        case failure(EquatableError)
    }

    var body: some Reducer<GameLevelsTabFeature.State, Action> {
        Reduce { state, action in
            switch action {
                case .start:
                    state.isBusy = true
                    return loadGameLevels(&state)

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

    private func loadGameLevels(_ state: inout GameLevelsTabFeature.State) -> Effect<Action> {
        return .run { send in
            do {
                let result = try await apiClient.gameLevelsAPI.fetchAllLevels()

                if let result = result as? [GameLevel] {
                    await send(.success(result))
                }
                else {
                    await send(.failure(EquatableError(EditLayoutError.loadLayoutError)))
                }
            }
            catch {
                await send(.failure(EquatableError(error)))
            }
        }
    }
}
