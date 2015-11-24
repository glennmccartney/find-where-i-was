//
//  SearchTableViewController.swift
//  Where Was I
//
//  Created by Glenn McCartney on 23/11/2015.
//  Copyright © 2015 Glenn McCartney. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchResultsUpdating {

    
    var arrMarkedLocationNames = [] as [String]
    
    var filteredarrMarkedLocationNames = [String]()
    var resultSearchController = UISearchController()
    var MarkedPointArr = [] as [MarkedPoint]
    var selectedMark : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.navigationController?.navigationBar.translucent = false
        
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        
        self.resultSearchController.dimsBackgroundDuringPresentation    = false
        self.resultSearchController.searchBar.sizeToFit()
        
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        
      
        
        self.tableView.reloadData()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
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
        
        self.tableView.reloadData()
    }
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
        
        //print (currentCell.textLabel?.text)
     
        //print ("You clicked on \(MarkedPointArr[indexPath.row].name)")
        
         print ("You clicked on \(currentCell.textLabel?.text)")
        
        selectedMark = currentCell.textLabel?.text
        
        self.performSegueWithIdentifier("unwindSearchIdentifier", sender: self)
        
    }
    
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
