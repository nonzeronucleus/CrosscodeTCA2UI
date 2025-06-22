import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct LoadGameLevelReducer {
    @Dependency(\.apiClient) var apiClient
    
    enum Action: Equatable {
        case start(UUID)
        case success(GameLevel)
        case failure(EquatableError)
    }
    
    var body: some Reducer<PlayGameFeature.State, Action> {
        Reduce { state, action in
            switch action {
                case .start(let id):
                    state.isBusy = true
                    return loadLevel(&state, id:id)
                    
                case .success(let level):
                    state.level = level
                    state.isBusy = false
                    state.isDirty = false

                    return .none

                case .failure(let error):
                    debugPrint(error)
                    return .none
            }
        }
    }
    
    private func loadLevel(_ state: inout PlayGameFeature.State, id:UUID) -> Effect<Action> {
        return .run { send in
            do {
                let result = try await apiClient.gameLevelsAPI.fetchLevel(id: id)
                
                if let result = result as? GameLevel {
                    await send(.success(result))
                }
                else {
                    await send(.failure(EquatableError(PlayGameFeature.FeatureError.loadLevelError)))
                }
            }
            catch {
                await send(.failure(EquatableError(error)))
            }
        }
    }
}
