import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary
import Factory

@Reducer
struct PopulationReducer {
    enum Action: Equatable {
        case buttonClicked
        case success(String, String)
        case failure(EquatableError)
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

                    return .none
                case .failure(let error):
                    debugPrint(error)
                    return .none
            }
        }
    }
    
    func handlePopulation(_ state: inout EditLayoutFeature.State) -> Effect<Action> {
        @Dependency(\.apiClient) var apiClient
        do {
            guard let layout = state.layout else { throw EditLayoutError.handlePopulationError("No layout loaded") }
            
            return .run { send in
                guard let populatedLevel = layout.gridText else { throw EditLayoutError.handlePopulationError("No populated layout")}
                let (updatedCrossword, charIntMap) = try await apiClient.layoutsAPI.populateCrossword(crosswordLayout: populatedLevel)
                
                await send(.success(updatedCrossword, charIntMap))
            }
        }
        catch {
            return .run {send in await send(.failure(EquatableError(error)))}
        }
    }
}
