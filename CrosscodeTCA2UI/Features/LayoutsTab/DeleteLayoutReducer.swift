import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct DeleteLayoutsReducer {
    typealias State = LayoutsTabFeature.State
    @Dependency(\.apiClient) var apiClient
    
    @CasePathable
    enum Action: Equatable {
        case api(API)
        case delegate(Delegate)
        
        @CasePathable
        enum API : Equatable {
            case start(UUID)
        }
        
        @CasePathable
        enum Delegate : Equatable {
            case success
            case failure(EquatableError)
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case let .api(apiAction):
                    return handleAPIAction(&state, apiAction)
                case .delegate:
                    return .none
            }
        }
    }
}

extension DeleteLayoutsReducer {
    func handleAPIAction(_ state: inout State, _ action: Action.API) -> Effect<Action> {
        switch action {
            case let .start(id):
                return deleteLayout(&state, id: id)
        }
    }

    private func deleteLayout(_ state: inout LayoutsTabFeature.State, id:UUID) -> Effect<Action> {
        @Dependency(\.apiClient) var apiClient
        return .run { send in
            do {
                try await apiClient.layoutsAPI.deleteLevel(id: id)
                return await send(.delegate(.success))
            }
            catch {
                await send(.delegate(.failure(EquatableError(error))))
            }
        }
    }
}
