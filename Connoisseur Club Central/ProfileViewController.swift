//
//  ProfileViewController.swift
//  Connoisseur Club Central
//
//  Created by Joeseidon, King of the Joecean on 3/30/17.
//  Copyright © 2017 Joeseidon, King of the Joecean. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //****
    //MARK: Outlets
    //****
    
    
    
    @IBOutlet weak var connoisseurIDLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var beersTriedLabel: UILabel!
    @IBOutlet weak var lovedBeersTable: UITableView!
    
    
    
    //****
    //MARK: Properties
    //****
    
    
    
    var theServer = Server.sharedInstance
    var authenticatedUser:Connoisseur = Connoisseur()
    var connoisseursFavoriteBeers:BeerList?
    
    
    
    //****
    //MARK: View Controller Maintenance
    //****
    
    
    
    //Set up visuals for the view when it loads
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        //Get authenticated user
        authenticatedUser = theServer.requestAuthenticatedUser()!
        
        //Set up lovedBeersTable
        updateFavoriteBeersList()
        lovedBeersTable.separatorColor = view.backgroundColor
        self.tabBarController?.automaticallyAdjustsScrollViewInsets = false

        
        //Set up Profile labels
        let connoisseurID = authenticatedUser.getID()
        let connoisseurFirstName = authenticatedUser.getFirstName()
        let connoisseurLastName = authenticatedUser.getLastName()
        let connoisseurBeersTried = authenticatedUser.getNumberOfBeersTried()
        updatePersonalInfoLabels(newID: String(connoisseurID), firstName: connoisseurFirstName, lastName: connoisseurLastName, newNumberTried: connoisseurBeersTried)
    }//viewDidLoad()
    
    
    //Set up different visuals for the view before it appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //Set up navigation item
        self.tabBarController?.navigationItem.title = "Profile"
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        self.tabBarController?.navigationItem.rightBarButtonItem = logoutButton
        self.tabBarController?.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationController?.isNavigationBarHidden = false
        
        //Set up beers tried label
        let connoisseurBeersTried = authenticatedUser.getNumberOfBeersTried()
        updateBeersTriedLabelText(newNumberTried: connoisseurBeersTried)
        
        //Set up favorite beers table
        updateFavoriteBeersList()
        lovedBeersTable.reloadData()
    }//viewWillAppear(_:)
    
    
    
    //****
    //MARK: Actions
    //****
    
    
    
    //Navigate to My Beers View
    @IBAction func userDidPressMyBeers(_ sender: Any) {
        performSegue(withIdentifier: Constants.Segues.MyBeers, sender: nil)
    }//userDidPressMyBeers(_:)

    
    
    //****
    //MARK: Table View Methods
    //****
    
    
    
    //Return 1 section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }//numberOfSections(in:)
    
    
    //Return the number of rows in the section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: //Only section
            if connoisseursFavoriteBeers?.getNumberOfBeers() == 0 { //If the connoisseur has no favorite beers, there will only be one cell
                return 1
            } else { //If the connoisseur has favorite beers, return the amount of favorite beers
                return (connoisseursFavoriteBeers?.getNumberOfBeers())!
            }
        default: //Case that something goes very, very wrong
            return 0
        }
    }//tableView(_:numberOfRowsInSection:)
    
    
    //Format and return a cell for the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Try to get a cell of type SearchResultTableViewCell, otherwise catch the error
        guard let cell = self.lovedBeersTable.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.BeerListing, for: indexPath) as? BeerListingTableViewCell
            else {
                fatalError("The dequeued cell is not an instance of BeerListingTableViewCell")
        } //guard/else
        
        if let beerForCell = connoisseursFavoriteBeers?.getAllBeersInList()?[indexPath.row] { //Case that there is a favorite beer for the given indexPath, update the cell accordingly
            
            //Error checking to make sure the connoisseur has actually rated the beer
            if let userRating = theServer.requestAuthenticatedUser()?.getRatingForBeer(withNumber: beerForCell.beerNumber!) {
                cell.updateRatingLabel(withRating: userRating)
            } else {
                cell.updateRatingLabel(withRating: nil)
            }
            
            //Set up cell visuals
            cell.selectionStyle = .none
            cell.updateBeerNumberLabel(withNumber: beerForCell.beerNumber)
            cell.updateBeerNameLabel(withName: beerForCell.beerName!, andBrewer: beerForCell.beerBrewer!)
            
        } else { //Case that there is no search result for the given indexPath (no search results), update the cell accordingly
            cell.updateBeerNameLabel(withName: "No favorite beers :(", andBrewer: "")
            cell.updateRatingLabel(withRating: nil)
            cell.updateBeerNumberLabel(withNumber: nil)
        }
        
        return cell
    }//tableView(_:cellForRowAt:)
    
    
    //Set section header title
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: //Only section
            return "Favorite Beers"
        default: //Case that something goes very, very wrong
            return ""
        }
    }//tableView(_:titleForHeaderInSection:)
    
    
    
    //****
    //MARK: Label Mutators
    //****
    
    
    
    //Calls update label function for each label
    func updatePersonalInfoLabels(newID id: String, firstName: String, lastName: String, newNumberTried num: Int) {
        updateIDLabelText(newID: id)
        updateNameLabelText(firstName: firstName, lastName: lastName)
        updateBeersTriedLabelText(newNumberTried: num)
    }//updatePersonalInfoLabels(newID:firstName:lastName:newNumberTried:)
    
    
    //Updates and formats attributed text (underlined, red) for ID label with the connoisseur's id
    func updateIDLabelText(newID id: String) {
        let idLength = id.characters.count
        let idString = NSMutableAttributedString(string: "Connoisseur #\(id)")
        let idRange = NSRange(location: 13, length: idLength)
        
        idString.addAttribute(NSUnderlineStyleAttributeName, value: 1, range: idRange)
        idString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: idRange)
        
        connoisseurIDLabel.attributedText = idString
    }//updateIDLabelText(newID:)
    
    
    //Updates and formats text for name label with the connoisseur's first and last names
    func updateNameLabelText(firstName: String, lastName: String) {
        nameLabel.text = lastName + ", " + firstName
    }//updateNameLabelText(firstName:lastName:)
    
    
    //Updates and formats the beers tried label text with the amount of beers that the connoisseur has tred
    func updateBeersTriedLabelText(newNumberTried num: Int) {
        let numLength = String(num).characters.count
        let beerString = NSMutableAttributedString(string: "Beers: \(String(num))")
        let numRange = NSRange(location: 7, length: numLength)
        
        beerString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: numRange)
        
        beersTriedLabel.attributedText = beerString
    }//updateBeersTriedLabelText(newNumberTried:)
    
    
    
    //****
    //MARK: Helper Functions
    //****
    
    
    
    //Log the connoisseur out, return to login view
    func logout() {
        theServer.revokeAuthentication()
        NotificationCenter.default.post(name: .requestLogout, object: nil)
    }//logout()
    
    
    //Refresh the list of the connoisseur's favorite beers, sorted chronologically
    func updateFavoriteBeersList() -> Void {
        connoisseursFavoriteBeers = BeerList()
        if let connoisseursLovedBeers = authenticatedUser.getAllBeerNumbersTried(sorted: .Chronologically, withRating: .Love) {
            for num in connoisseursLovedBeers {
                if let triedBeer = theServer.requestBeer(withNumber: num) {
                    connoisseursFavoriteBeers?.addBeer((num,triedBeer))
                }//if
            }//for
        }//if
    }//updateFavoriteBeersList()
}
