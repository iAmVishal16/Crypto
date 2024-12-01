//
//  ViewController.swift
//  Crypto
//
//  Created by Vishal Paliwal on 26/11/24.
//

import UIKit

class ViewController: UIViewController {
    
    private let viewModel = CryptoListViewModel()
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.fetchCryptoList()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Crypto Coins"
        
        searchBar.delegate = self
        searchBar.placeholder = "Search by name or symbol"
        navigationItem.titleView = searchBar
        
        
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        tableView.register(CryptoCell.self, forCellReuseIdentifier: CryptoCell.identifier)
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let filterView = WrappingFilterView()
        filterView.translatesAutoresizingMaskIntoConstraints = false
        filterView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
//        view.addSubview(filterView)
        tableView.tableFooterView = filterView

        
        NSLayoutConstraint.activate([
            filterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            filterView.heightAnchor.constraint(equalToConstant: 160)
        ])
        
        filterView.onFilterSelection = { selectedFilter in
            print("Selected Filter: \(selectedFilter)")
            
            self.viewModel.isFilterActive = selectedFilter.count > 0
            
            let isActiveCoins = selectedFilter.filter({ $0 == "Active Coins" }).count > 0
            let isInActiveCoins = selectedFilter.filter({ $0 == "Inactive Coins" }).count > 0
            let isOnlyTokens = selectedFilter.filter({ $0 == "Only Tokens" }).count > 0
            let isOnlyCoins = selectedFilter.filter({ $0 == "Only Coins" }).count > 0
            let isNewCoins = selectedFilter.filter({ $0 == "New Coins" }).count > 0

            var type: String? = nil
            if isOnlyCoins {
                type = Constants.CryptoType.coin.rawValue
            }
            
            if isOnlyTokens {
                type = Constants.CryptoType.token.rawValue
            }
            
            self.viewModel.applyFilters(isActive: isActiveCoins, isInActive: isInActiveCoins, type: type, isNew: isNewCoins)

        }
    }
    
    private func setupBindings() {
        viewModel.onDataUpdate = { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(query: searchText)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredCryptos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CryptoCell.identifier, for: indexPath) as? CryptoCell else {
            return UITableViewCell()
        }
        let crypto = viewModel.filteredCryptos[indexPath.row]
        cell.configure(with: crypto)
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
            tableView.deselectRow(at: indexPath, animated: false)
            return
        }
    }
}

// MARK: Crypto Cell
class CryptoCell: UITableViewCell {
    static let identifier = "CryptoCell"
    
    
    private let tokenNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tokenSymbolLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tokenLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let badgeView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "new")
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(tokenNameLabel)
        contentView.addSubview(tokenSymbolLabel)
        contentView.addSubview(tokenLogoImageView)
        contentView.addSubview(badgeView)
        
        // Set up constraints
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {

        NSLayoutConstraint.activate([
            tokenNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            tokenNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tokenNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            tokenSymbolLabel.topAnchor.constraint(equalTo: tokenNameLabel.bottomAnchor, constant: 4),
            tokenSymbolLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tokenSymbolLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            tokenLogoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tokenLogoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            tokenLogoImageView.widthAnchor.constraint(equalToConstant: 40),
            tokenLogoImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            badgeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            badgeView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            badgeView.widthAnchor.constraint(equalToConstant: 24),
            badgeView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with crypto: Crypto) {
        self.backgroundColor = .white
        tokenNameLabel.text = crypto.name
        tokenSymbolLabel.text = crypto.symbol
        if crypto.isActive {
            self.backgroundColor = .white
            tokenLogoImageView.image = crypto.type == Constants.CryptoType.coin.rawValue ? UIImage(named: "coin") : UIImage(named: "token")
        } else {
            tokenLogoImageView.image = UIImage(named: "inactive")
            self.backgroundColor = .white.withAlphaComponent(0.9)
        }
        
        if crypto.isNew {
            badgeView.image = UIImage(named: "new")
        } else {
            badgeView.image = nil
        }
    }
}


class WrappingFilterView: UIView {
    var onFilterSelection: (([String]) -> Void)?
    
    private let filters: [(title: String, withCheckmark: Bool)] = [
        ("Active Coins", false),
        ("Inactive Coins", false),
        ("Only Tokens", false),
        ("Only Coins", false),
        ("New Coins", false)
    ]
    
    private var buttons: [UIButton] = []
    private var selectedFilters: Set<String> = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {

        buttons = filters.map { createFilterButton(title: $0.title, withCheckmark: $0.withCheckmark) }
        
        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 8
        verticalStackView.alignment = .fill
        verticalStackView.distribution = .fillProportionally
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        var currentRow = UIStackView()
        currentRow.axis = .horizontal
        currentRow.spacing = 8
        currentRow.alignment = .center
        currentRow.distribution = .fillProportionally
        currentRow.translatesAutoresizingMaskIntoConstraints = false
        
        var currentRowWidth: CGFloat = 0
        let maxWidth = UIScreen.main.bounds.width - 32
        
        for button in buttons {
            let buttonSize = button.intrinsicContentSize.width + 32
            
            if currentRowWidth + buttonSize > maxWidth {
                verticalStackView.addArrangedSubview(currentRow)
                currentRow = UIStackView()
                currentRow.axis = .horizontal
                currentRow.spacing = 8
                currentRow.alignment = .center
                currentRow.distribution = .fill
                currentRow.translatesAutoresizingMaskIntoConstraints = false
                currentRowWidth = 0
            }
            
            currentRow.addArrangedSubview(button)
            currentRowWidth += buttonSize + 8
        }
        
        verticalStackView.addArrangedSubview(currentRow)
        
        addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            verticalStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            verticalStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            verticalStackView.topAnchor.constraint(equalTo: topAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func createFilterButton(title: String, withCheckmark: Bool = false) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        button.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func filterButtonTapped(_ sender: UIButton) {
        let title = sender.currentTitle?.replacingOccurrences(of: "✔ ", with: "") ?? ""
        if selectedFilters.contains(title) {
            deselectButton(sender, title)
            selectedFilters.remove(title)
        } else {
            selectButton(sender, title)
            selectedFilters.insert(title)
        }
        
        onFilterSelection?(Array(selectedFilters))
    }
    
    private func selectButton(_ button: UIButton, _ title: String) {
        button.setTitle( "✔ " + title, for: .selected)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.isSelected = true
    }
    
    private func deselectButton(_ button: UIButton, _ title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.isSelected = false
    }
}



