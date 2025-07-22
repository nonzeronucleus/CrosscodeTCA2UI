import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct ImportGameLevelsReducer {
    typealias State = GameLevelsTabFeature.State

    @Dependency(\.apiClient) var apiClient

    
    enum Action {
        case api(API)
        case `internal`(Internal)
        case delegate(Delegate)

        @CasePathable
        enum API {
            case start
        }
        
        @CasePathable
        enum Internal {
            case success([GameLevel])
        }

        enum Delegate {
            case failure(Error)
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
    
//    var body: some Reducer<State, Action> {
//        Reduce { state, action in
//            switch action {
//                case .start:
//                    return importGameLevels(&state)
//                case let .success(gameLevels):
//                    state.levels = IdentifiedArrayOf(uniqueElements: gameLevels)
//                    return .none
//                case .delegate:
//                    return .none
//            }
//        }
//    }
}

extension ImportGameLevelsReducer {
    func handleAPIAction(_ state: inout State, _ action: Action.API) -> Effect<Action> {
        switch action {
            case .start:
                return importGameLevels(&state)
        }
    }
    
    private func importGameLevels(_ state: inout State) -> Effect<Action> {
        return .run { send in
            do {
                let gameLevels = try await apiClient.gameLevelsAPI.importGameLevels()

                await send(.internal(.success(gameLevels)))
            }
            catch {
                await send(.delegate(.failure(error)))
            }
        }
    }
}

    
    // MARK: Internal Actions
extension ImportGameLevelsReducer {
    func handleInternalAction(_ state: inout State, _ action: Action.Internal) -> Effect<Action> {
        switch action {
            case let .success(gameLevels):
                state.levels = IdentifiedArrayOf(uniqueElements: gameLevels)

                return .none
        }
    }
}


