//
//  ViewController.swift
//  UICollectionViewDiffableDataSourceChangeDataSource
//
//  Created by 坂本龍哉 on 2022/01/03.
//

import UIKit

enum SearchState {
    case recommend
    case result
    
    mutating func changeState() {
        switch self {
        case .recommend: self = .result
        case .result: self = .recommend
        }
    }
}

final class ViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, Int>! = nil
    private var numbers: [[Int]] = [[1, 2, 3, 4, 5, 6],
                                    [7, 8, 9, 10, 11, 12]]
    private var searchState: SearchState = .recommend
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        configureDataSource()
    }
    
    @IBAction func didTapRefreshButton(_ sender: Any) {
        searchState.changeState()
        collectionView.collectionViewLayout = createLayout()
        configureDataSource()
    }
    
}

// MARK: - func
extension ViewController {
    
    private func snapShot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        (0..<numbers.count).forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems(numbers[$0])
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}

// MARK: - setup
extension ViewController {
    
    private func setupCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(UIDiffableDataSourceCollectionViewCell.nib, forCellWithReuseIdentifier: UIDiffableDataSourceCollectionViewCell.identifier)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, Int>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UIDiffableDataSourceCollectionViewCell.identifier, for: indexPath) as? UIDiffableDataSourceCollectionViewCell else { return UICollectionViewCell() }
            cell.configure(number: itemIdentifier)
            return cell
        })
        
        // MARK: Headerの作成
        let supplementaryRegistration = UICollectionView.SupplementaryRegistration<CollectionViewHeaderTitle>(elementKind: "header-element-kind") { supplementaryView, elementKind, indexPath in
            supplementaryView.label.text = "数字"
            supplementaryView.label.textColor = .white
            supplementaryView.label.font = .boldSystemFont(ofSize: 20)
        }
        dataSource.supplementaryViewProvider = { [weak self] (view, kind, index) in
            return self?.collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryRegistration, for: index)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        (0..<numbers.count).forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems(numbers[$0])
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()

        switch searchState {
        case .recommend:
            let layout = UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection in
                let leadingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                            heightDimension: .fractionalHeight(1.0)))
                leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                let containerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                                                                           heightDimension: .fractionalHeight(0.3)),
                                                                        subitems: [leadingItem])
                let section = NSCollectionLayoutSection(group: containerGroup)
                section.orthogonalScrollingBehavior = .continuous
                // MARK: Headerの処理
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                                                   heightDimension: .estimated(44)),
                                                                                elementKind: "header-element-kind",
                                                                                alignment: .top)
                section.boundarySupplementaryItems = [sectionHeader]

                return section
            }, configuration: config)
            
            return layout

        case .result:
            let layout = UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection in
                let leadingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                            heightDimension: .fractionalHeight(1.0)))
                leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                let containerGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                                           heightDimension: .fractionalHeight(0.1)),
                                                                        subitems: [leadingItem])
                let section = NSCollectionLayoutSection(group: containerGroup)
                // MARK: Headerの処理
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                                                   heightDimension: .estimated(44)),
                                                                                elementKind: "header-element-kind",
                                                                                alignment: .top)
                section.boundarySupplementaryItems = [sectionHeader]

                return section
            }, configuration: config)
            
            return layout
        }
    }
    
}

// MARK: - UICollectionReusableView
final class CollectionViewHeaderTitle: UICollectionReusableView {
    let label = UILabel()
    static let reuseIdentifier = "title-supplementary-reuse-identifier"

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CollectionViewHeaderTitle {
    private func configure() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        let inset: CGFloat = 10
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            label.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
        ])
        label.font = UIFont.preferredFont(forTextStyle: .title3)
    }
}
