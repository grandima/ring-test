//
//  ViewController.swift
//  ring-test
//
//  Created by Dmytro Medynsky on 6/1/19.
//  Copyright © 2019 Dmytro Medynsky. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    private let presenter: Presenter = { return Presenter.init() }()
    
    fileprivate var lastVisibleRow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        addActivityIndicator()
        configurePresenter()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if lastVisibleRow == nil {
            refresh()
        }
    }
    
    @objc private func refresh() {
        presenter.load()
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    private func addActivityIndicator() {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.startAnimating()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44)
        tableView.tableFooterView = activityIndicator
    }
    
    private func configurePresenter() {
        tableView.dataSource = presenter
        tableView.prefetchDataSource = presenter
        presenter.view = self
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.willDisplayCell(at: indexPath)
    }
}

extension ViewController: PresenterOutput {
    func update() {
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func getCell(at index: Int) -> UITableViewCell? {
        let indexPath = IndexPath.init(row: index, section: 0)
        return tableView.cellForRow(at: indexPath)
    }
    
    func present(with image: UIImage) {
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
        present(vc, animated: true)
    }
}

extension ViewController {
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        let data = presenter.dataModel
        coder.encode(data, forKey: "response")
        if let indexPath = tableView.indexPathsForVisibleRows?.last {
            coder.encode(indexPath.row, forKey: "currentRow")
        }
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        if let data = coder.decodeObject(forKey: "response") as? Data {
            let row = coder.decodeInteger(forKey: "currentRow")
            lastVisibleRow = row
            presenter.dataModel = data
        }
        
    }
    
    override func applicationFinishedRestoringState() {
        guard let row = lastVisibleRow else { return }
        let indexPath = IndexPath(row: row, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
}
