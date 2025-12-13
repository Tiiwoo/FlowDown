//
//  main.swift
//  FlowDownTranslationProvider
//
//  Created by qaq on 13/12/2025.
//

import ExtensionKit
import Foundation

NSLog("[*] starting translation provider")

guard let groupDir = FileManager.default.containerURL(
    forSecurityApplicationGroupIdentifier: AppGroup.identifier,
) else {
    fatalError("unable to located shared models")
}

try TranslationProviderExtension.main()
