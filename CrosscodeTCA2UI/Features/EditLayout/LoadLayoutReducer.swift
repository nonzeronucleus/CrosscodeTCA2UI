import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct LoadLayoutReducer {
    @Dependency(\.apiClient) var apiClient
    
    enum Action: Equatable {
        case start(UUID)
        case success(Layout)
        case failure(EquatableError)
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

                case .failure(let error):
                    debugPrint(error)
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
                    await send(.failure(EquatableError(EditLayoutError.loadLayoutError)))
                }
            }
            catch {
                await send(.failure(EquatableError(error)))
            }
        }
    }
}
