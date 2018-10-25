//
//  BxForumViewController.swift
//  BxForum
//
//  Created by Mars on 2018/9/25.
//  Copyright © 2018 Mars. All rights reserved.
//

import UIKit
import PromiseKit

class BxForumViewController: UIViewController {
  var spinner: UIView!
  var forumList: UITableView!
  var userContext: UserContext!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.white
  
    // Title
    self.title = "Boxue Forum"
  
    if self.userContext != nil {
      initUI()
    }
    else {
      fetchForumData()
    }
  }
    
  func fetchForumData() {
    let url = URL(string: "http://localhost:8080/forums")!
    let userContext = URLSession.shared
      .dataTask(.promise, with: url)
      .map(on: DispatchQueue.global()) {
        try JSONDecoder().decode(UserContext.self, from: $0.data)
      }

    firstly {
      () -> Promise<UserContext> in
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
      self.displaySpinner()
      return userContext
    }.done {
      (context: UserContext) in
      self.userContext = context

      self.initUI()
      self.view.setNeedsLayout()
    }.ensure {
      self.removeSpinner()
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }.catch { error in
      print(error)
    }
//    self.displaySpinner()
//
//    let task = URLSession.shared.dataTask(with: url) {
//        data, _, error in
//        if let data = data {
//            do {
//                self.userContext = try JSONDecoder().decode(UserContext.self, from: data)
//
//                DispatchQueue.main.async {
//                    self.removeSpinner()
//                    self.initUI()
//                    self.view.setNeedsLayout()
//                }
//            }
//            catch {
//                print(error)
//            }
//        }
//        else if let error = error {
//            print(error)
//        }
//    }
//
//    task.resume()
  }
    
  func initUI() {
    // Welcome message
    let welcomeLabel = UILabel()
    welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
    welcomeLabel.text = "Hello, \(self.userContext.username)"
    welcomeLabel.textAlignment = .center
    welcomeLabel.font = UIFont.boldSystemFont(ofSize: 22)
  
    self.view.addSubview(welcomeLabel)
  
    NSLayoutConstraint.activate([
        welcomeLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 25.0),
        welcomeLabel.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
        welcomeLabel.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
        ].compactMap {$0})
  
    // Forum list
    self.forumList = UITableView()
    self.forumList.translatesAutoresizingMaskIntoConstraints = false
    self.forumList.register(UITableViewCell.self, forCellReuseIdentifier: "ForumCell")
    self.forumList.dataSource = self
    self.forumList.delegate = self
    self.view.addSubview(forumList)
  
    NSLayoutConstraint.activate([
        forumList.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 25.0),
        forumList.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
        forumList.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        forumList.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor)
        ].compactMap {$0})
  }
    
  func displaySpinner() {
    self.spinner = UIView(frame: view.bounds)
    self.spinner.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.5)

    let ai = UIActivityIndicatorView(style: .whiteLarge)
    ai.startAnimating()
    ai.center = self.spinner.center

    self.spinner.addSubview(ai)
    self.view.addSubview(self.spinner)
  }
  
  func removeSpinner() {
    self.spinner.removeFromSuperview()
  }
}

extension BxForumViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.userContext.forums.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ForumCell", for: indexPath)
    cell.textLabel!.text = self.userContext.forums[indexPath.row].name
    cell.accessoryType = .disclosureIndicator
    return cell
  }
}

extension BxForumViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.forumList.deselectRow(at: indexPath, animated: true)
    let messageVC = BxForumMessageViewController(forumId: indexPath.row+1)
    self.navigationController?.pushViewController(messageVC, animated: true)
  }
}
