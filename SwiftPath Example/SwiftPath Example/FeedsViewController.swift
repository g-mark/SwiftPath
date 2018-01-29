//
//  FeedsViewController.swift
//  SwiftPath Example
//
//  Created by Steven Grosmark on 1/28/18.
//  Copyright © 2018 Steven Grosmark. All rights reserved.
//

import UIKit

class FeedsViewController: UITableViewController {

    private var feeds = [Feed]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Crypto Feeds"
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"Feeds", style:.plain, target:nil, action:nil)
        
        loadFeedsList()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func loadFeedsList() {
        guard
            let path = Bundle.main.path(forResource: "feeds.json", ofType: nil),
            let data = FileManager.default.contents(atPath: path),
            let feeds = try? JSONDecoder().decode([Feed].self, from: data)
        else {
            self.feeds = []
            return
        }
        self.feeds = feeds
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = feeds[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feed = feeds[indexPath.row]
        guard let url = feed.url, let jsonPath = feed.jsonPath else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            print("\n\nData:\n\(String(data: data, encoding: .utf8))")
            
            do {
                if let evaluated = try jsonPath.evaluate(with: data) {
                    let evaluatedData = try JSONSerialization.data(withJSONObject: evaluated)
                    print("\n\nEvaluated Data:\n\(String(data: evaluatedData, encoding: .utf8))")
                    let coins = try JSONDecoder().decode([Coin].self, from: evaluatedData)
                    dump(coins)
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
}

