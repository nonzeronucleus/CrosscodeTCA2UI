import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary
import Factory

@Reducer
struct DepopulationReducer {
    enum Action: Equatable {
        case buttonClicked
        case success(String, String)
        case delegate(Delegate)
        
        enum Delegate : Equatable {
            case failure(EquatableError)
        }
    }
    
    var body: some Reducer<EditLayoutFeature.State, Action> {
        Reduce { state, action in
            switch action {
                case .buttonClicked:
                    return handleDepopulation(&state)
                case .success(let layoutText, _):
                    @Injected(\.uuid) var uuid

                    state.layout?.crossword = Crossword(initString:layoutText)
                    state.layout?.letterMap = nil
                    state.isPopulated = false
                    return .none
                case .delegate:
                    return .none
            }
        }
    }
    
    func handleDepopulation(_ state: inout EditLayoutFeature.State) -> Effect<Action> {
        @Dependency(\.apiClient) var apiClient
        do {
            guard let layout = state.layout else { throw EditLayoutError.handlePopulationError("No layout loaded") }
            
            return .run { send in
                guard let populatedLevel = layout.gridText else { throw EditLayoutError.handlePopulationError("No populated layout")}
                let (updatedCrossword, charIntMap) = try await apiClient.layoutsAPI.depopulateCrossword(crosswordLayout: populatedLevel)
                
                await send(.success(updatedCrossword, charIntMap))
            }
        }
        catch {
            return .run {send in await send(.delegate(.failure(EquatableError(error))))}
        }
    }
}
