//
//  ConsolesTableViewController.swift
//  MyGames
//
//  Created by Douglas Frari on 16/05/20.
//  Copyright © 2020 Douglas Frari. All rights reserved.
//

import UIKit
import CoreData

class ConsolesTableViewController: UITableViewController {
    
    // esse tipo de classe oferece mais recursos para monitorar os dados
    var fetchedResultController:NSFetchedResultsController<Console>!
    
    var label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // mensagem default
        label.text = "Você não tem plataformas cadastradas"
        label.textAlignment = .center
        
        loadConsoles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // recarrega os dados da tabela quando a tela aparecer
        tableView.reloadData()
    }
    
    func loadConsoles() {
        let fetchRequest: NSFetchRequest<Console> = Console.fetchRequest()
        
        // definindo criterio da ordenacao de como os dados serao entregues
        let consoleNameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [consoleNameSortDescriptor]
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch  {
            print(error.localizedDescription)
        }
        
        //ConsolesManager.shared.loadConsoles(with: context)
        //tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let count = fetchedResultController?.fetchedObjects?.count ?? 0
        
        tableView.backgroundView = count == 0 ? label : nil
        
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "consoleCell", for: indexPath) as! ConsoleTableViewCell
        
        guard let console = fetchedResultController.fetchedObjects?[indexPath.row] else {
            return cell
        }
        
        cell.prepare(with: console)
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            guard let console = fetchedResultController.fetchedObjects?[indexPath.row] else {
                print("Nao foi possivel obter a Plataforma da linha selecionada para deletar")
                return
            }
            context.delete(console) // foi escalado para ser deletado, mas precisamos confirmar com save
            
            do {
                try context.save()
                // efeito visual deletar poderia ser feito aqui, porem, faremos somente se o banco de dados
                //reagir informando que ocorreu uma mudanca (NSFetchedResultsControllerDelegate)
            } catch  {
                print(error.localizedDescription)
            }
        }
        
        //ConsolesManager.shared.deleteConsole(index: indexPath.row, context: context)
        //tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier! == "editConsoleSegue" {
            print("editConsoleSegue")
            let vc = segue.destination as! ConsoleAddEditViewController
            
            if let consoles = fetchedResultController.fetchedObjects {
                vc.console = consoles[tableView.indexPathForSelectedRow!.row]
            }
            
        } else if segue.identifier! == "consoleSegue" {
            print("consoleSegue")
        }
    }
    

//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        let console = ConsolesManager.shared.consoles[indexPath.row]
//        //showAlert(with: console)
//
//        // deselecionar atual cell
//        tableView.deselectRow(at: indexPath, animated: false)
//     }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

//    func showAlert(with console: Console?) {
//        let title = console == nil ? "Adicionar" : "Editar"
//        let alert = UIAlertController(title: title + " plataforma", message: nil, preferredStyle: .alert)
//
//        alert.addTextField(configurationHandler: { (textField) in
//            textField.placeholder = "Nome da plataforma"
//
//            if let name = console?.name {
//                textField.text = name
//            }
//        })
//
//        alert.addAction(UIAlertAction(title: title, style: .default, handler: {(action) in
//            let console = console ?? Console(context: self.context)
//            console.name = alert.textFields?.first?.text
//            do {
//                try self.context.save()
//                self.loadConsoles()
//            } catch {
//                print(error.localizedDescription)
//            }
//        }))
//
//        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
//        alert.view.tintColor = UIColor(named: "second")
//
//        present(alert, animated: true, completion: nil)
//    }
    
    
//    @IBAction func addConsole(_ sender: UIBarButtonItem) {
//        print("addConsole")
//
//        // nil indica que sera criado uma plataforma nova
//        showAlert(with: nil)
//    }
    
    
} // fim da classe

extension ConsolesTableViewController: NSFetchedResultsControllerDelegate {
    
    // sempre que algum objeto for modificado esse metodo sera notificado
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
        default:
            tableView.reloadData()
        }
    }
}
