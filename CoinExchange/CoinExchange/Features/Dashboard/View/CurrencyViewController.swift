//
//  CurrencyViewController.swift
//  CoinExchange
//
//  Created by Vikalp on 10/11/24.
//

import UIKit
import Combine

class CurrencyViewController: UIViewController {

  var viewModel = CurrencyViewModel()
  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.dataSource = self
    tableView.register(CurrencyTableViewCell.self, forCellReuseIdentifier: StringConstants.cellIdentifier)
    return tableView
  }()
  private lazy var loaderView: UIActivityIndicatorView = {
    let loader = UIActivityIndicatorView(style: .large)
    loader.translatesAutoresizingMaskIntoConstraints = false
    loader.hidesWhenStopped = true
    return loader
  }()
  lazy var searchBar: UISearchBar = {
    let searchBar = UISearchBar()
    searchBar.placeholder = "Search"
    searchBar.delegate = self
    searchBar.isHidden = true
    searchBar.translatesAutoresizingMaskIntoConstraints = false
    return searchBar
  }()
  private lazy var floatingButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(systemName: "pencil"), for: .normal)
    button.tintColor = .systemBlue
    button.backgroundColor = .yellow
    button.layer.cornerRadius = 30
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOffset = CGSize(width: 0, height: 2)
    button.layer.shadowOpacity = 0.3
    button.layer.shadowRadius = 5
    button.addTarget(self, action: #selector(showFilterSheet), for: .touchUpInside)
    return button
  }()
  private let buttonTextfieldVisibility = UIButton()
  private var filterSheetViewController: BottomSheetViewController?
  private var cancellables: Set<AnyCancellable> = []
 
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    Task {
      await viewModel.fetchData()
    }
    
    viewModel.$data
      .sink { [weak self] data in
        // Update UI with data
        DispatchQueue.main.async {
          self?.tableView.reloadData()
          self?.hideLoader()
        }
      }
      .store(in: &cancellables)
    
    viewModel.$filteredData
      .sink { [weak self] data in
        // Update UI with data
        DispatchQueue.main.async {
          self?.tableView.reloadData()
          self?.hideLoader()
        }
      }
      .store(in: &cancellables)
    
    viewModel.$error
      .sink { error in
        print("Error: \(String(describing: error))")
      }
      .store(in: &cancellables)
  }
  
  private func setupUI() {
    view.backgroundColor = .white
    let headerView = UIView()
    headerView.backgroundColor = .blue
    headerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(headerView)
    
    let safeArea = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      headerView.topAnchor.constraint(equalTo: safeArea.topAnchor),
      headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      headerView.heightAnchor.constraint(equalToConstant: 60)
    ])
    setupcurrencyFilter(headerView)
    setupTableView(headerView, safeArea)
    setupFloatingButton()

    setupLoader()
    showLoader()
  }
  
  private func setupFloatingButton() {
    view.addSubview(floatingButton)
    
    NSLayoutConstraint.activate([
      floatingButton.widthAnchor.constraint(equalToConstant: 60),
      floatingButton.heightAnchor.constraint(equalToConstant: 60),
      floatingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
    ])
  }
  
  private func setupLoader() {
    view.addSubview(loaderView)
    
    NSLayoutConstraint.activate([
      loaderView.topAnchor.constraint(equalTo: view.topAnchor),
      loaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      loaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      loaderView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  func showLoader() {
    loaderView.isHidden = false
    loaderView.startAnimating()
  }
  
  func hideLoader() {
    loaderView.stopAnimating()
    loaderView.isHidden = true
  }
  
  fileprivate func setupTableView(_ headerView: UIView, _ safeArea: UILayoutGuide) {
    view.addSubview(tableView)
    
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
    ])
  }
  
  fileprivate func setupcurrencyFilter(_ headerView: UIView) {
    buttonTextfieldVisibility.setImage(UIImage(systemName: ImageConstants.searchImage), for: .normal)
    buttonTextfieldVisibility.tintColor = .white
    buttonTextfieldVisibility.addTarget(self, action: #selector(currencySearch), for: .touchUpInside)
    buttonTextfieldVisibility.translatesAutoresizingMaskIntoConstraints = false
    headerView.addSubview(buttonTextfieldVisibility)
    headerView.addSubview(searchBar)
    
    NSLayoutConstraint.activate([
      buttonTextfieldVisibility.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
      buttonTextfieldVisibility.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
      buttonTextfieldVisibility.widthAnchor.constraint(equalToConstant: 30),
      buttonTextfieldVisibility.heightAnchor.constraint(equalToConstant: 30)
    ])
    NSLayoutConstraint.activate([
      searchBar.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
      searchBar.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
      searchBar.trailingAnchor.constraint(equalTo: buttonTextfieldVisibility.leadingAnchor, constant: -10)
    ])
  }
  
  @objc private func currencySearch() {
    searchBar.isHidden = !searchBar.isHidden
    buttonTextfieldVisibility.setImage(UIImage(systemName: searchBar.isHidden ? ImageConstants.searchImage : ImageConstants.cancelImage), for: .normal)
    if searchBar.isHidden { // Resign Keyboard when search bar is hidden
      searchBar.resignFirstResponder()
    } else {
      searchBar.becomeFirstResponder()
    }
  }
  
  @objc private func showFilterSheet() {
    if filterSheetViewController == nil {
      filterSheetViewController = BottomSheetViewController()
      
      filterSheetViewController?.delegate = self
      
      filterSheetViewController?.modalPresentationStyle = .overCurrentContext
      filterSheetViewController?.modalTransitionStyle = .crossDissolve
    }
    
    present(filterSheetViewController ?? UIViewController(), animated: true)
  }
}

// MARK: TableView DataSource
extension CurrencyViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.filteredData.isEmpty ? viewModel.data.count : viewModel.filteredData.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: StringConstants.cellIdentifier, for: indexPath) as! CurrencyTableViewCell
    let coin = viewModel.filteredData.isEmpty ? viewModel.data[indexPath.row] : viewModel.filteredData[indexPath.row]
    cell.configure(with: coin)
    return cell
  }
}

// MARK: BottomSheet Controller Delegate Calls
extension CurrencyViewController: BottomSheetProtocol {
  func handleSelectedFilters(option: FilterOption) {
    viewModel.applyFilters(option: option)
  }
  
  func handleDeselectedFilters(option: FilterOption) {
    viewModel.deselectFilter(option: option)
  }
}

// MARK: Searchbar Delegate handling
extension CurrencyViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    viewModel.search(query: searchText)
  }
  
  func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
    searchBar.resignFirstResponder()
    return true
  }
}
