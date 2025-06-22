import SwiftUI

enum GameColors:Int {
    case empty, wrong, inWord, correctPosition, somewhere, cardBack, defaultText
    
    var background:Color {
        get {
            switch self {
            case .empty,.cardBack:
                return Color(UIColor.systemBackground)
            case .wrong:
                return Color(UIColor.lightGray)
            case .inWord:
                return .yellow
            case .correctPosition:
                return .green
            case .somewhere:
                return .orange
            case .defaultText:
                return Color(UIColor.label)
            }
        }
    }

    var foregroundColor:Color {
        get {
            switch self {
            case .empty,.cardBack:
                return .primary
            case .wrong:
                return .black
            case .inWord:
                return .green
            case .correctPosition:
                return .green
            case .somewhere:
                return .black
            case .defaultText:
                return .primary
            }
        }
    }
}

extension Color {
    static let correct = Color.green
    static let inWord = Color.orange
    static let wrong = Color(UIColor.label)
}
