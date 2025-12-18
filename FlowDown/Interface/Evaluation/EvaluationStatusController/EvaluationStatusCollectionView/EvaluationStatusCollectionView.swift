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

    private struct CaseDiffState: Equatable {
        let title: String
        let outcome: EvaluationManifest.Suite.Case.Result.Outcome
    }

    private struct SuiteHeaderDiffState: Equatable {
        let title: String
        let total: Int
        let completed: Int
        let passed: Int
        let failed: Int
        let awaitingJudging: Int
    }

    private var lastCaseStates: [UUID: CaseDiffState] = [:]
    private var lastSuiteHeaderStates: [UUID: SuiteHeaderDiffState] = [:]

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

        var newCaseStates: [UUID: CaseDiffState] = [:]
        var newSuiteHeaderStates: [UUID: SuiteHeaderDiffState] = [:]

        var changedItems: [Item] = []
        var changedSections: [Section] = []

        for manifest in session.manifests {
            for suite in manifest.suites {
                let section: Section = .suite(suite.id)
                snapshot.appendSections([section])

                let title = String(localized: suite.title)
                let total = suite.cases.count
                let completed = suite.cases.count(where: { caseItem in
                    guard let outcome = caseItem.results.last?.outcome else { return false }
                    return outcome != .notDetermined && outcome != .processing
                })
                let passed = suite.cases.count(where: { $0.results.last?.outcome == .pass })
                let failed = suite.cases.count(where: { $0.results.last?.outcome == .fail })
                let awaitingJudging = suite.cases.count(where: { $0.results.last?.outcome == .awaitingJudging })

                let suiteHeaderState = SuiteHeaderDiffState(
                    title: title,
                    total: total,
                    completed: completed,
                    passed: passed,
                    failed: failed,
                    awaitingJudging: awaitingJudging,
                )
                newSuiteHeaderStates[suite.id] = suiteHeaderState
                if let oldSuiteHeaderState = lastSuiteHeaderStates[suite.id], oldSuiteHeaderState != suiteHeaderState {
                    changedSections.append(section)
                }

                let items = suite.cases.map { caseItem in
                    let outcome = caseItem.results.last?.outcome ?? .notDetermined
                    let state = CaseDiffState(title: caseItem.title, outcome: outcome)
                    newCaseStates[caseItem.id] = state

                    let item = Item(suiteID: suite.id, caseID: caseItem.id)
                    if let oldState = lastCaseStates[caseItem.id], oldState != state {
                        changedItems.append(item)
                    }
                    return item
                }
                snapshot.appendItems(items, toSection: section)
            }
        }

        if !changedSections.isEmpty {
            snapshot.reloadSections(changedSections)
        }

        if !changedItems.isEmpty {
            snapshot.reconfigureItems(changedItems)
        }

        dataSource.apply(snapshot, animatingDifferences: animated)

        lastCaseStates = newCaseStates
        lastSuiteHeaderStates = newSuiteHeaderStates
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
