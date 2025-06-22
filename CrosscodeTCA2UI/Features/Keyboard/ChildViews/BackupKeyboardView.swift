//import SwiftUI
////import ReSwift
//
//
//let maxKeysPerRow = 10.0
//
//fileprivate struct KeyboardRow: View {
//    private let spacing = 2.0
//    private var letters:[Character]
//    private let wideActionButtons: Bool
//    
//    let onDeleteChar: () -> Void
//    let onSubmit: () -> Void
//    let onLetterPressed: (Character) -> Void
//
////    private let attemptedLetters:AttemptedLetters
////    private let controller:KeyboardController
//
//    init(_ letters:String,
////         attemptedLetters:AttemptedLetters,
////         controller:KeyboardController,
//         wideActionButtons:Bool
//    ){
//        self.letters = [Character](letters)
////        self.attemptedLetters = attemptedLetters
//        self.wideActionButtons = wideActionButtons
////        self.controller = controller
//    }
//    
//    func getColorForChar(char: Character) -> Color {
////        if let attempt = attemptedLetters.getStatus(char) {
////            return (attempt == .POSSIBLE)
////            ? .orange
////            : .gray
////        }
//        return Color(UIColor.systemBackground)
//    }
//    
//    var body: some View {
//        GeometryReader { geo in
//            let actionButtonWidth = wideActionButtons ? geo.size.width/7 : abs((geo.size.width/maxKeysPerRow)-spacing)
//            
//            HStack (spacing:spacing){
//                Spacer(minLength: 0)
//                ForEach(letters, id:\.self) { letter in
//                    let letterToShow = letter
//                    
//                    switch(letter) {
//                    case "⌫":
//                        ActionKeyView("⌫",
//                                      onClick: onDeleteChar,
//                                  fontScale:0.6)
//                            .frame(width:actionButtonWidth, height: geo.size.height, alignment:.center)
//                    case "⏎":
//                            ActionKeyView("⏎",
//                                  onClick: onSubmit,
//                                  fontScale:0.5)
//                            .frame(width: actionButtonWidth, height: geo.size.height, alignment:.center)
//                    default:
//                            ActionKeyView(letterToShow,
//                                  color: getColorForChar(char: letterToShow),
//                                          onClick: {onLetterPressed(letterToShow)}
//                        )
//                            .frame(width: abs((geo.size.width/maxKeysPerRow)-spacing), height: geo.size.height, alignment:.center)
//                    }
//                }
//                Spacer(minLength: 0)
//            }
//        }
//    }
//}
//
//
//
//
//fileprivate struct SharedKeyboard: View {
////    private let controller:KeyboardController
////    private let attemptedLetters:AttemptedLetters
//
//    private var keys:[String]
//    private let wideActionButtons: Bool
//    
//    init(keys:[String]/*, attemptedLetters:AttemptedLetters, controller:KeyboardController*/, wideActionButtons: Bool = true) {
//        self.keys = keys
//        self.wideActionButtons = wideActionButtons
////        self.controller = controller
////        self.attemptedLetters = attemptedLetters
//    }
//    
//    var body: some View {
//        HStack {
//            Spacer(minLength: 0)
//            GeometryReader { geo in
//                let keyHeight = geo.size.width/maxKeysPerRow
//                    VStack {
//                        Spacer()
//                        ForEach(keys, id:\.self) { letterRow in
//                            KeyboardRow(letterRow,
////                                        attemptedLetters: attemptedLetters,
////                                        controller: controller,
//                                        wideActionButtons: wideActionButtons
//                            )
//                                .frame(width: geo.size.width, height: keyHeight, alignment:
//                                            .center)
//                    }
//                }
//                .padding(.bottom, keyHeight)
//            }
//            .frame(alignment: .bottom)
//            Spacer(minLength: 0)
//        }
//        .padding(6)
//    }
//}
//
//
//fileprivate struct LetterKeyboardImpl: View {
//    private var letters = [
//        "QWERTYUIOP",
//        "ASDFGHJKL",
//        "⌫ZXCVBNM⏎"
//    ]
//    
//    private let controller:KeyboardController
////    private let attemptedLetters:AttemptedLetters
//
//    init(/*attemptedLetters:AttemptedLetters, controller:KeyboardController*/) {
////        self.controller = controller
////        self.attemptedLetters = attemptedLetters
//    }
//    
//    var body: some View {
//        SharedKeyboard(keys: letters/*, attemptedLetters: attemptedLetters, controller: controller*/)
//    }
//}
//
//protocol KeyboardController {
//    
//    func addChar(_ char:Character)
//    
//    func deleteChar()
//    
//    func submit()
//}
//
////fileprivate class GameKeyboardController: KeyboardController {
////    private let state:ObservableState<AppState>
////
////    init(state:ObservableState<AppState>) {
////        self.state = state
////    }
////
////    func addChar(_ char:Character) {
////        state.dispatch(AddCharacterAction(char: char))
////    }
////
////    func deleteChar() {
////        state.dispatch(DeleteCharacterAction())
////    }
////
////    func submit() {
////        state.dispatch(SubmitGuessAction())
////    }
////}
//
////fileprivate class TestKeyboardController: KeyboardController {
////    func addChar(_ char:Character) {
////    }
////
////    func deleteChar() {
////    }
////
////    func submit() {
////    }
////}
//
//
////struct LetterKeyboard: View {
////    @EnvironmentObject private var state:ObservableState<AppState>
////
////    var body: some View {
////        LetterKeyboardImpl(attemptedLetters: state.current.attemptedLetters, controller: GameKeyboardController(state: state))
////    }
////}
////
////struct NumberPad: View {
////    @EnvironmentObject private var state:ObservableState<AppState>
////
////    var body: some View {
////        NumberPadImpl(attemptedLetters: state.current.attemptedLetters, controller: GameKeyboardController(state: state))
////    }
////}
//
//
//
////struct Keyboard: View {
//////    @EnvironmentObject private var state:ObservableState<AppState>
////
////    var body: some View {
////        state.current.currentGameMode == .letters
////            ? AnyView(LetterKeyboard())
////            : AnyView(NumberPad())
////    }
////}
////
//
////struct Keyboard_Previews: PreviewProvider {
////    static let attemptedLetters = AttemptedLetters(attempts: ["A":.POSSIBLE, "B":.NOT_IN_WORD] )
////    static let attemptedNumbers = AttemptedLetters(attempts: ["1":.POSSIBLE, "2":.NOT_IN_WORD] )
////
////    static var previews: some View {
////        NumberPadImpl(attemptedLetters: attemptedNumbers, controller: TestKeyboardController())
////            .environmentObject( createStore())
////
////        LetterKeyboardImpl(attemptedLetters: attemptedLetters, controller: TestKeyboardController())
////            .environmentObject( createStore())
////    }
////}
////