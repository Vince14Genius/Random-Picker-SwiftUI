import SwiftUI

struct PickerView: View {
    @StateObject var state: RandomListState
    
    @State private var animating = true
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(animating ? "Picking randomly..." : "Randomly picked:")
                    .font(.title)
                ScrollerView(animating: $animating, items: state.items.map { .init(title: $0.name) })
            }
            .padding()
            .toolbar {
                Button("Done") {
                    state.isRandomPickAlertShown = false
                }
                .disabled(animating)
            }
        }
        .task {
            do {
                let randomDuration = ScrollerView.scrollDurationPerItem * Int.random(in: 0 ..< state.items.count)
                try await Task.sleep(for: ScrollerView.scrollDurationPerItem * state.items.count * 4 + .seconds(2) + randomDuration)
            } catch {
                return
            }
            await MainActor.run {
                animating = false
            }
        }
        .interactiveDismissDisabled()
    }
}
