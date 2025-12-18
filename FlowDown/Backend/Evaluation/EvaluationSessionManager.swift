//
//  EvaluationSessionManager.swift
//  FlowDown
//
//  Created by qaq on 18/12/2025.
//

import Foundation
import OSLog

enum EvaluationSessionStorageError: Error {
    case applicationSupportUnavailable
}

final class EvaluationSessionManager {
    static let shared = EvaluationSessionManager()

    private let logger = Logger(subsystem: "FlowDown", category: "EvaluationSession")
    private let encoder: PropertyListEncoder = .init()
    private let decoder: PropertyListDecoder = .init()

    private init() {}

    // MARK: - Public API

    @discardableResult
    func save(_ session: EvaluationSession) throws -> URL {
        let directory = try sessionsDirectoryURL()

        let url = directory.appendingPathComponent(filename(for: session.id))
        let data = try encoder.encode(session)
        try data.write(to: url, options: [.atomic])
        logger.info("saved evaluation session \(session.id.uuidString, privacy: .public)")
        return url
    }

    func load(id: UUID) throws -> EvaluationSession {
        let url = try sessionURL(for: id)
        let data = try Data(contentsOf: url)
        return try decoder.decode(EvaluationSession.self, from: data)
    }

    func delete(id: UUID) throws {
        let url = try sessionURL(for: id)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
            logger.info("deleted evaluation session \(id.uuidString, privacy: .public)")
        }
    }

    func deleteAll() throws {
        let directory = try sessionsDirectoryURL()
        guard FileManager.default.fileExists(atPath: directory.path) else {
            return
        }

        let urls = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles],
        )
        .filter { $0.pathExtension == "plist" }

        for url in urls {
            try FileManager.default.removeItem(at: url)
        }

        logger.info("deleted all evaluation sessions (\(urls.count, privacy: .public))")
    }

    func listSessions() throws -> [EvaluationSession] {
        let directory = try sessionsDirectoryURL()
        guard FileManager.default.fileExists(atPath: directory.path) else {
            return []
        }

        let urls = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.creationDateKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles],
        )
        .filter { $0.pathExtension == "plist" }

        var sessions: [EvaluationSession] = []
        sessions.reserveCapacity(urls.count)

        for url in urls {
            do {
                let data = try Data(contentsOf: url)
                let session = try decoder.decode(EvaluationSession.self, from: data)
                sessions.append(session)
            } catch {
                logger.error("failed to decode evaluation session at \(url.lastPathComponent, privacy: .public): \(String(describing: error), privacy: .public)")
            }
        }

        return sessions.sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Paths

    private func sessionsDirectoryURL() throws -> URL {
        guard let base = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
        ).first
        else {
            throw EvaluationSessionStorageError.applicationSupportUnavailable
        }
        let dir = base
            .appendingPathComponent("FlowDown", isDirectory: true)
            .appendingPathComponent("EvaluationSessions", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func filename(for id: UUID) -> String {
        "session-\(id.uuidString).plist"
    }

    private func sessionURL(for id: UUID) throws -> URL {
        let directory = try sessionsDirectoryURL()
        return directory.appendingPathComponent(filename(for: id))
    }
}
