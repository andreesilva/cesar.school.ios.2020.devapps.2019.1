//
//  ConsolesManager.swift
//  MyGames
//
//  Created by Douglas Frari on 16/05/20.
//  Copyright © 2020 Douglas Frari. All rights reserved.
//

import CoreData

final class ConsolesManager {
   
    static let shared = ConsolesManager()
    var consoles: [Console] = []
   
    // usando padrao de projeto Singleton
    private init() {
       
    }
    
    func loadConsoles(with context: NSManagedObjectContext) {
        
        let fetchRequest: NSFetchRequest<Console> = Console.fetchRequest()
        
        // equivalente ao SQL 'where'
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
       
        do {
            // equivalente ao SELECT * FROM TABLE 
            consoles = try context.fetch(fetchRequest)
        } catch  {
            print(error.localizedDescription)
        }
    }
   
   
    func deleteConsole(index: Int, context: NSManagedObjectContext) {
        let console = consoles[index]
        context.delete(console)
       
        do {
            try context.save()
            consoles.remove(at: index)
        } catch  {
            print(error.localizedDescription)
        }
    }
   
    
}
