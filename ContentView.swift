import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "shield.slash")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
            Text("MessageBlocker")
                .font(.title2.bold())
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
