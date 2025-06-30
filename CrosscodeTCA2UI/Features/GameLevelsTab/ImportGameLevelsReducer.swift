import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct ImportGameLevelsReducer {
    @Dependency(\.apiClient) var apiClient
    
    enum Action: Equatable {
        case start
        case delegate(Delegate)
        case success([GameLevel])

        enum Delegate : Equatable {
            case failure(EquatableError)
        }
    }
    
    var body: some Reducer<GameLevelsTabFeature.State, Action> {
        Reduce { state, action in
            switch action {
                case .start:
                    return importGameLevels(&state)
                case let .success(gameLevels):
                    state.levels = IdentifiedArrayOf(uniqueElements: gameLevels)
                    return .none
                case .delegate:
                    return .none
            }
        }
    }
    private func importGameLevels(_ state: inout GameLevelsTabFeature.State) -> Effect<Action> {
        return .run { send in
            do {
                let gameLevels = try await apiClient.gameLevelsAPI.importGameLevels()

                await send(.success(gameLevels))
            }
            catch {
                await send(.delegate(.failure(EquatableError(error))))
            }
        }
    }
}

