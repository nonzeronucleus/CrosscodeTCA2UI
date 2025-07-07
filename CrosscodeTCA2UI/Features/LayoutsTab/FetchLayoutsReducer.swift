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
            case noLayoutsLoaded
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
                let layouts = try await apiClient.layoutsAPI.fetchAllLevels() as! [Layout]
                
                if layouts.isEmpty {
                    await send(.delegate(.noLayoutsLoaded))
                }
                
                await send(.success(layouts))
            }
            catch {
                await send(.delegate(.failure(EquatableError(error))))
            }
        }
    }
}

