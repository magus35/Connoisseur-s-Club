//
//  SecondViewController.swift
//  Connoisseur Club Central
//
//  Created by Joeseidon, King of the Joecean on 3/6/17.
//  Copyright © 2017 Joeseidon, King of the Joecean. All rights reserved.
//

import UIKit

class BeerListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var beerListSearchBar: UISearchBar!
    @IBOutlet weak var searchTypeSelector: UISegmentedControl!
    @IBOutlet weak var beerListTable: UITableView!
    
    var beerList = TheBeerList.sharedInstance
    
    var cellReuseIdentifier = "BeerListCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.beerList.theBeers.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = self.beerListTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? BeerListingTableViewCell
            else {
                fatalError("The dequeued cell is not an instance of BeerListingTableViewCell")
        }
        
        
        let listing = beerList.theBeers[beerList.beerKeys[indexPath.row]]!
        // Configure the cell...
        if listing.beerWasTried == true {
            cell.beerWasTriedLabel.text = "✅"
        } else {
            cell.beerWasTriedLabel.text = ""
        }
        cell.beerNumberLabel.text = "#\(listing.beerNumber!)"
        cell.beerNameLabel.text = listing.beerName
        
        return cell
    }



}

