import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

    @Reducer
struct FetchLayoutsReducer {
    @Dependency(\.apiClient) var apiClient
    
    enum Action: Equatable {
        case start
        case success([Layout])
        case delegate(Delegate)
        
        enum Delegate : Equatable {
            case failure(EquatableError)
        }
    }
    var body: some Reducer<LayoutsTabFeature.State, Action> {
        Reduce { state, action in
            switch action {
                case .start:
                    return fetchAll(&state)
                case .delegate:
                    return .none
                case let .success(layouts):
                    state.layouts = IdentifiedArray(uniqueElements: layouts)
                    return .none

            }
        }
    }
    
    private func fetchAll(_ state: inout LayoutsTabFeature.State) -> Effect<Action> {
        @Dependency(\.apiClient) var apiClient
        return .run { send in
            do {
                let result = try await apiClient.layoutsAPI.fetchAllLevels() as! [Layout]
                
                await send(.success(result))
            }
            catch {
                await send(.delegate(.failure(EquatableError(error))))
            }
        }
    }
}

