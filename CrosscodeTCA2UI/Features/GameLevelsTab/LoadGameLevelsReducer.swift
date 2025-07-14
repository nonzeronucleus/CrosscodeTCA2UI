import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct LoadGameLevelsReducer {
    @Dependency(\.apiClient) var apiClient

    enum Action: Equatable {
        case api(API)
        case `internal`(Internal)
        case delegate(Delegate)
        
        enum API : Equatable {
            case start(UUID)
        }
        
        enum Internal : Equatable  {
            case success([GameLevel])
        }
        
        enum Delegate : Equatable {
            case failure(EquatableError)
        }
    }

    var body: some Reducer<GameLevelsTabFeature.State, Action> {
        Reduce { state, action in
            switch action {
                case let .api(apiAction):
                    switch apiAction {
                        case let .start(id):
                            state.isBusy = true
                            return loadGameLevels(&state, id:id)
                    }
                            
                case let .internal(internalAction):
                    switch internalAction {
                            
                        case .success(let levels):
                            state.levels = IdentifiedArray(uniqueElements: levels)
                            state.isBusy = false
                            return .none
                    }
                    
                case .delegate:
                    return .none
            }
        }
    }

    private func loadGameLevels(_ state: inout GameLevelsTabFeature.State, id: UUID) -> Effect<Action> {
        return .run { send in
            do {
                let result = try await apiClient.gameLevelsAPI.fetchGameLevels(packId: id)

                await send(.internal(.success(result)))
            }
            catch {
                await send(.delegate(.failure(EquatableError(error))))
            }
        }
    }
}
