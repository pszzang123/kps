//
//  DbFirebase.swift
//  kps
//
//  Created by mac035 on 6/18/24.
//

import Foundation
import FirebaseFirestore


class DbFirebase: Database{
    
    var reference: CollectionReference = Firestore.firestore().collection("cities")
    
    var parentNotification: (([String: Any]?, DbAction?)->Void)?
    var existQuery: ListenerRegistration?
    
    required init(parentNotification: (([String : Any]?, DbAction?) -> Void)?) {
        self.parentNotification = parentNotification
    }
    
    
    
    
    func setQuery(from: Any, to: Any) {
        if let query = existQuery{
            query.remove()
        }
        
        let query = reference.whereField("id", isGreaterThan: 0).whereField("id", isLessThan: 10000)
        
        existQuery = query.addSnapshotListener(onChangingData)
    }
    
    func saveChange(key: String, object: [String : Any], action: DbAction) {
        if action == .delete {
            reference.document(key).delete()
            return
        }
        reference.document(key).setData(object)
    }
    
    func onChangingData(querySnapShot: QuerySnapshot?, error: Error?){
        guard let querySnapshot = querySnapShot else {return}
        
        if(querySnapshot.documentChanges.count == 0){
            return
        }
        
        for documentChange in querySnapshot.documentChanges{
            let dict = documentChange.document.data()
            var action: DbAction?
            switch(documentChange.type){
            case .added: action = .add
            case .modified: action = .modify
            case .removed: action = .delete
            }
            
            if let parentNotification = parentNotification{parentNotification(dict, action)}
        }
    }
}
