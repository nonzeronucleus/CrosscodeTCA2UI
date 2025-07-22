import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary
import Factory

//@Reducer
//struct PopulationReducer2 {
//    typealias State = EditLayoutFeature.State
//    
//    @Dependency(\.apiClient) var apiClient
//    @Injected(\.uuid) var uuid
//    
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
//            case cancel
//        }
//        
//        @CasePathable
//        enum Internal: Equatable {
//            case taskCompleted(TaskResult<CompletionPayload>)
//        }
//        
//        @CasePathable
//        enum Delegate : Equatable {
//            case failure(EquatableError)
//        }
//        
//        struct CompletionPayload: Equatable {
//            let updatedCrossword: String
//            let charIntMap: String
//            var isCancelled: Bool = false
//            
//            static func success(_ updatedCrossword: String, _ charIntMap: String) -> Self {
//                CompletionPayload(updatedCrossword: updatedCrossword, charIntMap: charIntMap)
//            }
//            
//            static let cancelled = CompletionPayload(
//                updatedCrossword: "",
//                charIntMap: "",
//                isCancelled: true
//            )
//        }
//    }
//}




import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary
import Factory

@Reducer
struct PopulationReducer {
    typealias State = EditLayoutFeature.State

    @Dependency(\.apiClient) var apiClient
    @Injected(\.uuid) var uuid


    @CasePathable
    enum Action {
        case api(API)
        case `internal`(Internal)
        case delegate(Delegate)

        @CasePathable
        enum API  {
            case start
            case cancel
        }
        
        @CasePathable
        enum Internal {
            case cancelled
            case success(String, String)
        }
        
        @CasePathable
        enum Delegate  {
            case failure(Error)
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case let .api(apiAction):
                    return handleAPIAction(&state, apiAction)
                    
                case let .internal(internalAction):
                    return handleInternalAction(&state, internalAction)

                case .delegate:
                    return .none
            }
        }
    }
    
    func handlePopulation(_ state: inout State) -> Effect<Action> {
        do {
            state.isBusy = true
            guard let layout = state.layout else {
                throw EditLayoutError.handlePopulationError("No layout loaded")
            }
            
            return .run { send in
                do {
                    guard let populatedLevel = layout.gridText else {
                        throw EditLayoutError.handlePopulationError("No populated layout")
                    }

                    let (updatedCrossword, charIntMap) = try await apiClient.layoutsAPI.populateCrossword(crosswordLayout: populatedLevel)

                    await send(.internal(.success(updatedCrossword, charIntMap)))
                } catch {
                    await send(.delegate(.failure(error)))
                }
            }
        }
        catch {
            return .run {send in await send(.delegate(.failure(error)))}
        }
    }
    
    func handlePopulationCancel(_ state: inout State) -> Effect<Action> {
        return .run { send in
            do {
                await apiClient.layoutsAPI.cancelPopulation()
                await send(.internal(.cancelled))
            }
        }
    }
}

extension PopulationReducer {
    func handleAPIAction(_ state: inout State, _ action: Action.API) -> Effect<Action> {
        switch action {
            case .start:
                return handlePopulation(&state)
            case .cancel:
                return handlePopulationCancel(&state)
        }
    }

    
    // MARK: Internal Actions
    func handleInternalAction(_ state: inout State, _ action: Action.Internal) -> Effect<Action> {
        switch action {
            case .success(let layoutText, let charIntMap):
                @Injected(\.uuid) var uuid

                state.layout?.crossword = Crossword(initString:layoutText)
                state.layout?.letterMap = CharacterIntMap(from: charIntMap)
                state.isPopulated = true
                state.isDirty = true
                state.isBusy = false

                return .none

            case .cancelled:
                state.isBusy = false
                return .none
        }
    }
}


