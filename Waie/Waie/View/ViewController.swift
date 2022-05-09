//
//  ViewController.swift
//  Waie
//
//  Created by Bharath Raj Venkatesh on 17/04/22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var applicationViewModel: ApplicationViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUp()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applicationViewModel?.requestNASAApi()
    }
    
    private func setUp() {
        applicationViewModel = ApplicationViewModel()
        applicationViewModel?.reloadTableViewClosure = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        applicationViewModel?.networkUnavailabilityClosure = { [weak self] in
            guard let self = self else { return }
            let alertController = UIAlertController(title: "Alert", message: "Network connection unavailable", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(ApplicationTableViewCell.nib(), forCellReuseIdentifier: ApplicationTableViewCell.identifier)
        tableView.tableFooterView = UIView()
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return applicationViewModel?.rowCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if let cell = tableView.dequeueReusableCell(withIdentifier: ApplicationTableViewCell.identifier, for: indexPath) as? ApplicationTableViewCell,
           let applicationCellViewModel = applicationViewModel?.applicationCellViewModel {
            cell.populate(applicationCellViewModel: applicationCellViewModel)
            return cell
        }
        return cell
    }
}

