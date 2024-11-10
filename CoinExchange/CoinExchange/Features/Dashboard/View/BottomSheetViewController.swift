//
//  FilterBottomSheetView.swift
//  CoinExchange
//
//  Created by Vikalp on 10/11/24.
//


import UIKit

protocol BottomSheetProtocol {
  func handleSelectedFilters(option: FilterOption)
  func handleDeselectedFilters(option: FilterOption)
}

class BottomSheetViewController: UIViewController {
  private let options = [CoinFilterConstants.activeCoin, CoinFilterConstants.inactiveCoin, CoinFilterConstants.onlyToken, CoinFilterConstants.onlyCoin, CoinFilterConstants.newCoin]
  private var selectedOptions: Set<String> = []
  var delegate : BottomSheetProtocol?
  var scrollView: UIScrollView!
  var buttons: [UIButton] = []
  let buttonSpacing: CGFloat = 10
  let padding: CGFloat = 10
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
    setupScrollView()
    createButtons(with: options)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    if !scrollView.frame.contains(touches.first!.location(in: view)) {
      dismiss(animated: true, completion: nil)
    }
  }
  
  private func setupScrollView() {
    scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.backgroundColor = .white
    scrollView.layer.cornerRadius = 12
    scrollView.clipsToBounds = true
    view.addSubview(scrollView)
    
    NSLayoutConstraint.activate([
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  private func createButtons(with texts: [String]) {
    var currentRowStartX: CGFloat = 0
    var currentRowY: CGFloat = 10
    let height: CGFloat = 54
    
    for (index, text) in texts.enumerated() {
      let button = ChoiceChipButton(title: text, target: self, action: #selector(buttonTapped(_:)), tag: index)
      scrollView.addSubview(button)
      buttons.append(button)
      
      let buttonWidth = button.intrinsicContentSize.width + 40
      
      if currentRowStartX + buttonWidth > view.frame.width - (2 * padding) {
        currentRowStartX = 0
        currentRowY += height
      }
      
      NSLayoutConstraint.activate([
        button.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: currentRowStartX + padding),
        button.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: currentRowY),
        button.widthAnchor.constraint(equalToConstant: buttonWidth),
        button.heightAnchor.constraint(equalToConstant: 44)
      ])
      
      currentRowStartX += buttonWidth + buttonSpacing
    }
    
    scrollView.contentSize = CGSize(width: view.frame.width - (2 * padding), height: currentRowY + height)
    
    let scrollViewHeightConstraint = scrollView.heightAnchor.constraint(equalToConstant: min(scrollView.contentSize.height + 20, view.frame.height - 100))
    scrollViewHeightConstraint.isActive = true
  }
  
  @objc private func buttonTapped(_ sender: UIButton) {
    let buttonText = sender.title(for: .normal) ?? ""

    if selectedOptions.contains(buttonText) {
      sender.setImage(nil, for: .normal)
      switch buttonText {
        case CoinFilterConstants.activeCoin:
          delegate?.handleDeselectedFilters(option: FilterOption(isActive: true, type: CoinType.coin.rawValue))
        case CoinFilterConstants.newCoin:
          delegate?.handleDeselectedFilters(option: FilterOption(type: CoinType.coin.rawValue, isNew: true))
        case CoinFilterConstants.inactiveCoin:
          delegate?.handleDeselectedFilters(option: FilterOption(isActive: false, type: CoinType.coin.rawValue))
        case CoinFilterConstants.onlyToken:
          delegate?.handleDeselectedFilters(option: FilterOption(type: CoinType.token.rawValue))
        case CoinFilterConstants.onlyCoin:
          delegate?.handleDeselectedFilters(option: FilterOption(type: CoinType.coin.rawValue))
        default:
          break
      }
      selectedOptions.remove(buttonText)
    } else {
      sender.setImage(UIImage(systemName: ImageConstants.circleImage), for: .normal)
      switch buttonText {
        case CoinFilterConstants.activeCoin:
          delegate?.handleSelectedFilters(option: FilterOption(isActive: true, type: CoinType.coin.rawValue))
        case CoinFilterConstants.newCoin:
          delegate?.handleSelectedFilters(option: FilterOption(type: CoinType.coin.rawValue, isNew: true))
        case CoinFilterConstants.inactiveCoin:
          delegate?.handleSelectedFilters(option: FilterOption(isActive: false, type: CoinType.coin.rawValue))
        case CoinFilterConstants.onlyToken:
          delegate?.handleSelectedFilters(option: FilterOption(type: CoinType.token.rawValue))
        case CoinFilterConstants.onlyCoin:
          delegate?.handleSelectedFilters(option: FilterOption(type: CoinType.coin.rawValue))
        default:
          break
      }
      selectedOptions.insert(buttonText)
    }
  }
  
  
}


