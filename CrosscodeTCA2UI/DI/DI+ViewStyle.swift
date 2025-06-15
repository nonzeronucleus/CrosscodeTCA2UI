import Dependencies
import CoreFoundation

extension DependencyValues {
    var viewStyle: ViewStyle {
        get { self[ViewStyle.self] }
        set { self[ViewStyle.self] = newValue }
    }
}
