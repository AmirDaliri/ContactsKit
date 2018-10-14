//
//  ViewController.swift
//  ContactTest
//
//  Created by Amir Daliri on 7/22/1397 AP.
//  Copyright © 1397 AmirDaliri. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var phoneContacts = [PhoneContact]()
    var filter: ContactsFilter = .none
    var collectionArray = [String]()
    
    var store = CNContactStore()
    var contacts: [CNContact] = []

    var searched = false
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // I'm Here...
        AppDelegate.sharedDelegate().checkAccessStatus { (accessGranted) in
            if accessGranted {
                DispatchQueue.main.async {
                    self.loadContacts(filter: self.filter)
                }
            } else {
                print("you not have permision")
            }
        }
    }
    
    //MARK: - All Contact

    fileprivate func loadContacts(filter: ContactsFilter) {
        phoneContacts.removeAll()
        var allContacts = [PhoneContact]()
        for contact in PhoneContacts.getContacts(filter: filter) {
            allContacts.append(PhoneContact(contact: contact))
        }
        
        var filterdArray = [PhoneContact]()
        if self.filter == .mail {
            filterdArray = allContacts.filter({ $0.email.count > 0 }) // getting all email
        } else if self.filter == .message {
            filterdArray = allContacts.filter({ $0.phoneNumber.count > 0 })
        } else {
            filterdArray = allContacts
        }
        phoneContacts.append(contentsOf: filterdArray)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    //MARK: - search
    
    func findContactsWithName(name: String) {
        AppDelegate.sharedDelegate().checkAccessStatus(completionHandler: { (accessGranted) -> Void in
            if accessGranted {
                DispatchQueue.main.async {
                    do {
                        let predicate: NSPredicate = CNContact.predicateForContacts(matchingName: name)
                        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactBirthdayKey, CNContactViewController.descriptorForRequiredKeys()] as [Any]
                        self.contacts = try self.store.unifiedContacts(matching: predicate, keysToFetch:keysToFetch as! [CNKeyDescriptor])
                        self.searched = true
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    catch {
                        print("Unable to refetch the selected contact.")
                    }
                }
            }
        })
    }


}

// MARK: - UITableView Methode

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searched {
            return contacts.count
        } else {
            return self.phoneContacts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        if searched {
            cell.textLabel!.text = contacts[indexPath.row].givenName + " " + contacts[indexPath.row].familyName
            if let birthday = contacts[indexPath.row].birthday {
                let formatter = DateFormatter()
                formatter.dateStyle = DateFormatter.Style.long
                formatter.timeStyle = .none
                cell.detailTextLabel?.text = formatter.string(from: (birthday.date)!)
            }
        } else {
            cell.textLabel?.text = self.phoneContacts[indexPath.row].name ?? ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if searched {
            let choosed = contacts[indexPath.row].givenName + " " + contacts[indexPath.row].familyName
            self.collectionArray.append(choosed)
        } else {
            self.collectionArray.append(self.phoneContacts[indexPath.row].name ?? "is null")
        }
        self.collectionView.reloadData()
    }
}

// MARK: - UICollectionView Methode

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CollectionViewCell = (collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath as IndexPath) as? CollectionViewCell)!
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.cornerRadius = 12
        cell.layer.masksToBounds = true
        cell.nameLabel.text = self.collectionArray[indexPath.row]
        return cell
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.searched = false
            self.loadContacts(filter: .none)
        } else {
            self.findContactsWithName(name: searchText)
        }
    }

    //    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    //        if let query = searchBar.text {
    //            self.findContactsWithName(name: query)
    //        }
    //    }

}
