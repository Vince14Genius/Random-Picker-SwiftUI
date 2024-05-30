import SwiftUI

struct ItemsList: View {
    
    @StateObject private var state = RandomListState()
    @State private var newItemName = ""
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    state.beginCreatingItem()
                } label: {
                    Spacer()
                    Text(" ")
                    Image(systemName: "plus")
                    Text(" ")
                    Spacer()
                }
                .buttonStyle(.bordered)
                .keyboardShortcut("n", modifiers: [])
                
                Button {
                    state.showRandomPick()
                } label: {
                    Spacer()
                    Text("Pick Randomly")
                    Spacer()
                }
                .buttonStyle(.borderedProminent)
                .disabled(state.items.count <= 1)
                .keyboardShortcut(.return, modifiers: [])
            }
            .frame(maxWidth: 800)
            .padding()
            
            if state.items.isEmpty {
                Spacer()
                Group {
                    Text("No items yet.")
                        .font(.headline)
                    Text("Add items using the + button to pick from them randomly.")
                }
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                Spacer()
            } else {
                List {
                    ForEach(state.items, id: \.self) { item in
                        Text(item.name)
                    }
                    .onDelete { state.items.remove(atOffsets: $0) }
                }
            }
        }
        .navigationTitle("Items List")
        .toolbar {
            EditButton()
                .disabled(state.items.isEmpty)
        }
        .alert("New Item", isPresented: $state.isCreateItemAlertShown) {
            TextField(
                "Item Name",
                text: $newItemName, 
                prompt: Text("Name of the new item")
            )
            Button("Cancel", role: .cancel) {
                dismissCreateItemAlert()
            }
            Button("Create") {
                state.items.append(.init(name: newItemName))
                dismissCreateItemAlert()
            }
        }
        .sheet(isPresented: $state.isRandomPickAlertShown) {
            PickerView(state: state)
        }
    }
    
    private func dismissCreateItemAlert() {
        newItemName = ""
        state.isCreateItemAlertShown = false
    }
}

struct ItemsList_Previews: PreviewProvider {
    static var previews: some View {
        ItemsList()
    }
}
