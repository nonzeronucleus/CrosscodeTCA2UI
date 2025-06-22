import SwiftUI

struct CompletedPopover: View {
    let close: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Button(action: close) {
                    Image(systemName: "xmark")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.gray.opacity(0.8))
                        .clipShape(Circle())
                }
                .padding()
                
                Spacer()
            }
            
            Text("Completed")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
//                .padding()
            
            Spacer()
        }
        .frame(width: 200, height: 120)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

#Preview {
    CompletedPopover(close: {})
}
