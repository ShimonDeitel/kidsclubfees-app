import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var items: [FeeItem] = []
    @Published var isPro: Bool = false

    static let freeLimit = 15

    private let fileName = "kidsclubfees_items.json"

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent(fileName)
    }

    init() {
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([FeeItem].self, from: data) else {
            items = [
        FeeItem(childName: "Emma", activity: "Soccer League", amount: 120.0, dueDate: "2026-08-01"),
        FeeItem(childName: "Noah", activity: "Piano Lessons", amount: 80.0, dueDate: "2026-07-15"),
        FeeItem(childName: "Emma", activity: "Swim Club", amount: 95.0, dueDate: "2026-07-20")
            ]
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    var canAddMore: Bool {
        isPro || items.count < Store.freeLimit
    }

    @discardableResult
    func add(_ item: FeeItem) -> Bool {
        guard canAddMore else { return false }
        items.append(item)
        save()
        return true
    }

    func update(_ item: FeeItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: FeeItem) {
        items.removeAll(where: { $0.id == item.id })
        save()
    }
}
