//
//  CategoryViewController.swift
//  Inlist
//
//  Created by Jose Antonio on 15/10/23.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categories: [CategoryData] = [CategoryData]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var searchCategory: UISearchBar!
    
    let categoryColor = ["#314E6D","#5F668E","#927DAB","#C795C1"]

    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        tableView.rowHeight = 80
        searchCategory.changeDarkLightTheme()
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
            
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                searchCategory.changeDarkLightTheme()
            }
    }
    
    //MARK: - Add button funcionality
    @IBAction func addCategoryButton(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Nueva categoria", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Añadir categoria", style: .default){ (action) in
            
            var category: CategoryData = CategoryData(context: self.context)
            category.name = textField.text!
            
            self.categories.append(category)
            
            self.saveItems()
            
            self.tableView.reloadData()
            
        }
        
        let quitAction = UIAlertAction(title: "Cancelar", style: .cancel)
        quitAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addTextField(){ (textF) in
            textF.placeholder = "Nombre de la categoria"
            textField = textF
        }
        
        alert.addAction(action)
        alert.addAction(quitAction)
        present(alert, animated: true)
    
    }
    
    // MARK: - Table view data
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellCategoryId, for: indexPath)
        
        let strokeTextAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.white,
            .font : UIFont.boldSystemFont(ofSize: 20),
            ]
        
        cell.textLabel?.attributedText = NSAttributedString(string: categories[indexPath.row].name ?? "", attributes: strokeTextAttributes)
        

        cell.backgroundColor = UIColor(hex: self.categoryColor[indexPath.row % categoryColor.count])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.goToList, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            context.delete(categories[indexPath.row])
            categories.remove(at: indexPath.row)
            saveItems()
            tableView.reloadData()
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Para el segue
        if segue.identifier == Constants.goToList {
            //Si el destino es el siguiente view Controller
            if let listElements = segue.destination as? TodoViewController {
                //Se obtiiene el id de la siguiente
                if let indexPath = tableView.indexPathForSelectedRow {
                    listElements.categoryData = categories[indexPath.row]
                }
            }
        }
    }
    
    
    
    //MARK: - Metodos propios
    
    func saveItems(){
        
        do{
            try self.context.save()
        }catch{
            print("Error al codificar: \(error)")
        }
    }
    
    func loadItems(request: NSFetchRequest<CategoryData> = CategoryData.fetchRequest(), predicate: NSPredicate? = nil){
        
        if let addPredicate = predicate{
            request.predicate = predicate
        }
        
        do{
            categories = try context.fetch(request)
        }catch{
            print("Error al cargar: \(error)")
        }
    }
    
    
    
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(red: CGFloat(r)/CGFloat(255), green: CGFloat(g)/CGFloat(255), blue: CGFloat(b)/CGFloat(255), alpha: CGFloat(a)/CGFloat(255))
    }
}


//MARK: - Search bar extension
extension CategoryViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //1º se crea la peticion de busqueda
        let request: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()
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



