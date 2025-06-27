import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

struct Settings: Equatable {
    @Shared(.appStorage("isEditMode")) var isEditMode: Bool = false

//    var darkModeEnabled: Bool
//    var notificationsEnabled: Bool
//    var textSize: TextSize
//    var username: String
}
