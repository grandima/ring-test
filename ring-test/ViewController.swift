//
//  ViewController.swift
//  ring-test
//
//  Created by Dmytro Medynsky on 6/1/19.
//  Copyright © 2019 Dmytro Medynsky. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, PresenterOutput {
    @IBOutlet weak var tableView: UITableView!
    
    private var presenter: Presenter!
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = Presenter.init()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = presenter
        presenter.view = self
        presenter.load()
    }
    
    func update() {
        tableView.reloadData()
    }


}

