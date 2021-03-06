import UIKit
import RealmSwift
import ChameleonFramework
import SwipeCellKit

protocol CanReceiveTransaction {
    
    func dataReceivedTransactionsTable(dataTransaction: String)
    
}

class TransactionsTableViewController: UITableViewController {
    
    var transactions: Results<Transactions>?
    
    var delegateTransaction: CanReceiveTransaction?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        getTransactions()
        
        tableView.reloadData()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return transactions?.count ?? 1
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SwipeTableViewCell
        
        if let transaction = transactions?[indexPath.row] {
            
            // kategorie wyswietlaja sie jako tablica - musimy zrzutowac na NSArray i pobrac pierwszy element
            let categoryNameObject = transaction.parentCategories.value(forKey: "categoryName") as? NSArray
            
            if transaction.income != 0.0 {
                
                cell.textLabel?.text = "Data: \(convertDateToString(date: transaction.dataTransaction) ?? "")"
                cell.detailTextLabel?.numberOfLines = 6;
                
                cell.detailTextLabel?.text =
                    
                "Przychód: \(transaction.income) PLN \nKategoria: \(categoryNameObject?.firstObject ?? "") \nOpis: \(transaction.note)"
                
                cell.textLabel?.textColor = UIColor.flatGreenDark
                cell.detailTextLabel?.textColor = UIColor.flatGreenDark
                
            } else {
                
                cell.textLabel?.text = "Data: \(convertDateToString(date: transaction.dataTransaction) ?? "")"
                cell.detailTextLabel?.numberOfLines = 3;
                
                cell.detailTextLabel?.text =
                    
                "Wydatek: \(transaction.expense) PLN \nKategoria: \(categoryNameObject?.firstObject ?? "") \nOpis: \(transaction.note)"
                
                cell.textLabel?.textColor = UIColor.flatRedDark
                cell.detailTextLabel?.textColor = UIColor.flatRedDark
                
            }
            
        }
        
        cell.delegate = self
        
        return cell
        
    }
    
    func getTransactions() {
        
        let realm = try! Realm()
        
        transactions = realm.objects(Transactions.self).sorted(byKeyPath: "dataTransaction", ascending: false)
        
    }
    
}

// usuwanie wybranej transakcji
extension TransactionsTableViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            let realm = try! Realm()
            
            let accountResults = realm.objects(Account.self)
            
            if let account = accountResults.first {
                
                try! realm.write {
                    
                    if self.transactions?[indexPath.row].income != 0 {
                        
                        account.balance = account.balance - (self.transactions?[indexPath.row].income ?? 0.0)
                        
                    } else {
                        
                        account.balance = account.balance + (self.transactions?[indexPath.row].expense ?? 0.0)
                        
                    }
                    
                    realm.add(account, update: true)
                    
                    realm.delete((self.transactions?[indexPath.row])!)
                    
                }
                
            }
            
            tableView.reloadData()
            
            self.delegateTransaction?.dataReceivedTransactionsTable(dataTransaction: "")
            
        }
        
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
        
    }
    
}

extension UIViewController {
    
    // zamiana string na date
    func convertStringtToDate(strDate: String) -> Date! {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let date = dateFormatter.date(from: strDate)
        
        return date
        
    }
    
    // zamiana daty na string
    func convertDateToString(date : Date ) -> String! {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let string = dateFormatter.string(from: date)
        
        return string
        
    }
    
}
