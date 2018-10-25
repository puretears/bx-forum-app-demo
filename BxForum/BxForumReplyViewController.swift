//
//  BxForumReplyViewController.swift
//  BxForum
//
//  Created by Mars on 2018/10/8.
//  Copyright © 2018 Mars. All rights reserved.
//

import UIKit
import PromiseKit

class BxForumReplyViewController: UIViewController {
  var forumId: Int
  var messageId: Int
  var spinner: UIView!
  var replyList: UITableView!
  var replyContext: ReplyContext!
  
  init(forumId: Int, messageId: Int) {
    self.forumId = forumId
    self.messageId = messageId
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.white
    
    // Title
    self.title = "Loading replies..."
    
    if self.replyContext != nil {
      initUI()
    }
    else {
      fetchMessageData()
    }
  }
  
  func initUI() {
    self.title = self.replyContext.message.title
    
    // Forum list
    self.replyList = UITableView()
    self.replyList.translatesAutoresizingMaskIntoConstraints = false
    self.replyList.register(UITableViewCell.self, forCellReuseIdentifier: "ReplyCell")
    self.replyList.dataSource = self
    self.replyList.delegate = self
    self.view.addSubview(replyList)
    
    NSLayoutConstraint.activate([
      replyList.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 25.0),
      replyList.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
      replyList.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
      replyList.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor)
    ].compactMap {$0})
  }
  
  func fetchMessageData() {
    let url = URL(string: "http://localhost:8080/forums/\(forumId)/messages/\(messageId)")!
    let replyContext = URLSession.shared
      .dataTask(.promise, with: url)
      .map(on: DispatchQueue.global()) {
        response -> ReplyContext in
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
          let data = try decoder.singleValueContainer().decode(String.self)
          let formatter = DateFormatter()
          formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
          
          return formatter.date(from: data)!
        })
        
        return try decoder.decode(ReplyContext.self, from: response.data)
    }
    
    firstly {
      () -> Promise<ReplyContext> in
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
      self.displaySpinner()
      return replyContext
      }.done {
        (context: ReplyContext) in
        self.replyContext = context
        self.initUI()
        self.view.setNeedsLayout()
      }.ensure {
        self.removeSpinner()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
      }.catch { error in
        print(error)
    }
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

extension BxForumReplyViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.replyContext.replies.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ReplyCell", for: indexPath)
    cell.textLabel!.text = self.replyContext.replies[indexPath.row].content
    return cell
  }
}

extension BxForumReplyViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.replyList.deselectRow(at: indexPath, animated: true)
  }
}
