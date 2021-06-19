//
//  DetailViewController.swift
//  Alamofire-BackendlessAPI-StarWarsAPI
//
//  Created by Desi Mac Book 1 on 19.06.2021.
//

import UIKit
import Alamofire

class DetailViewController: UIViewController {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var item1TitleLabel: UILabel!
  @IBOutlet weak var item1Label: UILabel!
  @IBOutlet weak var item2TitleLabel: UILabel!
  @IBOutlet weak var item2Label: UILabel!
  @IBOutlet weak var item3TitleLabel: UILabel!
  @IBOutlet weak var item3Label: UILabel!
  @IBOutlet weak var listTitleLabel: UILabel!
  @IBOutlet weak var listTableView: UITableView!
  
  var data: Displayable?
  var listData: [Displayable] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    commonInit()
    
    listTableView.dataSource = self
    fetchList()
  }
  
  private func commonInit() {
    guard let data = data else { return }
    
    titleLabel.text = data.titleLabelText
    subtitleLabel.text = data.subtitleLabelText
    
    item1TitleLabel.text = data.item1.label
    item1Label.text = data.item1.value
    
    item2TitleLabel.text = data.item2.label
    item2Label.text = data.item2.value
    
    item3TitleLabel.text = data.item3.label
    item3Label.text = data.item3.value
    
    listTitleLabel.text = data.listTitle
  }
}

// MARK: - UITableViewDataSource
extension DetailViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return listData.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
    cell.textLabel?.text = listData[indexPath.row].titleLabelText
    return cell
  }
}

// MARK: - Fetching
extension DetailViewController {
  // 1
  private func fetch<T: Decodable & Displayable>(_ list: [String], of: T.Type) {
    var items: [T] = []
    // 2
    let fetchGroup = DispatchGroup()
    
    // 3
    list.forEach { (url) in
      // 4
      fetchGroup.enter()
      // 5
      AF.request(url).validate().responseDecodable(of: T.self) { (response) in
        if let value = response.value {
          items.append(value)
        }
        // 6
        fetchGroup.leave()
      }
    }
    
    fetchGroup.notify(queue: .main) {
      self.listData = items
      self.listTableView.reloadData()
    }
  }
  
  func fetchList() {
    // 1
    guard let data = data else { return }
    
    // 2
    switch data {
    case is Film:
      fetch(data.listItems, of: Starship.self)
    case is Starship:
      fetch(data.listItems, of: Film.self)
    default:
      print("Unknown type: ", String(describing: type(of: data)))
    }
  }
}
