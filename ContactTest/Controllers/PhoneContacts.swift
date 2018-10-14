//
//  PhoneContacts.swift
//  ContactTest
//
//  Created by Amir Daliri on 7/22/1397 AP.
//  Copyright © 1397 AmirDaliri. All rights reserved.
//

import Foundation
import ContactsUI


enum ContactsFilter {
    case none
    case mail
    case message
}

class PhoneContacts {
    
    class func getContacts(filter: ContactsFilter = .none) -> [CNContact] { 
        
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching containers")
            }
        }
        return results
    }
}
