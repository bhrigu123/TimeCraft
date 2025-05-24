import SwiftUI

struct StatsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("Coming Soon!")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Statistics and insights are on the way.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                if let url = URL(string: "https://github.com/bhrigu123/TimeCraft/issues/1") {
                    NSWorkspace.shared.open(url)
                }
            }) {
                HStack {
                    Text("👍🏼 this feature on GitHub")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .buttonStyle(PlainButtonStyle())
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            .onHover { hovering in
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
        .frame(maxWidth: CGFloat.infinity, maxHeight: CGFloat.infinity)
    }
}

#Preview {
    StatsView()
} 