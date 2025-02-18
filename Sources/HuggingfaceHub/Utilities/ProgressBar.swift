import Foundation

enum ProgressBarType {
    case network
    case count

    var formatter: (Int64) -> String {
        switch self {
        case .network:
            return { ByteCountFormatter.string(fromByteCount: $0, countStyle: .file) }
        case .count:
            return { String($0) }
        }
    }

    var speedUnit: String {
        switch self {
        case .network: return "/s"
        case .count: return " it/s"
        }
    }
}

actor ProgressBar {
    private let width = 50
    private let startTime = Date()
    private var lastUpdateTime = Date()
    private var previousProgress: Int64 = 0
    private let title: String
    private let type: ProgressBarType
    private var total: Int64

    init(title: String, total: Int64 = 0, type: ProgressBarType = .network) {
        self.title = title
        self.type = type
        self.total = total
    }

    func update(current: Int64, total: Int64? = nil) {
        if let total { self.total = total }

        let now = Date()
        let timeElapsed = now.timeIntervalSince(startTime)
        let timeSinceLastUpdate = now.timeIntervalSince(lastUpdateTime)

        let speed = calculateSpeed(current: current, timeSinceLastUpdate: timeSinceLastUpdate)
        let eta = calculateETA(current: current, speed: speed)
        let percentage = calculatePercentage(current: current)
        let progressBar = createProgressBar(percentage: percentage)

        let formatter = type.formatter

        let progressInfo = String(
            format: "%@: %.1f%%|%@| %@/%@ [%@<%@, %@%@]",
            title,
            percentage,
            progressBar,
            formatter(current),
            formatter(self.total),
            timeElapsed.formattedDuration(),
            eta.formattedDuration(),
            formatter(Int64(speed)),
            type.speedUnit
        )

        print("\u{1B}[1A\u{1B}[K\(progressInfo)")
        fflush(stdout)

        if current == total {
            print()
        }

        lastUpdateTime = now
        previousProgress = current
    }

    private func calculateSpeed(current: Int64, timeSinceLastUpdate: TimeInterval) -> Double {
        guard timeSinceLastUpdate > 0 else { return 0 }
        return Double(current - previousProgress) / timeSinceLastUpdate
    }

    private func calculateETA(current: Int64, speed: Double) -> Double {
        let remaining = total - current
        guard remaining > 0, speed > 0 else { return 0 }
        return Double(remaining) / speed
    }

    private func calculatePercentage(current: Int64) -> Double {
        guard current > 0, total > 0 else { return 0 }
        return Double(current * 100) / Double(total)
    }

    private func createProgressBar(percentage: Double) -> String {
        let filledWidth = percentage > 0 ? Int(Double(width) * percentage / 100.0) : 0
        let emptyWidth = width - filledWidth
        return String(repeating: "█", count: filledWidth) + String(repeating: "░", count: emptyWidth)
    }
}
