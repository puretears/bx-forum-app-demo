//
//  ViewController.swift
//  BxForum
//
//  Created by Mars on 2018/9/25.
//  Copyright © 2018 Mars. All rights reserved.
//

import UIKit

class ViewController: UINavigationController {
  override func viewDidLoad() {
    super.viewDidLoad()
  
    let blue = UIColor(
        red: CGFloat(0)/256.0,
        green: CGFloat(122)/256.0,
        blue: CGFloat(255)/256.0,
        alpha: 1.0)
    
    self.navigationBar.barTintColor = blue
    self.navigationBar.tintColor = .white

    self.navigationBar.titleTextAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor.white
    ]
  }
}

