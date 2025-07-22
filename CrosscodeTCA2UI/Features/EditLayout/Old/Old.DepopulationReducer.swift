//import ComposableArchitecture
//import Foundation
//import CrosscodeDataLibrary
//import Factory
//
//
//@Reducer
//struct DepopulationReducer {
//    typealias State = EditLayoutFeature.State
//    @Injected(\.uuid) var uuid
//    
//    @CasePathable
//    enum Action: Equatable {
//        case api(API)
//        case `internal`(Internal)
//        case delegate(Delegate)
//
//        @CasePathable
//        enum API : Equatable {
//            case start
//        }
//        
//        @CasePathable
//        enum Internal: Equatable {
//            case success(String, String)
//        }
//            
//        
//        @CasePathable
//        enum Delegate : Equatable {
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
//                case let .internal(internalAction):
//                    return handleInternalAction(&state, internalAction)
//
//                case .delegate:
//                    return .none
//            }
//        }
//    }
//    
//    func handleDepopulation(_ state: inout State) -> Effect<Action> {
//        @Dependency(\.apiClient) var apiClient
//        do {
//            guard let layout = state.layout else { throw EditLayoutError.handlePopulationError("No layout loaded") }
//            
//            return .run { send in
//                guard let populatedLevel = layout.gridText else { throw EditLayoutError.handlePopulationError("No populated layout")}
//                let (updatedCrossword, charIntMap) = try await apiClient.layoutsAPI.depopulateCrossword(crosswordLayout: populatedLevel)
//                
//                await send(.internal(.success(updatedCrossword, charIntMap)))
//            }
//        }
//        catch {
//            return .run {send in await send(.delegate(.failure(EquatableError(error))))}
//        }
//    }
//}
//
//extension DepopulationReducer {
//    func handleAPIAction(_ state: inout State, _ action: Action.API) -> Effect<Action> {
//        switch action {
//            case .start:
//                return handleDepopulation(&state)
//        }
//    }
//
//    
//    // MARK: Internal Actions
//    func handleInternalAction(_ state: inout State, _ action: Action.Internal) -> Effect<Action> {
//        switch action {
//            case .success(let layoutText, _):
//                state.layout?.crossword = Crossword(initString:layoutText)
//                state.layout?.letterMap = nil
//                state.isPopulated = false
//                return .none
//        }
//    }
//}
