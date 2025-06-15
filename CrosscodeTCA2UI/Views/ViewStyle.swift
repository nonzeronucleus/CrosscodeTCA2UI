import Dependencies
import UIKit
import CoreFoundation

struct ViewStyle {
    let buttonHeight: CGFloat
    let buttonSpacing: CGFloat
    let cornerRadius: CGFloat
}

extension ViewStyle: DependencyKey {
    static let liveValue = Self(
        buttonHeight:UIDevice.current.userInterfaceIdiom == .pad ? 60 : 50,
        buttonSpacing: UIDevice.current.userInterfaceIdiom == .pad ? 50 : 20,
            cornerRadius: UIDevice.current.userInterfaceIdiom == .pad ? 2 : 1
    )
}
      
