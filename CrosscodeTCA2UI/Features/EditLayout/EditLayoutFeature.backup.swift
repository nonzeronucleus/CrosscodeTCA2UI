//import ComposableArchitecture
//import Foundation
//import CrosscodeDataLibrary
//
//@Reducer
//struct EditLayoutFeature {
//    // MARK: - Reducer
//    @Dependency(\.uuid) var uuid
//    @Dependency(\.dismiss) var dismiss
//    @Dependency(\.isPresented) var isPresented
//    @Dependency(\.apiClient) var apiClient
//
//    @ObservableState
//    struct State: Equatable {
//        var layoutID: UUID
//        var layout: Layout?
//        var isBusy = false
//        var isDirty = false
//        var isPopulated: Bool = false
//        var isExiting: Bool = false
//        var error: EquatableError?
//    }
//
//    enum Action: Equatable {
//        case pageLoaded
//        case backButtonTapped
//        case populateButtonTapped
//        case depopulateButtonTapped
//        case populated(String, String)
//        case depopulated(String)
//        case saveSuccess
//        case layoutLoaded(Layout)
//        
//        case cellClicked(UUID)
//        case failure(EquatableError)
//    }
//    
//    var body: some Reducer<State, Action> {
//        Reduce { state, action in
//            switch action {
//                case .backButtonTapped:
//                    guard isPresented else { return .none }
//                    
//                    if !state.isDirty { // Don't bother trying to save something that hasn't changed
//                        return .run { _ in await dismiss() }
//                    }
//                    
//                    state.isExiting = true
//                    return handleSave(&state)
//                    
//                case .pageLoaded:
//                    state.isDirty = false
//                    return loadLayout(&state)
//                    
//                case .saveSuccess:
//                    state.isDirty = false
//                    state.isBusy = false
//                    if state.isExiting {
//                        return .run { _ in await dismiss() }
//                    }
//                    return .none
//                    
//                case .layoutLoaded(let layout):
//                    state.layout = layout
//                    state.isBusy = false
//                    state.isDirty = false
//                    return .none
//                    
//                case .cellClicked(let id):
//                    return handleToggle(&state, id: id)
//                    
//                case .populateButtonTapped:
//                    return handlePopulation(&state)
//                    
//                case .depopulateButtonTapped:
//                    return handleDepopulation(&state)
//
//                    
//                case .populated(let layoutText, let charIntMap):
//                    state.layout?.crossword = Crossword(initString:layoutText)
//                    state.layout?.letterMap = CharacterIntMap(from: charIntMap)
//                    
//                    state.isPopulated = true
//                    state.isBusy = false
//                    state.isDirty = true
//
//                    return .none
//                    
//                case .depopulated(let layoutText):
//                    state.layout?.crossword = Crossword(initString:layoutText)
//                    state.layout?.letterMap = nil
//                    
//                    state.isPopulated = false
//                    state.isBusy = false
//                    state.isDirty = false
//
//                    return .none
//
//                    
//                case .failure(let error):
//                    return handleError(&state, error: error)
//            }
//        }
//    }
//}
//
//// MARK: - Loading
//extension EditLayoutFeature {
//    private func loadLayout(_ state: inout EditLayoutFeature.State) -> Effect<Action> {
//        let id = state.layoutID
//        return .run { send in
//            do {
//                let result = try await apiClient.layoutsAPI.fetchLevel(id: id)
//                
//                if let result = result as? Layout {
//                    await send(.layoutLoaded(result))
//                }
//                else {
//                    await send(.failure(EquatableError(EditLayoutError.loadLayoutError)))
//                }
//            }
//            catch {
//                await send(.failure(EquatableError(error)))
//            }
//        }
//    }
//}
//
//// MARK: - Saving
//extension EditLayoutFeature {
//    private func handleSave(_ state: inout State) -> Effect<Action> {
//        state.isBusy = true
//        if state.isPopulated {
//            return addLevel(&state)
//        }
//        else {
//            return saveLayout(&state)
//        }
//    }
//    
//    private func saveLayout(_ state: inout EditLayoutFeature.State) -> Effect<Action> {
//
//        let layout = state.layout
//        return .run {  send in
//            do {
//                guard let layout = layout else { throw EditLayoutError.saveLayoutError("No layout found in save level") }
//                try await apiClient.layoutsAPI.saveLevel(level: layout)
//                await send(.saveSuccess)
//            }
//            catch {
//                await send(.failure(EquatableError(error)))
//            }
//        }
//    }
//    
//    private func addLevel(_ state: inout EditLayoutFeature.State) -> Effect<Action> {
//        let layout = state.layout
//        
//        return .run {  send in
//            do {
//                guard let layout = layout else { throw EquatableError(EditLayoutError.saveLayoutError("No layout found in add level")) }
//                
//                try await apiClient.gameLevelsAPI.addNewLevel(layout: layout)
//                
//                await send(.saveSuccess)
//            }
//            catch {
//                await send(.failure(EquatableError(error)))
//            }
//        }
//    }
//}
//
//// MARK; - Toggle Cell
//extension EditLayoutFeature {
//    func handleToggle(_ state: inout EditLayoutFeature.State, id: UUID) -> Effect<Action> {
//        guard !state.isPopulated else {return .none} // If the layout has been populated with words, don't allow the cell to be clicked on
//        guard let level = state.layout else {return .run { send in await send(.failure(EquatableError(EditLayoutCellReducerError.layoutNil)))}}
//        guard let location = level.crossword.locationOfElement(byID: id) else {return .run { send in await send(.failure(EquatableError(EditLayoutCellReducerError.couldNotFindCell(id))))}
//        }
//        
//        // Calculate opposite position first
//        let opposite = Pos(
//            row: level.crossword.columns - 1 - location.row,
//            column: level.crossword.rows - 1 - location.column
//        )
//        
//        // Minimize update calls
//        var crossword = level.crossword
//        crossword.updateElement(byPos: location) { $0.toggle() }
//        if opposite != location {
//            crossword.updateElement(byPos: opposite) { $0.toggle() }
//        }
//        
//        state.layout = level.withUpdatedCrossword(crossword)
//        state.isDirty = true
//
//        return .none
//    }
//}
//
//// MARK: - Population
//extension EditLayoutFeature {
//    func handlePopulation(_ state: inout EditLayoutFeature.State) -> Effect<Action> {
//        state.isBusy = true
//        do {
//            guard let layout = state.layout else { throw EditLayoutError.handlePopulationError("No layout loaded") }
//            
//            return .run { send in
//                guard let populatedLevel = layout.gridText else { throw EditLayoutError.handlePopulationError("No populated layout")}
//                let (updatedCrossword, charIntMap) = try await apiClient.layoutsAPI.populateCrossword(crosswordLayout: populatedLevel)
//                
//                await send(.populated(updatedCrossword, charIntMap))
//            }
//        }
//        catch {
//            return .run {send in await send(.failure(EquatableError(error)))}
//        }
//    }
//    
//    func handleDepopulation(_ state: inout EditLayoutFeature.State) -> Effect<Action> {
//        do {
//            guard let layout = state.layout else { throw EditLayoutError.handlePopulationError("No layout loaded") }
//            
//            return .run { send in
//                guard let populatedLevel = layout.gridText else { throw EditLayoutError.handlePopulationError("No populated layout")}
//                let (updatedCrossword, _) = try await apiClient.layoutsAPI.depopulateCrossword(crosswordLayout: populatedLevel)
//                
//                await send(.depopulated(updatedCrossword))
//            }
//        }
//        catch {
//            return .run {send in await send(.failure(EquatableError(error)))}
//        }
//    }
//}
//
//
//// MARK: - Error handling
//extension EditLayoutFeature {
//    func handleError(_ state: inout State, error: EquatableError) -> Effect<Action> {
//        state.error = error
//        state.isBusy = false
//        debugPrint("Error \(error.localizedDescription)")
//        return .none
//    }
//}
//
//
//
//public enum EditLayoutError: Error {
//    case loadLayoutError
//    case saveLayoutError(_ text:String)
//    case handlePopulationError(_ text:String)
//}
//
//public enum EditLayoutCellReducerError: Error {
//    case layoutNil
//    case couldNotFindCell(UUID)
//}
//
