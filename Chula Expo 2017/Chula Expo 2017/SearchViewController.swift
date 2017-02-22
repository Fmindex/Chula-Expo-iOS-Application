//
//  SearchViewController.swift
//  Chula Expo 2017
//
//  Created by Ekkalak Leelasornchai on 2/3/2560 BE.
//  Copyright © 2560 Chula Computer Engineering Batch#41. All rights reserved.

import UIKit
import CoreData

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UISearchBarDelegate {

    
    var managedObjectContext: NSManagedObjectContext? =
        (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
    
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var Events = [ActivityData]()
    let searchController = UISearchController(searchResultsController: nil)
    
    var ShouldShowResult = false
    var fetchActivity = [ActivityData]()
   

    /*func filterContentForSearchText(searchText: String, scope: String = "All"){
        filterEvents = Events.filter{ ActivityData in
              //  return (ActivityData.name?.lowercased()
        }
        tableView.reloadData()
     
    }*/
    //@IBOutlet var tableHeader: TableHeaderView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
           /* var name: String?
            var toRound: NSSet?
            var thumbnail: String?
            var facity: String?
            fetchData.managedObjectContext?.performAndWait{
                // it's easy to forget to do this on the proper queue
                name = fetchData.name
                thumbnail = fetchData.thumbnailsUrl
                facity = fetchData.faculty
                toRound = fetchData.toRound
                // we're not assuming the context is a main queue context
                // so we'll grab the screenName and return to the main queue
                // to do the cell.textLabel?.text setting
            }
            print("feedCell name == \(name)")
            if let eventFeedCell = cell as? EventfeedTableViewCell{
                print("feedCell name == \(name)")
                eventFeedCell.name = name
                eventFeedCell.toRound = toRound
                eventFeedCell.thumbnail = thumbnail
                eventFeedCell.facity = facity
            }
        }
             */
        
        requestForFeedEvent()
        self.navigationController?.navigationBar.isTranslucent = false
        // ย้ายตำแหน่งลงมาข้างล่างมันยังบัคต้องหาวิธีอื่น
//        tableView.contentInset = UIEdgeInsetsMake(((self.navigationController?.navigationBar.frame)?.height)! + (self.navigationController?.navigationBar.frame)!.origin.y, 0.0,  ((self.tabBarController?.tabBar.frame)?.height)!, 0);

        //navigationController?.navigationBar.barTintColor = UIColor.white
       // homeTableView.tableFooterView = UIView(frame: CGRect.zero)
       // searchBar.showsCancelButton = true
        searchBar.placeholder = "ค้นหากิจกรรม"
       // searchBar.barStyle = UIBarStyle.blackOpaque
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        /*searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar*/
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if segue.identifier == "toEventDetails" {
            
            if let destination = segue.destination as? EventDetailTableViewController{
                
                if let eventcell = sender as? EventFeedCell?{
                    
                    if let id = eventcell?.activityId{
                        
                        if let fetch = ActivityData.fetchActivityDetails(activityId: id, inManageobjectcontext: managedObjectContext!){
                            
                            destination.activityId = fetch.activityId
                            destination.bannerUrl = fetch.bannerUrl
                            destination.topic = fetch.name
                            destination.locationDesc = ""
                            destination.toRounds = fetch.toRound
                            destination.desc = fetch.desc
                            destination.room = fetch.room
                            destination.place = fetch.place
                            destination.latitude = fetch.latitude
                            destination.longitude = fetch.longitude
                            destination.pdf = fetch.pdf
                            destination.toImages = fetch.toImages
                            destination.toTags = fetch.toTags
                            destination.managedObjectContext = self.managedObjectContext
                        }
                    }
                }                
            }
        }
    }
    

    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        ShouldShowResult = true
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.showsCancelButton = false
        ShouldShowResult = false
        self.tableView.reloadData()
        // Remove focus from the search bar.
        searchBar.endEditing(true)
        
        // Perform any necessary work.  E.g., repopulating a table view
        // if the search bar performs filtering.
    }
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            do {
                if let frc = fetchedResultsController {
                    frc.delegate = self
                    try frc.performFetch()
                }
                tableView.reloadData()
            } catch let error {
                print("NSFetchedResultsController.performFetch() failed: \(error)")
            }
        }
    }

    func requestForFeedEvent(){
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ActivityData")
        request.predicate = NSPredicate(format: "isStageEvent = %@", NSNumber(booleanLiteral: false))
        request.sortDescriptors = [NSSortDescriptor(
            key: "activityId",
            ascending: true
            )]
        if let context = managedObjectContext {
            
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
       // filterEvents =
        managedObjectContext?.performAndWait {
            self.fetchActivity = ActivityData.fetchActivityFromSearch(name: searchText, inManageobjectcontext: self.managedObjectContext!)
        }
        
        self.tableView.reloadData()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        tableView.reloadData()
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        if(ShouldShowResult){
            return 1
        }
        else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(ShouldShowResult) {
            return fetchActivity.count
        }
        else{
                if(section == 1){
                    if let i = fetchedResultsController?.sections?[0]{
                        return i.numberOfObjects+1
                    }
                }

                return 2
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        if(ShouldShowResult){
            cell = tableView.dequeueReusableCell(withIdentifier: "EventSearchFeed", for: indexPath)
            if let eventFeedCell = cell as? EventFeedCell{
              //  print("feedCell name == \(name)")
                eventFeedCell.manageObjectContext = managedObjectContext
                eventFeedCell.name = fetchActivity[indexPath.row].name
                eventFeedCell.toRound = fetchActivity[indexPath.row].toRound
                eventFeedCell.thumbnail = fetchActivity[indexPath.row].thumbnailsUrl
                eventFeedCell.facity = fetchActivity[indexPath.row].faculty
                
            }
        }
        else {
        
                if indexPath.section == 0 && indexPath.row == 0 {
                    cell = tableView.dequeueReusableCell(withIdentifier: "HeaderSearch", for: indexPath)
                    if let headerCell = cell as? HeaderSearchTableViewCell{
                        headerCell.title1 = "WHERE AM I ?"
                        headerCell.title2 = "แนะนำ Events จากสถานที่ปัจจุบันของคุณ"
                        headerCell.iconImage = "heartIcon"
                    }
                    cell.selectionStyle = .none
                }
                else if indexPath.section == 0 && indexPath.row == 1 {
        
                    /*cell = tableView.dequeueReusableCell(withIdentifier: "Map", for: indexPath)
                    cell.selectionStyle = .none*/
                    cell = tableView.dequeueReusableCell(withIdentifier: "HeaderSearch", for: indexPath)
                    if let headerCell = cell as? HeaderSearchTableViewCell{
                        headerCell.title1 = "POPULAR EVENTS"
                        headerCell.title2 = "Events ที่กำลังได้รับความนิยมในขณะนี้"
                        headerCell.iconImage = "heartIcon"
                    }
                    cell.selectionStyle = .none
            
        
                }
        
                else if indexPath.section == 1 && indexPath.row == 0{
                    cell = tableView.dequeueReusableCell(withIdentifier: "HeaderSearch", for: indexPath)
                    if let headerCell = cell as? HeaderSearchTableViewCell{
                        headerCell.title1 = "POPULAR EVENTS"
                        headerCell.title2 = "Events ที่กำลังได้รับความนิยมในขณะนี้"
                        headerCell.iconImage = "heartIcon"
                    }
                    cell.selectionStyle = .none
              }
               else {
                    cell = tableView.dequeueReusableCell(withIdentifier: "EventSearchFeed", for: indexPath)
                    if let fetchData = fetchedResultsController?.object(at: IndexPath(row: indexPath.row-1, section: 0)) as? ActivityData{
                        var name: String?
                        var toRound: NSSet?
                        var thumbnail: String?
                        var facity: String?
                        fetchData.managedObjectContext?.performAndWait{
                            // it's easy to forget to do this on the proper queue
                            name = fetchData.name
                            thumbnail = fetchData.thumbnailsUrl
                            facity = fetchData.faculty
                            toRound = fetchData.toRound
                            // we're not assuming the context is a main queue context
                            // so we'll grab the screenName and return to the main queue
                            // to do the cell.textLabel?.text setting
                        }
                        print("feedCell name == \(name)")
                        if let eventFeedCell = cell as? EventFeedCell{
                            print("feedCell name == \(name)")

                            eventFeedCell.manageObjectContext = managedObjectContext
                            eventFeedCell.name = name
                            eventFeedCell.toRound = toRound
                            eventFeedCell.thumbnail = thumbnail
                            eventFeedCell.facity = facity
                            
                        }
                    }

                }
        }
        
        cell.selectionStyle = .none
        return cell
        
    }
    
    func searchButtonClicked(searchBar: UISearchBar){
        ShouldShowResult = true
        searchBar.endEditing(true)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
     func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if(!ShouldShowResult){
            if section == 0 {
                return 4
            }
        }
            return 0
    }
    
     func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if(!ShouldShowResult){
            if section == 0{
                let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
                view.backgroundColor = UIColor.clear
                return view
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(!ShouldShowResult){
            if indexPath.row == 1 && indexPath.section == 0 {
                return 0
            }
            else if indexPath.row == 0{
                
                    return 58
                }
            else if indexPath.section == 1 {
                return 78
            }
        }
        else {
            return 78
        }
        
        return UITableViewAutomaticDimension
        
    }

}

    // Core Data


//
//    


//    // MARK: - Table view data source
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        ((
//        var cell: UITableViewCell
//        
//        if indexPath.section == 0 && indexPath.row == 0 {
//            
//            cell = tableView.dequeueReusableCell(withIdentifier: "Map", for: indexPath)
//            cell.selectionStyle = .none
//           
//        }
//            
//        else if indexPath.section == 1 && indexPath.row == 0{
//            cell = tableView.dequeueReusableCell(withIdentifier: "HeaderSearch", for: indexPath)
//            if let headerCell = cell as? HeaderSearchTableViewCell{
//                headerCell.title1 = "EVENTS FOR YOU"
//                headerCell.title2 = "แนะนำกิจกรรมที่คุณอาจสนใจ"
//                headerCell.iconImage = "heartIcon"
//            }
//            cell.selectionStyle = .none
//        }
//        else {
//            cell = tableView.dequeueReusableCell(withIdentifier: "Map", for: indexPath)
//            cell.selectionStyle = .none
//        }
//        
//           
       /* else {
 
            cell = tableView.dequeueReusableCell(withIdentifier: "EventFeed", for: indexPath)
            if let fetchData = fetchedResultsController2?.object(at: IndexPath(row: indexPath.row-1, section: 0)) as? ActivityData{
                var name: String?
                 var toRound: NSSet?
                var thumbnail: String?
                var facity: NSSet?
                fetchData.managedObjectContext?.performAndWait{
                    // it's easy to forget to do this on the proper queue
                    name = fetchData.name
                    thumbnail = fetchData.thumbnailsUrl
                    facity = fetchData.toFaculty
                    toRound = fetchData.toRound
                    // we're not assuming the context is a main queue context
                    // so we'll grab the screenName and return to the main queue
                    // to do the cell.textLabel?.text setting
                }
                print("feedCell name == \(name)")
                if let eventFeedCell = cell as? EventFeedCell{
                    print("feedCell name == \(name)")
                    eventFeedCell.name = name
                    eventFeedCell.toRound = toRound
                    eventFeedCell.thumbnail = thumbnail
                    eventFeedCell.facity = facity
                }
            }
        }*/
//        
//        return cell
//    }
//    

//    private func printDatabaseStatistics(){
//        managedObjectContext?.perform {
//            if let result = try? self.managedObjectContext!.fetch(NSFetchRequest(entityName: "ActivityData")){
//                print("Total ActivityDatas in coredata \(result.count)")
//            }
//        }
//    }
//    
//}
