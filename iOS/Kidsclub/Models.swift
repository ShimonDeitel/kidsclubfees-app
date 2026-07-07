import Foundation

struct FeeItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var childName: String
    var activity: String
    var amount: Double
    var dueDate: String
    var dateAdded: Date = Date()
}
