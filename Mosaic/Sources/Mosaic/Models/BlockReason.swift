import Foundation

enum BlockReason: String, CaseIterable, Codable {
    case noLongerInterested = "no_longer_interested"
    case notCompatible = "not_compatible"
    case schedulingConflict = "scheduling_conflict"
    case other = "other"

    var displayName: String {
        switch self {
        case .noLongerInterested: return "No longer interested"
        case .notCompatible: return "Not compatible"
        case .schedulingConflict: return "Scheduling conflict"
        case .other: return "Other"
        }
    }
}
