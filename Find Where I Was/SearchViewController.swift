//
//  SearchViewController.swift
//  Where Was I
//
//  Created by Glenn McCartney on 24/11/2015.
//  Copyright © 2015 Glenn McCartney. All rights reserved.
//

import UIKit

protocol SearchDelegate {
    func deleteMarker(data: String)
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
       
    
    @IBAction func backButtonTapped(sender: AnyObject) {
          self.performSegueWithIdentifier("unwindSearchIdentifier", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationController?.navigationBar.translucent = false
        
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        
        self.resultSearchController.dimsBackgroundDuringPresentation    = false
        self.resultSearchController.searchBar.sizeToFit()
        self.resultSearchController.searchBar.placeholder = "Search Marked Locations"
        
        myTableView.tableHeaderView = self.resultSearchController.searchBar
        
        
        myTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.resultSearchController.active
        {
            return self.filteredarrMarkedLocationNames.count
        }
        else
        {
            return self.arrMarkedLocationNames.count
        }
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell?
        
        if self.resultSearchController.active
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
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        self.filteredarrMarkedLocationNames.removeAll(keepCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        
        let array = (self.arrMarkedLocationNames as NSArray).filteredArrayUsingPredicate(searchPredicate)
        
        self.filteredarrMarkedLocationNames = array as! [String]
        
        myTableView.reloadData()
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
        
        print ("You clicked on \(currentCell.textLabel?.text)")
        
        selectedMark = currentCell.textLabel?.text
        
        self.performSegueWithIdentifier("unwindSearchIdentifier", sender: self)
        
    }
   
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    
    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            /*
            // Delete the row from the data source
            arrMarkedLocationNames.removeAtIndex(indexPath.row)
            let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
            delegate?.deleteMarker((currentCell.textLabel?.text)!)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            */
            
            
        } else if editingStyle == .Insert {
            
            
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        
       
    }


    
    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .Normal, title: "Edit") { (rowAction:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
            //TODO: edit the row at indexPath here
            print ("Edit")
            
            self.OpenMarkerDetailsForEdit = true
            
            let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
            self.selectedMark = currentCell.textLabel?.text
            
            self.performSegueWithIdentifier("unwindSearchIdentifier", sender: self)
            
            
            
        }
        editAction.backgroundColor = UIColor.blueColor()
        
        
        let deleteAction = UITableViewRowAction(style: .Normal, title: "Delete") { (rowAction:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
            //TODO: Delete the row at indexPath here
            
            // Delete the row from the data source
            self.arrMarkedLocationNames.removeAtIndex(indexPath.row)
            let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
            self.delegate?.deleteMarker((currentCell.textLabel?.text)!)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            
        }
        deleteAction.backgroundColor = UIColor.redColor()
        
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
