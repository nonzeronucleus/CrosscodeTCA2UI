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
//    enum Action: Equatable {
//
//        case api(API)
//        case delegate(Delegate)
//
//        @CasePathable
//        enum API: Equatable {
//            case start
//        }
//        
//        @CasePathable
//        enum Delegate : Equatable {
//            case success
//            case failure(EquatableError)
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
//            return .send(.delegate(.failure(EquatableError(EditLayoutError.saveLayoutError("No layout found in save level")))))
//        }
//
//        return .run { send in
//            do {
//                try await apiClient.layoutsAPI.saveLevel(level: layout)
//                await send(.delegate(.success))
//            } catch {
//                await send(.delegate(.failure(EquatableError(error))))
//            }
//        }
//    }
//}
//
