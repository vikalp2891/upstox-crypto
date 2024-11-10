//
//  CurrencyTableViewCell.swift
//  CoinExchange
//
//  Created by Vikalp on 10/11/24.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {
  
  fileprivate let labelName = UILabel()
  fileprivate let labelSymbol = UILabel()
  fileprivate var imageViewCoin: UIImageView!
  fileprivate var imageViewNewBadge: UIImageView!
  fileprivate var stackView = UIStackView()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
    self.isUserInteractionEnabled = false
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    labelName.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    labelSymbol.font = UIFont.systemFont(ofSize: 14, weight: .regular)
    labelSymbol.textColor = .gray
    
    // Setup coin image
    imageViewCoin = UIImageView()
    imageViewCoin.translatesAutoresizingMaskIntoConstraints = false
    imageViewCoin.contentMode = .scaleAspectFill
    imageViewCoin.clipsToBounds = true
    contentView.addSubview(imageViewCoin)
    
    // Setup new badge image
    imageViewNewBadge = UIImageView()
    imageViewNewBadge.translatesAutoresizingMaskIntoConstraints = false
    imageViewNewBadge.image = UIImage(named: ImageConstants.newBadge)
    imageViewNewBadge.isHidden = true
    contentView.addSubview(imageViewNewBadge)
    
    // Setup StackView
    stackView.addArrangedSubview(labelName)
    stackView.addArrangedSubview(labelSymbol)
    stackView.axis = .vertical
    stackView.spacing = 4
    stackView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(stackView)
    
    setupConstraints()
  }
  
  private func setupConstraints() {
    // stackview constraints
    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
    ])
    
    // Image view container constraints
    NSLayoutConstraint.activate([
      imageViewCoin.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      imageViewCoin.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      imageViewCoin.widthAnchor.constraint(equalToConstant: 40),
      imageViewCoin.heightAnchor.constraint(equalToConstant: 40)
    ])
    
    // New data badge constraints
    NSLayoutConstraint.activate([
      imageViewNewBadge.topAnchor.constraint(equalTo: imageViewCoin.topAnchor, constant: -5),
      imageViewNewBadge.trailingAnchor.constraint(equalTo: imageViewCoin.trailingAnchor, constant: 5),
      imageViewNewBadge.widthAnchor.constraint(equalToConstant: 20),
      imageViewNewBadge.heightAnchor.constraint(equalToConstant: 20)
    ])
  }
  
  func configure(with coin: Coins) {
    labelName.text = coin.name
    labelSymbol.text = coin.symbol
    if (coin.isActive && coin.type == CoinType.coin.rawValue) {
      imageViewCoin.image =  UIImage(named: ImageConstants.coinActive)
    } else if(coin.isActive && coin.type == CoinType.token.rawValue) {
      imageViewCoin.image =  UIImage(named: ImageConstants.tokenActive)
    } else {
      imageViewCoin.image =  UIImage(named: ImageConstants.inactive)
    }
    imageViewNewBadge.isHidden = !coin.isNew
    labelName.textColor = coin.isActive ? .black : .gray
  }
}
