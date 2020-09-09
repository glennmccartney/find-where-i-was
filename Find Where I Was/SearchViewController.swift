//
//  SearchViewController.swift
//  Where Was I
//
//  Created by Glenn McCartney on 24/11/2015.
//  Copyright © 2015 Glenn McCartney. All rights reserved.
//

import UIKit

protocol SearchDelegate {
    func deleteMarker(_ data: String)
}

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {

    var delegate: SearchDelegate?
    
    var arrMarkedLocationNames = [] as [String]
    
    var filteredarrMarkedLocationNames = [String]()
    var resultSearchController = UISearchController()
    var MarkedPointArr = [] as [MarkedPoint]
    var selectedMark : String?
    var OpenMarkerDetailsForEdit: Bool = false
    
    @IBOutlet weak var myTableView: UITableView!
       
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
          self.performSegue(withIdentifier: "unwindSearchIdentifier", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationController?.navigationBar.translucent = false
        
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        
        //self.resultSearchController.dimsBackgroundDuringPresentation    = false
        self.resultSearchController.searchBar.sizeToFit()
        self.resultSearchController.searchBar.placeholder = "Search Marked Locations"
        
        myTableView.tableHeaderView = self.resultSearchController.searchBar
        
        //To suit dark mode...
        if #available(iOS 13.0, *) {
            myTableView.overrideUserInterfaceStyle = .light
        }
        
        myTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.resultSearchController.isActive
        {
            return self.filteredarrMarkedLocationNames.count
        }
        else
        {
            return self.arrMarkedLocationNames.count
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell?
        
        //  06/05/2016 - Font changed
        cell!.textLabel!.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        //UIFont(name:"Avenir", size:14)
        
        
        if self.resultSearchController.isActive
        {
            
            cell?.textLabel?.text = self.filteredarrMarkedLocationNames[indexPath.row]
        }
        else
        {
            cell?.textLabel?.text = self.arrMarkedLocationNames[indexPath.row]
        }
        
        // Configure the cell...
        return cell!
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        
        self.filteredarrMarkedLocationNames.removeAll(keepingCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        
        let array = (self.arrMarkedLocationNames as NSArray).filtered(using: searchPredicate)
        
        self.filteredarrMarkedLocationNames = array as! [String]
        
        myTableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        
        print ("You clicked on \(String(describing: currentCell.textLabel?.text))")
        
        selectedMark = currentCell.textLabel?.text
        
        self.performSegue(withIdentifier: "unwindSearchIdentifier", sender: self)
        
    }
   
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            /*
            // Delete the row from the data source
            arrMarkedLocationNames.removeAtIndex(indexPath.row)
            let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
            delegate?.deleteMarker((currentCell.textLabel?.text)!)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            */
            
            
        } else if editingStyle == .insert {
            
            
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        
       
    }


    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (rowAction:UITableViewRowAction, indexPath:IndexPath) -> Void in
            //TODO: edit the row at indexPath here
            print ("Edit")
            
            self.OpenMarkerDetailsForEdit = true
            
            let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
            self.selectedMark = currentCell.textLabel?.text
            
            self.performSegue(withIdentifier: "unwindSearchIdentifier", sender: self)
        }
        
        editAction.backgroundColor = UIColor.blue
        
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction:UITableViewRowAction, indexPath:IndexPath) -> Void in
            //TODO: Delete the row at indexPath here
            
            // Delete the row from the data source
            self.arrMarkedLocationNames.remove(at: indexPath.row)
            let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
            self.delegate?.deleteMarker((currentCell.textLabel?.text)!)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleteAction.backgroundColor = UIColor.red
        
        return [editAction,deleteAction]
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
