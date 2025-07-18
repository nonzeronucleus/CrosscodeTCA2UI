import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct LoadGameLevelsReducer {
    typealias State = GameLevelsTabFeature.State
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
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case let .api(apiAction):
                    return handleAPIAction(&state, apiAction)
                    
                case let .internal(internalAction):
                    return handleInternalAction(&state, internalAction)

                case .delegate:
                    return .none
            }
        }
    }
}


extension LoadGameLevelsReducer {
    func handleAPIAction(_ state: inout State, _ action: Action.API) -> Effect<Action> {
        switch action {
            case let .start(id):
                state.isBusy = true
                return loadGameLevels(&state, id:id)
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

    
// MARK: Internal Actions
extension LoadGameLevelsReducer {
    func handleInternalAction(_ state: inout State, _ action: Action.Internal) -> Effect<Action> {
        switch action {
                
            case .success(let levels):
                state.levels = IdentifiedArray(uniqueElements: levels)
                state.isBusy = false
                return .none
        }
    }
}
