import SwiftUI

let maxKeysPerRow = 10.0

struct LetterKeyboardView: View {
    private let lettersNoEnter = [
        "QWERTYUIOP",
        "ASDFGHJKL",
        "ZXCVBNM⌫"
    ]
    private let enterLetter = "⏎"
    
    private let onLetterPressed: (Character) -> Void
    private let onDeletePressed: () -> Void
    private let onEnterPressed: () -> Void
    private let showEnter: Bool
    private let usedLetters: Set<Character>
    
    init(onLetterPressed: @escaping (Character) -> Void,
         onDeletePressed: @escaping () -> Void = {},
         showEnter: Bool = false,
         onEnterPressed: @escaping () -> Void = {},
         usedLetters: Set<Character>
    ) {
        self.onEnterPressed = onEnterPressed
        self.onLetterPressed = onLetterPressed
        self.onDeletePressed = onDeletePressed
        self.showEnter = showEnter
        self.usedLetters = usedLetters
    }
    
    private func getLetters() -> [String] {
        var letters = lettersNoEnter
        if showEnter {
            letters[letters.count-1] += enterLetter
        }
        return letters
    }
    
    var body: some View {
        let vSpacing: CGFloat = 8
        
        GeometryReader { geometry in
            let height = (geometry.size.height - 3 * vSpacing)/3
            VStack(spacing: vSpacing) {
                ForEach(getLetters(), id: \.self) { row in
                    HStack(spacing: 4) {
                        ForEach(Array(row), id: \.self) { char in
                            if char == "⌫" || char == "⏎" {
                                ActionKeyView(symbol: String(char),
                                              onClick: char == "⌫" ? onDeletePressed : onEnterPressed,
                                              fontScale: 0.6)
                                .frame(height: height)
                                .frame(maxWidth: .infinity)
                            } else {
                                LetterKeyView(letter: char,
                                              color: usedLetters.contains(char) ? .gray : Color(UIColor.systemBackground),
                                              onClick: { onLetterPressed(char) })
                                .frame(height: height)
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
            .padding(8)
            .background(Color.gray.opacity(0.5))
            .cornerRadius(4)
            .fixedSize(horizontal: false, vertical: true) // Critical for containment
        }
    }
}



#Preview("Enter") {
    LetterKeyboardView(onLetterPressed: {_ in }, onDeletePressed: {}, onEnterPressed: {}, usedLetters: [] )
        .padding(20)
}

#Preview("No Enter") {
    LetterKeyboardView(onLetterPressed: {_ in }, onDeletePressed: {}, showEnter: false, usedLetters: [])
        .padding(20)
}

