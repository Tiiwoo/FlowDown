//
//  TemplateMigrationTests.swift
//  StorageTests
//
//  Created by Assistant on 2025/12/07.
//

import Foundation
@testable import Storage
import Testing
import WCDBSwift

@Suite("Template migrations")
struct TemplateMigrationTests {
    @Test("V5 -> V6 creates ChatTemplate table and bumps userVersion")
    func migrateV5ToV6_createsTable() throws {
        let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        let databaseURL = tempDirectory.appendingPathComponent("migration.db")
        let database = Database(at: databaseURL.path)
        defer { database.close() }

        // simulate existing schema at v5
        try database.exec(StatementPragma().pragma(.userVersion).to(DBVersion.Version5.rawValue))

        let migration = MigrationV5ToV6()
        try migration.migrate(db: database)

        #expect(try database.isTableExists(ChatTemplateRecord.tableName))
        let userVersion = try database.getValue(from: StatementPragma().pragma(.userVersion))?.intValue
        #expect(userVersion == DBVersion.Version6.rawValue)
    }
}
