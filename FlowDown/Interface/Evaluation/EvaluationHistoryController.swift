//
//  EvaluationHistoryController.swift
//  FlowDown
//
//  Created by qaq on 18/12/2025.
//

import SnapKit
import UIKit

class EvaluationHistoryController: UIViewController {
    private var sessions: [EvaluationSession] = []

    private lazy var collectionView: UICollectionView = {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    private let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, EvaluationSession> { cell, _, session in
        var content = cell.defaultContentConfiguration()
        content.text = session.id.uuidString // Fallback title

        let dateString = session.createdAt.formatted(date: .abbreviated, time: .shortened)
        content.text = dateString

        var secondaryText = session.modelIdentifier
        // Calculate stats if possible (not computed in session yet, just showing metadata)
        let totalCases = session.manifests.reduce(0) { $0 + $1.suites.reduce(0) { $0 + $1.cases.count } }
        secondaryText += " • \(totalCases) cases"

        content.secondaryText = secondaryText
        content.secondaryTextProperties.color = .secondaryLabel

        cell.contentConfiguration = content
        cell.accessories = [.disclosureIndicator()]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = String(localized: "Evaluation History")
        view.backgroundColor = .systemGroupedBackground

        setupView()
        loadData()
    }

    private func setupView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func loadData() {
        do {
            sessions = try EvaluationSessionManager.shared.listSessions()
            collectionView.reloadData()
        } catch {
            // Handle error silently or log
            print("Failed to load sessions: \(error)")
        }
    }
}

extension EvaluationHistoryController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        sessions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let session = sessions[indexPath.item]
        return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: session)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let session = sessions[indexPath.item]
        let resultController = EvaluationResultController(session: session)
        navigationController?.pushViewController(resultController, animated: true)
    }

    func collectionView(_: UICollectionView, performPrimaryActionForItemAt _: IndexPath) {
        // Handle selection
    }

    func collectionView(_: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point _: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let deleteAction = UIAction(
                title: String(localized: "Delete"),
                image: UIImage(systemName: "trash"),
                attributes: .destructive,
            ) { _ in
                self?.deleteSession(at: indexPath)
            }
            return UIMenu(title: "", children: [deleteAction])
        }
    }

    private func deleteSession(at indexPath: IndexPath) {
        let session = sessions[indexPath.item]
        do {
            try EvaluationSessionManager.shared.delete(id: session.id)
            sessions.remove(at: indexPath.item)
            collectionView.deleteItems(at: [indexPath])
        } catch {
            // Error handling
        }
    }
}
