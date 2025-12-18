//
//  EvaluationResultController.swift
//  FlowDown
//
//  Created by qaq on 18/12/2025.
//

import SnapKit
import UIKit

class EvaluationResultController: UIViewController {
    let session: EvaluationSession

    // Flattened data structure for display: [(Suite, [Case])] or just Sections of Suites
    private var sections: [(suite: EvaluationManifest.Suite, cases: [EvaluationManifest.Suite.Case])] = []

    private lazy var collectionView: UICollectionView = {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.headerMode = .supplementary
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    private let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { _, _, _ in
        // We will configure this in dataSource
    }

    private let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, EvaluationManifest.Suite.Case> { cell, _, item in
        var content = cell.defaultContentConfiguration()
        content.text = item.title

        let result = item.results.last?.outcome ?? .notDetermined

        let iconName: String
        let iconColor: UIColor

        switch result {
        case .pass:
            iconName = "checkmark.circle.fill"
            iconColor = .systemGreen
        case .fail:
            iconName = "xmark.circle.fill"
            iconColor = .systemRed
        case .processing:
            iconName = "arrow.triangle.2.circlepath.circle.fill"
            iconColor = .systemBlue
        case .awaitingJudging:
            iconName = "eye.circle.fill"
            iconColor = .systemOrange
        case .notDetermined:
            iconName = "circle"
            iconColor = .systemGray3
        }

        content.image = UIImage(systemName: iconName)
        content.imageProperties.tintColor = iconColor

        cell.contentConfiguration = content
        cell.accessories = [.disclosureIndicator()]
    }

    init(session: EvaluationSession) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
        prepareData()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = String(localized: "Results")
        view.backgroundColor = .systemGroupedBackground

        setupView()
    }

    private func prepareData() {
        // Flatten suites from all manifests
        sections = session.manifests.flatMap { manifest in
            manifest.suites.map { suite in
                (suite: suite, cases: suite.cases)
            }
        }
    }

    private func setupView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension EvaluationResultController: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        sections.count
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[section].cases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = sections[indexPath.section].cases[indexPath.item]
        return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        return UICollectionReusableView()
    }
}

// Separate extension for Header Configuration to keep closure clean
extension EvaluationResultController {
    func configureHeader(_ view: UICollectionViewListCell, at indexPath: IndexPath) {
        var content = view.defaultContentConfiguration()
        let suite = sections[indexPath.section].suite
        content.text = String(localized: suite.title)
        view.contentConfiguration = content
    }
}

extension EvaluationResultController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionHeader, let listCell = view as? UICollectionViewListCell {
            configureHeader(listCell, at: indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let item = sections[indexPath.section].cases[indexPath.item]
        let detailVC = EvaluationCaseDetailController(caseItem: item, session: session)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
