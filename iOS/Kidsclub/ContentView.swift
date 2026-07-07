import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editingItem: FeeItem?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.items) { item in
                        Button {
                            editingItem = item
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.childName)
                                    .font(Theme.bodyFont.weight(.semibold))
                                Text("\(item.activity)")
                                    .font(Theme.captionFont)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .accessibilityIdentifier("item_row_\(item.id.uuidString)")
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Kidsclub")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settings_gear_button")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("add_item_button")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddItemView { item in
                    store.add(item)
                }
            }
            .sheet(item: $editingItem) { item in
                EditItemView(item: item, onSave: { updated in
                    store.update(updated)
                }, onDelete: {
                    store.delete(item)
                })
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .tint(Theme.accent)
    }
}

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var childName: String = ""
    @State private var activity: String = ""
    @State private var amountText: String = ""
    @State private var dueDate: String = ""
    var onSave: (FeeItem) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("New Fee") {
                    TextField("Childname", text: $childName)
                        .accessibilityIdentifier("add_childName_field")
                    TextField("Activity", text: $activity)
                        .accessibilityIdentifier("add_activity_field")
                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("add_amount_field")
                    TextField("Duedate", text: $dueDate)
                        .accessibilityIdentifier("add_dueDate_field")
                }
            }
            .background(
                Color.clear.contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
            )
            .navigationTitle("Add Fee")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("add_cancel_button")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let item = FeeItem(
                        childName: childName,
                        activity: activity,
                        amount: Double(amountText) ?? 0,
                        dueDate: dueDate
                        )
                        onSave(item)
                        dismiss()
                    }
                    .accessibilityIdentifier("add_save_button")
                }
            }
        }
    }
}

struct EditItemView: View {
    @Environment(\.dismiss) private var dismiss
    @State var item: FeeItem
    var onSave: (FeeItem) -> Void
    var onDelete: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Fee") {
                    Text(item.childName)
                }
                Section {
                    Button("Delete", role: .destructive) {
                        onDelete()
                        dismiss()
                    }
                    .accessibilityIdentifier("edit_delete_button")
                }
            }
            .navigationTitle("Edit Fee")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .accessibilityIdentifier("edit_close_button")
                }
            }
        }
    }
}
