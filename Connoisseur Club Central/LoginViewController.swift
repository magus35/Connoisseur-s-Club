//
//  LoginViewController.swift
//  Connoisseur Club Central
//
//  Created by Joeseidon, King of the Joecean on 5/11/17.
//  Copyright © 2017 Joeseidon, King of the Joecean. All rights reserved.
//

import UIKit
import Firebase

//Define a notification name used for listening to logout requests
extension Notification.Name {
    static let requestLogout = Notification.Name("RequestLogOut")
}


class LoginViewController: UIViewController, UITextFieldDelegate {
    //****
    //MARK: Outlets
    //****
    
    
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    
    
    //****
    //MARK: Properties
    //****
    
    
    
    var ref: DatabaseReference!
    var theServer = Server.sharedInstance
    
    
    
    //****
    //MARK: View Controller Methods
    //****

    
    
    //Register sample users and add a logout observer when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        registerSampleUsers()
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveRequestForLogout(notification:)), name: .requestLogout, object: nil)
    }//viewDidLoad()
    
    
    //Hide the navigation bar, but also set the color of the navigation for children view controllers
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.barTintColor = Constants.Colors.navigationItem
    }//viewWillAppear(_:)
    
    
    //Remove the notification observer
    deinit {
        NotificationCenter.default.removeObserver(self)
    }//deinit
    
    
    
    //****
    //MARK: Text Field Methods
    //****
    
    
    
    //Set up the behavior of the return button for each text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField { //Case that the text field that should return is the username field
            passwordField.becomeFirstResponder()
        } else if textField == passwordField { //Case that the text field that should return is the password field
            if inputIsValid() { //If the user entered text into each field, attempt to log the connoisseur in with the entered credentials
                let connoisseurCredentials = Credentials(username: usernameField.text!, password: passwordField.text!)
                if let _ = theServer.authenticateUser(withCredentials: connoisseurCredentials) { //Case that credentials are valid
                    statusLabel.text = ""
                    statusLabel.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0)
                    performSegue(withIdentifier: Constants.Segues.login, sender: nil)
                } else { //Case that credentials are invalid
                    statusLabel.text = "Please enter valid credentials"
                    statusLabel.backgroundColor = Constants.Colors.loginLabel
                }//if-else
            } else { //Case that user didn't enter text into both fields
                statusLabel.text = "Please enter username and password"
                statusLabel.backgroundColor = Constants.Colors.loginLabel
            }//if-else
        }//if-else
        textField.resignFirstResponder()
        return true
    }//textFieldShouldReturn(_:)
    
    
    
    //****
    //MARK: Actions & Gestures
    //****
    
    
    
    //Attempt to log the user in with the credentials entered if the user taps login
    @IBAction func userDidTapLogin(_ sender: UIButton) {
        if inputIsValid() { //Case that the user entered text into both text fields
            let connoisseurCredentials = Credentials(username: usernameField.text!, password: passwordField.text!)
            if let _ = theServer.authenticateUser(withCredentials: connoisseurCredentials) { //case that the user entered valid credentials
                statusLabel.text = ""
                statusLabel.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0)
                performSegue(withIdentifier: Constants.Segues.login, sender: nil)
            } else { //case that the user didn't enter valid credentials
                statusLabel.text = "Please enter valid credentials"
                statusLabel.backgroundColor = Constants.Colors.loginLabel
            }//if-else
        } else { //Case that the user didn't enter text into both text fields
            statusLabel.text = "Please enter username and password"
            statusLabel.backgroundColor = Constants.Colors.loginLabel
        }//if-else
    }//userDidTapLogin(_:)
    
    
    //Handles taps, dismisses keyboard if user taps on view with keyboard presented
    @IBAction func userDidTap(_ sender: UITapGestureRecognizer) {
        if usernameField.isFirstResponder {
            usernameField.resignFirstResponder()
        } else if passwordField.isFirstResponder {
            passwordField.resignFirstResponder()
        }
    }//userDidTap(_:)
    
    
    
    /*
     //Firebase testing
     @IBAction func userDidThing(_ sender: Any) {
        let username = usernameField.text!
        self.ref.child("users").child(username).setValue("value")
    }*/
    
    
    
    //****
    //MARK: Helper functions
    //****
    
    
    
    //Check if there is text in each text field
    func inputIsValid() -> Bool {
        if usernameField.text == "" || passwordField.text == "" {
            return false
        } else {
            return true
        }
    }//inputIsValid()
    
    
    //Method to be called when the user taps logout from the Profile
    func didReceiveRequestForLogout(notification: Notification) -> Void {
        navigationController?.popToRootViewController(animated: true)
    }//didReceiveRequestForLogout(notification:)
    
    
    //Registers sample users in the mock server
    //CREDENTIALS:
    //admin/pass - prepopulated with tried beers
    //joeseidon/notpass - not prepopulated with tried beers
    //cschatz/thumper - not prepopulated with tried beers
    func registerSampleUsers() -> Void {
        var sampleCredentials:[Credentials] = []
        sampleCredentials.append(Credentials(username: "admin", password: "pass"))
        sampleCredentials.append(Credentials(username: "joeseidon", password: "notpass"))
        sampleCredentials.append(Credentials(username: "cschatz", password: "thumper"))
        
        for creds in sampleCredentials {
            theServer.registerConnoisseur(withCredentials: creds)
        }
        
        let conn1 = theServer.requestConnoisseur(withCredentials: sampleCredentials[0])
        conn1?.setConnoisseurID(newID: 1000)
        conn1?.setName(newFirstName: "John", newLastName: "Smith")
        conn1?.tryBeer(withNumber: 50, rating: .Meh)
        conn1?.tryBeer(withNumber: 432, rating: .Good)
        conn1?.tryBeer(withNumber: 1111, rating: .Bad)
        conn1?.tryBeer(withNumber: 2500, rating: .Good)
        conn1?.tryBeer(withNumber: 1734, rating: .Love)
        
        let conn2 = theServer.requestConnoisseur(withCredentials: sampleCredentials[1])
        conn2?.setConnoisseurID(newID: 666)
        conn2?.setName(newFirstName: "Joe", newLastName: "Schmo")
        
        let conn3 = theServer.requestConnoisseur(withCredentials: sampleCredentials[2])
        conn3?.setConnoisseurID(newID: 1337)
        conn3?.setName(newFirstName: "Colin", newLastName: "Schatz")
    }//registerSampleUsers()
}
