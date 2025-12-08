//
//  BalancedEmitter.swift
//  FlowDown
//
//  Created by qaq on 9/12/2025.
//

import Foundation

actor BalancedEmitter {
    private var buffer: String = ""
    private var isRunning: Bool = false
    private var continuation: CheckedContinuation<Void, Never>?

    private let onEmit: @Sendable (String) -> Void
    private let threshold: Double
    private let frequency: Int

    init(
        threshold: Double = 1,
        frequency: Int = 30,
        onEmit: @escaping @Sendable (String) -> Void,
    ) {
        self.threshold = threshold
        self.frequency = frequency
        self.onEmit = onEmit
    }

    func add(_ chunk: String) {
        guard !chunk.isEmpty else { return }
        buffer += chunk
        dispatchLoopIfRequired()
    }

    func wait() async {
        if buffer.isEmpty { return }
        clean()
        dispatchLoopIfRequired()
        await withCheckedContinuation { cont in
            self.continuation = cont
        }
    }

    private func dispatchLoopIfRequired() {
        guard !isRunning else { return }
        isRunning = true
        Task {
            let stepDelay = (threshold * 1000) / Double(frequency)
            let batch = Int(ceil(Double(buffer.count) / Double(frequency)))
            while !buffer.isEmpty {
                let len = max(1, batch)
                let emitText = String(buffer.prefix(len))
                buffer.removeFirst(emitText.count)
                onEmit(emitText)
                if buffer.isEmpty { break }
                try? await Task.sleep(for: .milliseconds(Int(stepDelay)))
            }
            isRunning = false
            clean()
        }
    }

    @inline(__always)
    private func clean() {
        continuation?.resume()
        continuation = nil
    }

    func cancel() {
        buffer = ""
        clean()
    }
}
