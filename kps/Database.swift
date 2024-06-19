//
//  Database.swift
//  kps
//
//  Created by mac035 on 6/18/24.
//

import Foundation


enum DbAction{
    case add, delete, modify
}


protocol Database{
    
    init(parentNotification: (([String: Any]?, DbAction?)->Void)?)
    
    func setQuery(from: Any, to: Any)
    
    func saveChange(key: String, object: [String:Any], action: DbAction)
    
    
    
}
