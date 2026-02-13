import SwiftUI

struct MonthSectionHeaderView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title3.weight(.bold))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
    }
}

#Preview {
    MonthSectionHeaderView(title: "February 2026")
}
