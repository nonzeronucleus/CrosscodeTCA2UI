import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary
import Factory

@Reducer
struct PopulationReducer {
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
                    return handlePopulation(&state)
                case .success(let layoutText, let charIntMap):
                    @Injected(\.uuid) var uuid
                    
                    state.layout?.crossword = Crossword(initString:layoutText)
                    state.layout?.letterMap = CharacterIntMap(from: charIntMap)
                    state.isPopulated = true
                    state.isDirty = true
                    state.isBusy = false

                    return .none
                    
                case .delegate:
                    return .none
            }
        }
    }
    
    func handlePopulation(_ state: inout EditLayoutFeature.State) -> Effect<Action> {
        @Dependency(\.apiClient) var apiClient
        do {
            state.isBusy = true
            guard let layout = state.layout else { throw EditLayoutError.handlePopulationError("No layout loaded") }
            
            return .run { send in
                guard let populatedLevel = layout.gridText else { throw EditLayoutError.handlePopulationError("No populated layout")}
                let (updatedCrossword, charIntMap) = try await apiClient.layoutsAPI.populateCrossword(crosswordLayout: populatedLevel)
                
                await send(.success(updatedCrossword, charIntMap))
            }
        }
        catch {
            return .run {send in await send(.delegate(.failure(EquatableError(error))))}
        }
    }
}
