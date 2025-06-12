import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct EditLayoutFeature {
    @Dependency(\.uuid) var uuid
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.isPresented) var isPresented

    @ObservableState
    struct State: Equatable {
        var layoutID: UUID
        var layout: Layout?
        var isBusy = false
        var isPopulated: Bool = false
        var debug: String?
        var error: EquatableError?
    }

    enum Action: Equatable {
        case pageLoaded
        case loadLayout(LoadLayout)
        case backButtonTapped
        case failure(EquatableError)
        case toggle(UUID)

        enum LoadLayout: Equatable {
            case start(UUID)
            case success(Layout)
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .backButtonTapped:
                    if isPresented {
                        return .run { _ in await dismiss() }
                    } else {
                        return .none
                    }
                case .pageLoaded:
                    return .send(.loadLayout(.start(state.layoutID)))
                case .loadLayout(let subAction):
                    return handleLoadLayout(&state, action: subAction)
                case .failure(let error):
                    state.error = error
                    state.isBusy = false
                    return .none

                case .toggle(let id):
                    return handleToggle(&state, id: id)
            }
        }
    }
}


extension EditLayoutFeature {
    private func handleLoadLayout(_ state: inout State, action:Action.LoadLayout) -> Effect<Action> {
        switch action {
            case .start(let id):
                state.isBusy = true
                return loadLayout(&state, id:id)
                
            case .success(let layout):
                state.layout = layout
                state.isBusy = false
                return .none
        }
    }
    
    private func loadLayout(_ state: inout State, id:UUID) -> Effect<Action> {
        @Dependency(\.apiClient) var apiClient
        
        return .run { send in
            do {
                let result = try await apiClient.layoutsAPI.fetchLevel(id: id)
                
                if let result = result as? Layout {
                    await send(.loadLayout(.success(result)))
                }
                else {
                    await send(.failure(EquatableError(EditLayoutError())))
                }
            }
            catch {
                await send(.failure(EquatableError(error)))
            }
        }
    }
}


//func handleToggle(_ state: inout EditLayoutFeature.State, id:UUID) -> Effect<EditLayoutFeature.Action> {
//    if state.isPopulated { return .none } // Don't allow the squares to be clicked while the grid's been populated
//
//    guard var level = state.layout else { return .none }
//
//    if let location = level.crossword.locationOfElement(byID: id ) {
//        level.crossword.updateElement(byPos: location) { cell in
//            cell.toggle()
//        }
//        let opposite = Pos(row: level.crossword.columns - 1 - location.row, column: level.crossword.rows - 1 - location.column)
//        
//        if opposite != location {
//            level.crossword.updateElement(byPos: opposite) { cell in
//                cell.toggle()
//            }
//        }
//    }
//    
//    state.layout = level
//    
//    return .none
//}

func handleToggle(_ state: inout EditLayoutFeature.State, id: UUID) -> Effect<EditLayoutFeature.Action> {
    guard !state.isPopulated, let level = state.layout,
          let location = level.crossword.locationOfElement(byID: id) else {
        return .none
    }
    
    // Calculate opposite position first
    let opposite = Pos(
        row: level.crossword.columns - 1 - location.row,
        column: level.crossword.rows - 1 - location.column
    )
    
    // Minimize update calls
    var crossword = level.crossword
    crossword.updateElement(byPos: location) { $0.toggle() }
    if opposite != location {
        crossword.updateElement(byPos: opposite) { $0.toggle() }
    }
    
    state.layout = level.withUpdatedCrossword(crossword)
    state.debug = state.layout?.gridText
    return .none
}

class EditLayoutError: Error {
    let message: String = "Something went wrong"
}







//@Reducer
//struct ToggleReducer {
//    var body: some Reducer<State, Action> {
//
//
//}


//
//func toggleReducer(_ state: inout EditLayoutFeature.State, id:UUID) -> Effect<EditLayoutFeature.Action> {
////    if state?.populationState != .unpopulated { return } // Don't allow the squares to be clicked while the grid's been populated
//
////    var level = state!.level
////    let selectedCell = action.payload
////
////    if let selectedCell {
////        if let location = level.crossword.locationOfElement(byID: selectedCell ) {
////            level.crossword.updateElement(byPos: location) { cell in
////                cell.toggle()
////            }
////            let opposite = Pos(row: level.crossword.columns - 1 - location.row, column: level.crossword.rows - 1 - location.column)
////
////            if opposite != location {
////                level.crossword.updateElement(byPos: opposite) { cell in
////                    cell.toggle()
////                }
////            }
////        }
////    }
////
////    state!.level = level
////    state!.selectedCell = selectedCell
////    state!.populationState = .unpopulated
////    state!.saveState = .dirty
//
//    return .none
//
////    DispatchQueue.main.async {
////        store.dispatch( LayoutEditActions.Cell.select(action.payload))
////    }
//}

//        enum Cell: ActionNamespace {
//            static var select = action("Select", payload: UUID?.self)
//        }
//
//        enum Populate: ActionNamespace {
//            static var start = action("Start", payload: Crossword.self)
//            static var success = action("Success", payload: PopulationPayload.self)
//            static var failure = action("Failure", payload: Error.self)
//        }
//
//        enum CancelPopulation: ActionNamespace {
//            static var start = action("Cancel", payload: Crossword.self)
//            static var success = action("Success")
//        }
//
//        enum Depopulate: ActionNamespace {
//            static var start = action("Cancel", payload: Crossword.self)
//            static var success = action("Success", payload: PopulationPayload.self)
//        }
//
//        enum SaveLayout: ActionNamespace {
//            static var start = action("Cancel", payload: LevelLayout.self)
//            static var success = action("Success")
//            static var failure = action("Failure", payload: Error.self)
//
//        }
//
//        enum ExportPopulatedLevel: ActionNamespace {
//            static var start = action("Cancel", payload: LevelLayout.self)
//            static var success = action("Success")
//            static var failure = action("Failure", payload: Error.self)
//        }
