//
//  ChoiceChipButton.swift
//  CoinExchange
//
//  Created by Vikalp on 10/11/24.
//
import UIKit

class ChoiceChipButton: UIButton {
  
  init(title: String, target: Any?, action: Selector, tag: Int) {
    super.init(frame: .zero)
    setupButton(title: title, target: target, action: action, tag: tag)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupButton(title: "", target: nil, action: nil, tag: 0)
  }
  
  private func setupButton(title: String, target: Any?, action: Selector?, tag: Int) {
    self.translatesAutoresizingMaskIntoConstraints = false
    self.setTitle(title, for: .normal)
    self.setTitleColor(.black, for: .normal)
    self.layer.borderWidth = 1
    self.layer.borderColor = UIColor.black.cgColor
    self.layer.cornerRadius = 27
    self.clipsToBounds = true
    self.tag = tag
    if let action = action, let target = target {
      self.addTarget(target, action: action, for: .touchUpInside)
    }
  }
}
