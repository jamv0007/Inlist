//
//  ViewController.swift
//  Inlist
//
//  Created by Jose Antonio on 13/10/23.
//

import UIKit
import CoreData


class TodoViewController: UITableViewController {
    
    var elements: [ItemData] = [ItemData]()
    var categoryData: CategoryData? {
        didSet{
            loadItems()
            changeTitle()
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    let colorGradient = ["#005E6E","#008982","#3CB383","#52a32e"]
    
    
    
    @IBOutlet var searchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        searchBar.changeDarkLightTheme()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
            
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                searchBar.changeDarkLightTheme()
            }
    }
    
    func changeTitle(){
        let newTitle = categoryData?.name
        let titleModified = newTitle?.regulateTextTam(size: 15)
        title = titleModified
    }
    
    
    
    //MARK: - Metodos sobrescritos

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellId, for: indexPath)
        
        
        let strokeTextAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.white,
            .font : UIFont.boldSystemFont(ofSize: 20),
            ]
        
        cell.textLabel?.attributedText = NSAttributedString(string: elements[indexPath.row].name ?? "", attributes: strokeTextAttributes)
        

        cell.backgroundColor = UIColor(hex: self.colorGradient[indexPath.row % colorGradient.count])
        
        
       
        
        cell.accessoryType = .none
        
        if elements[indexPath.row].check {
            cell.accessoryType = .checkmark
        }

        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        elements[indexPath.row].check = !elements[indexPath.row].check
        
        tableView.cellForRow(at: indexPath)?.accessoryType = elements[indexPath.row].check ? .checkmark : .none
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        saveItems()
    }
    
    //Modificacion del estilo para borrar
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            context.delete(self.elements[indexPath.row])
            self.elements.remove(at: indexPath.row)
            saveItems()
            tableView.reloadData()
        }
    }

    //MARK: - IBActions
    
    @IBAction func addNewElement(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Nuevo elemento", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Añadir elemento", style: .default) { (action) in
            
            
            var item = ItemData(context: self.context)
            item.name = textField.text!
            item.check = false
            item.parentRelationshit = self.categoryData
            
            self.elements.append(item)
            
            self.saveItems()
            
            self.tableView.reloadData()
        }
        
        alert.addTextField(){ (textF) in
            textF.placeholder = "Nombre del elemento"
            textField = textF
        }
        alert.addAction(action)
        present(alert, animated: true)
        
        
    }
    
    //MARK: - Metodos propios
    
    func saveItems(){
        
        do{
            try self.context.save()
        }catch{
            print("Error al codificar: \(error)")
        }
    }
    
    func loadItems(request: NSFetchRequest<ItemData> = ItemData.fetchRequest(), predicate: NSPredicate? = nil){
        
        let parentPredicate = NSPredicate(format: "parentRelationshit.name MATCHES %@",categoryData?.name ?? "")
        
        if let otherPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [parentPredicate,otherPredicate])
        }else{
            request.predicate = parentPredicate
        }
        
        
        do{
            elements = try context.fetch(request)
        }catch{
            print("Error al cargar: \(error)")
        }
    }
    
}

extension UISearchBar{
    func changeDarkLightTheme(){
        if traitCollection.userInterfaceStyle == .light{
            
            self.searchTextField.backgroundColor = UIColor(red: 127/255, green: 202/255, blue: 196/255, alpha: 1)
            self.searchTextField.attributedPlaceholder = NSTextStorage(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 96/255, green: 121/255, blue: 122/255, alpha: 1),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)])
            self.searchTextField.textColor = UIColor.black
        }else{
            self.searchTextField.backgroundColor = UIColor(red: 40/255, green: 68/255, blue: 85/255, alpha: 1)
            self.searchTextField.attributedPlaceholder = NSTextStorage(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 150/255, green: 164/255, blue: 176/255, alpha: 1),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)])
            self.searchTextField.textColor = UIColor.white
        }
    }
}

extension TodoViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //1º se crea la peticion de busqueda
        let request: NSFetchRequest<ItemData> = ItemData.fetchRequest()
        //Se determina el predicado de busqueda
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        //Se crea una ordenacion por nombre y se ordena por este
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        //Se aplica la busqueda
        loadItems(request: request,predicate: predicate)
        
        //Se recarga la tabla
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            
            loadItems()
            
            tableView.reloadData()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}
    
extension String{
    
    func getFirstSubstring(size: Int) -> String{
        var cade = ""
        var cont = 0
        for charac in self{
            if cont >= size {
                break
            }
            
            cade.append(charac)
            cont += 1
        }
        
        return cade
    }
        
    func regulateTextTam(size: Int) -> String{
        if(size > 3){
            if self.count > size {
                let newText = (self.getFirstSubstring(size:size-3))
                return "\(newText)..."
            }
        }
        
        return self
    }
}


    




