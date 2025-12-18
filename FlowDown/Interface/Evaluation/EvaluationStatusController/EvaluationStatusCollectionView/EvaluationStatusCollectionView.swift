//
//  EvaluationStatusCollectionView.swift
//  FlowDown
//
//  Created by qaq on 18/12/2025.
//

import SnapKit
import UIKit

final class EvaluationStatusCollectionView: UIView {
    enum Section: Hashable {
        case suite(UUID)
    }

    struct Item: Hashable {
        let suiteID: UUID
        let caseID: UUID
    }

    let session: EvaluationSession

    var onSelectCase: ((EvaluationManifest.Suite.Case) -> Void)?

    static let suiteHeaderReuseIdentifier = "EvaluationSuiteHeaderView"

    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.register(
            EvaluationSuiteHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: Self.suiteHeaderReuseIdentifier,
        )
        return cv
    }()

    lazy var dataSource: UICollectionViewDiffableDataSource<Section, Item> = createDataSource()

    override var intrinsicContentSize: CGSize { .zero }

    init(session: EvaluationSession) {
        self.session = session
        super.init(frame: .zero)

        setupView()
        configureRegistrations()
        applySessionUpdate(animated: false)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func configureRegistrations() {
        collectionView.register(EvaluationStatusCell.self, forCellWithReuseIdentifier: "EvaluationStatusCell")
    }

    func setStopped() {
        // Intentionally left blank.
    }

    func applySessionUpdate(animated: Bool) {
        applySnapshot(animated: animated)
    }

    func applySnapshot(animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        for manifest in session.manifests {
            for suite in manifest.suites {
                let section: Section = .suite(suite.id)
                snapshot.appendSections([section])
                let items = suite.cases.map { Item(suiteID: suite.id, caseID: $0.id) }
                snapshot.appendItems(items, toSection: section)
            }
        }

        snapshot.reloadSections(snapshot.sectionIdentifiers)

        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    func suite(forSectionIndex sectionIndex: Int) -> EvaluationManifest.Suite? {
        var suites: [EvaluationManifest.Suite] = []
        for manifest in session.manifests {
            suites.append(contentsOf: manifest.suites)
        }

        guard suites.indices.contains(sectionIndex) else { return nil }
        return suites[sectionIndex]
    }

    func caseItem(for item: Item) -> EvaluationManifest.Suite.Case? {
        for manifest in session.manifests {
            for suite in manifest.suites where suite.id == item.suiteID {
                return suite.cases.first(where: { $0.id == item.caseID })
            }
        }
        return nil
    }
}
