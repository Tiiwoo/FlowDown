//
//  EvaluationStatusCollectionView+DataSource.swift
//  FlowDown
//
//  Created by qaq on 18/12/2025.
//

import UIKit

extension EvaluationStatusCollectionView {
    func createDataSource() -> UICollectionViewDiffableDataSource<EvaluationStatusCollectionView.Section, EvaluationStatusCollectionView.Item> {
        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { [weak self] collectionView, indexPath, itemIdentifier in
            guard let self else { return UICollectionViewCell() }

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EvaluationStatusCell", for: indexPath) as? EvaluationStatusCell else {
                return UICollectionViewCell()
            }
            if let caseItem = caseItem(for: itemIdentifier) {
                cell.configure(with: caseItem)
            }
            return cell
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self else { return nil }
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            guard let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: Self.suiteHeaderReuseIdentifier,
                for: indexPath,
            ) as? EvaluationSuiteHeaderView else {
                return nil
            }
            if let suite = suite(forSectionIndex: indexPath.section) {
                view.configure(
                    title: String(localized: suite.title),
                    total: suite.cases.count,
                    completed: suite.cases.count(where: { caseItem in
                        guard let outcome = caseItem.results.last?.outcome else { return false }
                        return outcome != .notDetermined && outcome != .processing
                    }),
                    passed: suite.cases.count(where: { $0.results.last?.outcome == .pass }),
                )
            }
            return view
        }
        return dataSource
    }
}
