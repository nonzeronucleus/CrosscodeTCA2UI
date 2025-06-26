import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct SaveLayoutReducer {
    @Dependency(\.apiClient) var apiClient
    
    enum Action: Equatable {
        case start
        case delegate(Delegate)
        
        enum Delegate : Equatable {
            case success
            case failure(EquatableError)
        }
    }
    
    var body: some Reducer<EditLayoutFeature.State, Action> {
      
        Reduce { state, action in
            switch action {
                case .start:
                    if !state.isDirty { // Don't bother trying to save something that hasn't changed
                        return .run {  send in
                            await send(.delegate(.success))
                        }
                    }
                    state.isBusy = true
                    if state.isPopulated {
                        return addLevel(&state)
                    }
                    return saveLayout(&state)
                    
                case .delegate:
                    return .none
            }
        }
    }
    
    private func saveLayout(_ state: inout EditLayoutFeature.State) -> Effect<Action> {
        guard let layout = state.layout else {
            return .send(.delegate(.failure(EquatableError(EditLayoutError.saveLayoutError("No layout found in save level")))))
        }

        return .run { send in
            do {
                try await apiClient.layoutsAPI.saveLevel(level: layout)
                await send(.delegate(.success))
            } catch {
                await send(.delegate(.failure(EquatableError(error))))
            }
        }
    }
    
    
//    private func saveLayout(_ state: inout EditLayoutFeature.State) -> Effect<Action> {
//        let layout = state.layout
//        
//        return .run {  send in
//            do {
//                guard let layout = layout else { throw EditLayoutError.saveLayoutError("No layout found in save level") }
//                
//                try await apiClient.layoutsAPI.saveLevel(level: layout)
//                
//                await send(.delegate(.success))
//            }
//            catch {
//                await send(.delegate(.failure(EquatableError(error))))
//            }
//        }
//    }
    
    private func addLevel(_ state: inout EditLayoutFeature.State) -> Effect<Action> {
        let layout = state.layout
        
        return .run {  send in
            do {
                guard let layout = layout else { throw EquatableError(EditLayoutError.saveLayoutError("No layout found in add level")) }
                
                try await apiClient.gameLevelsAPI.addNewLevel(layout: layout)
                
                await send(.delegate(.success))
            }
            catch {
                await send(.delegate(.failure(EquatableError(error))))
            }
        }
    }
}
