import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct SaveLayoutReducer {
    @Dependency(\.apiClient) var apiClient
    
    enum Action: Equatable {
        case start
        case success
        case failure(EquatableError)
    }
    
    var body: some Reducer<EditLayoutFeature.State, Action> {
        Reduce { state, action in
            switch action {
                case .start:
                    state.isBusy = true
                    return saveLayout(&state)
                    
                case .success:
                    state.isBusy = false
                    return .none
                    
                case .failure(let error):
                    debugPrint(error)
                    return .none
            }
        }
    }
    
    private func saveLayout(_ state: inout EditLayoutFeature.State) -> Effect<Action> {
        guard let layout = state.layout else {
            return .run { send in
                await send (.failure(EquatableError(EditLayoutError.saveLayoutError)))
            }
        }
        
        return .run {  send in
            do {
                
                try await apiClient.layoutsAPI.saveLevel(level: layout)
                
                await send(.success)
            }
            catch {
                await send(.failure(EquatableError(error)))
            }
        }
        
    }
}
