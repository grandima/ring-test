//
//  ViewController.swift
//  ring-test
//
//  Created by Dmytro Medynsky on 6/1/19.
//  Copyright © 2019 Dmytro Medynsky. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var result: PresentationRoot? {
        didSet {
            tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkManager.init().getTopPosts(before: nil, after: nil) { (result) in
            self.result = try? result.map({PresentationRoot.init(posts: $0.data, oldPosts: [])}).get()
            
        }
        // Do any additional setup after loading the view.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result?.posts.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCellIdentifier") as! TableViewCell
        guard let post = result?.posts[indexPath.row] else { return cell }
        cell.titleLabel.text = post.title
        ImageManager.shared.getImage(for: post.thumbnail) { (image) in
            cell.imageView?.image = image
        }
        return cell
    }

}

