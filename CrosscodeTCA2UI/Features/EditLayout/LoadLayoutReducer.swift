import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

extension EditLayoutFeature {
    @Reducer
    struct LoadLayoutReducer {
        @Dependency(\.apiClient) var apiClient
        
        @CasePathable
        enum Action: Equatable {
            case start(UUID)
            case success(Layout)
            case delegate(Delegate)
            
            @CasePathable enum Delegate : Equatable {
                case failure(EquatableError)
            }
        }
        
        var body: some Reducer<EditLayoutFeature.State, Action> {
            Reduce { state, action in
                switch action {
                    case .start(let id):
                        state.isBusy = true
                        return loadLayout(&state, id:id)
                        
                    case .success(let layout):
                        state.layout = layout
                        state.isBusy = false
                        state.isDirty = false
                        
                        return .none
                        
                    case .delegate:
                        return .none
                }
            }
        }
        
        private func loadLayout(_ state: inout EditLayoutFeature.State, id:UUID) -> Effect<Action> {
            return .run { send in
                do {
                    let result = try await apiClient.layoutsAPI.fetchLevel(id: id)
                    
                    if let result = result as? Layout {
                        await send(.success(result))
                    }
                    else {
                        throw EditLayoutError.loadLayoutError
                    }
                }
                catch {
                    await send(.delegate(.failure(EquatableError(error))))
                }
            }
        }
    }
}
