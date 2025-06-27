import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

    @Reducer
struct DeleteLayoutsReducer {
    @Dependency(\.apiClient) var apiClient
    
    enum Action: Equatable {
        case start(UUID)
        case delegate(Delegate)
        
        enum Delegate : Equatable {
            case success
            case failure(EquatableError)
        }
    }
    
    var body: some Reducer<LayoutsTabFeature.State, Action> {
        Reduce { state, action in
            switch action {
                case let .start(id):
                    return deleteLayout(&state, id: id)
                case .delegate:
                    return .none
            }
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

