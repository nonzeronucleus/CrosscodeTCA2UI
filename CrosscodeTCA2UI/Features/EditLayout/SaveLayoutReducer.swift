import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary
import Factory

@Reducer
struct SaveLayoutReducer {
    typealias State = EditLayoutFeature.State
    
    @Dependency(\.apiClient) var apiClient
    @Injected(\.uuid) var uuid
    
    @CasePathable
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
            case finished(Result<Void, Error>)
        }
        
        @CasePathable
        enum Delegate {
            case finished(Result<Void, Error>)
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .api(.start):
                    state.isBusy = true
//                    return .none
                    return .run { [state] send in
                        let result = await saveLayout(state)
                        
                        await send(.internal(.finished(result)))
                    }
                        
//                        switch result {
//                            case .success:
//                                await send(.internal(.finished(.success((layoutText, charIntMap)))))
//                                
//                            case .failure(let error):
//                                await send(.internal(.finished(.failure(error))))
//                        }
//                    }
                    
                case .internal(.finished(.success)):
                    state.isBusy = false
                    state.isDirty = false
                    
                    return .run { send in await send(.delegate(.finished(.success(())))) }
                    
                case .internal(.finished(.failure(let error))):
                    state.isBusy = false
                    return .run { send in await send(.delegate(.finished(.failure(error)))) }
                    
                case .delegate:
                    return .none
            }
        }
    }
    
    func depopulate(_ state: State) async -> Result<(String, String), Error> {
        guard let layout = state.layout else { return .failure(EditLayoutError.handlePopulationError("No layout loaded")) }
        
        do {
            guard let populatedLevel = layout.gridText else { throw EditLayoutError.handlePopulationError("No layout") }
            
            return try await .success(apiClient.layoutsAPI.depopulateCrossword(crosswordLayout: populatedLevel))
        } catch {
            return .failure(error)
        }
    }
    
    
    private func saveLayout(_ state: State) async -> Result<Void, Error> {
        guard let layout = state.layout else {
            return .failure(EditLayoutError.saveLayoutError("No layout found in save level"))
        }
        do {
            try await apiClient.layoutsAPI.saveLevel(level: layout)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}





//import ComposableArchitecture
//import Foundation
//import CrosscodeDataLibrary
//
//@Reducer
//struct SaveLayoutReducer {
//    typealias State = EditLayoutFeature.State
//    @Dependency(\.apiClient) var apiClient
//    
//    @CasePathable
//    enum Action {
//
//        case api(API)
//        case delegate(Delegate)
//
//        @CasePathable
//        enum API {
//            case start
//        }
//        
//        @CasePathable
//        enum Delegate {
//            case success
//            case failure(Error)
//        }
//    }
//    
//    var body: some Reducer<State, Action> {
//        Reduce { state, action in
//            switch action {
//                case let .api(apiAction):
//                    return handleAPIAction(&state, apiAction)
//                    
//                case .delegate:
//                    return .none
//            }
//        }
//    }
//}
//
//// MARK: - API
//extension SaveLayoutReducer {
//    func handleAPIAction(_ state: inout State, _ action: Action.API) -> Effect<Action> {
//        switch action {
//            case .start:
//                if !state.isDirty || state.isPopulated { // Don't bother trying to save something that hasn't changed, or if the grid's been populated
//                    return .run {  send in
//                        await send(.delegate(.success))
//                    }
//                }
//                state.isBusy = true
//                return saveLayout(&state)
//        }
//    }
//    
//    private func saveLayout(_ state: inout EditLayoutFeature.State) -> Effect<Action> {
//        guard let layout = state.layout else {
//            return .send(.delegate(.failure(EditLayoutError.saveLayoutError("No layout found in save level"))))
//        }
//
//        return .run { send in
//            do {
//                try await apiClient.layoutsAPI.saveLevel(level: layout)
//                await send(.delegate(.success))
//            } catch {
//                await send(.delegate(.failure(error)))
//            }
//        }
//    }
//}
//
