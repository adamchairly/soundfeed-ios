import SwiftUI
import SwiftfulLoadingIndicators

struct SplashView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack() {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                
                Text("soundfeed")
                    .font(.title.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            
            LoadingIndicator()
            
            Spacer()
            
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    SplashView()
}
