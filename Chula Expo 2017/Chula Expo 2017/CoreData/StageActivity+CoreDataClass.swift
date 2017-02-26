//
//  StageActivity+CoreDataClass.swift
//  
//
//  Created by Pakpoom on 2/24/2560 BE.
//
//

import Foundation
import CoreData

@objc(StageActivity)
public class StageActivity: NSManagedObject {
    
    class func fetchStageActivities(inManageobjectcontext context: NSManagedObjectContext) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "StageActivity")
        
        do {
            
            let results = try context.fetch(request) as? [StageActivity]
            
            for result in results! {
                
                print(result.toActivity)
                
            }
            
        } catch {
            
            print("Couldn't fetch results")
            
        }
        
    }
    
    class func makeRelation(activityId: String, inManageObjectContext context: NSManagedObjectContext) -> Bool? {
        
        let stageRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StageActivity")
        stageRequest.predicate = NSPredicate(format: "activityId = %@",  activityId)
        
        if let stageResult = (try? context.fetch(stageRequest))?.first as? StageActivity {
            
            // found this event in the database, return it ...
//            print("Found \(stageResult.activityId!) in StageActivity")
            
            let activityRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ActivityData")
            activityRequest.predicate = NSPredicate(format: "activityId = %@",  activityId)
            
            if let activityResult = (try? context.fetch(activityRequest))?.first as? ActivityData
            {
                
                stageResult.toActivity = activityResult
                
//                print("already make relationship btw stage and activity")
                return true
                
            }
            
        }
        
        print("fail to make relationship btw stage and activity")
        
        return false
        
    }
    
    class func addData(activityId: String, activityData: ActivityData, stage: Int, inManageobjectcontext context: NSManagedObjectContext, completion: ((StageActivity?) -> Void)?) {
        
        let stageRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StageActivity")
        stageRequest.predicate = NSPredicate(format: "activityId = %@",  activityId)
        
        if let result = (try? context.fetch(stageRequest))?.first as? StageActivity {
            
            // found this event in the database, return it ...
//            print("Found \(result.activityId!) in StageActivity")
            
            completion?(result)
            
        } else {
            
            if let stageData = NSEntityDescription.insertNewObject(forEntityName: "StageActivity", into: context) as? StageActivity
            {
                        
                stageData.activityId = activityId
                stageData.stage = Int16(stage)
                stageData.toActivity = activityData
                
                completion?(stageData)
                
            } else {

                completion?(nil)
                
            }
            
        }
        
    }

}
