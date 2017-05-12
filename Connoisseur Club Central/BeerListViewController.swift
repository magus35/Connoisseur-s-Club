//
//  SecondViewController.swift
//  Connoisseur Club Central
//
//  Created by Joeseidon, King of the Joecean on 3/6/17.
//  Copyright © 2017 Joeseidon, King of the Joecean. All rights reserved.
//

import UIKit
import Firebase

class BeerListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    
    //MARK: Outlets & Properties
    @IBOutlet weak var beerListSearchBar: UISearchBar!
    @IBOutlet weak var searchTypeSelector: UISegmentedControl!
    @IBOutlet weak var beerListTable: UITableView!
    
    //Singleton for the whole beer list
    var theBeerList = BeerList.sharedInstance
    
    
    //MARK: ViewController maintenance
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false

    }

    
    //MARK: Protocol Required Methods
    
    //Set number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.theBeerList.getBeerCount()
    }
    
    //Create a cell for each row in table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Try to get a cell of type SearchResultTableViewCell, otherwise catch the error
        guard let cell = self.beerListTable.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.BeerListing, for: indexPath) as? BeerListingTableViewCell
            else {
                fatalError("The dequeued cell is not an instance of BeerListingTableViewCell")
        }
        
        /* Create the listing using the old beer list model
        //Fetch the appropriate beer from the beer list
        let listing = theBeerList.theBeers[beerList.beerKeys[indexPath.row]]!
        
        
        //Populate cell with data
        cell.beerNumberLabel.text = "#\(listing.beerNumber!)"
        cell.beerNameLabel.text = listing.beerName*/
        
        return cell
    }

    //Resign first responder on search bar when search button is tapped
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

}

