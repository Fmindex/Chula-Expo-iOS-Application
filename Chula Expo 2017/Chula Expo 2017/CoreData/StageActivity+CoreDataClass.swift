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
//                stageData.startDate = activityData.startTime
//                stageData.startDate = ( activityData.toRound?.allObjects.first as! RoundData).endTime
                stageData.toActivity = activityData
                
                completion?(stageData)
                
            } else {

                completion?(nil)
                
            }
            
        }
        
    }
    
    class func fetchNowOnStageID(manageObjectContext context: NSManagedObjectContext) -> [ActivityData?] {
        
        var fetchResult = [ActivityData?]()
        fetchResult = [nil,nil,nil]
        let request1 = NSFetchRequest<NSFetchRequestResult>(entityName: "StageActivity")
        let request2 = NSFetchRequest<NSFetchRequestResult>(entityName: "StageActivity")
        let request3 = NSFetchRequest<NSFetchRequestResult>(entityName: "StageActivity")
        
        let nowDate = Date()
//        request1.predicate = NSPredicate(format: "endDate <= nowDate AND stage == 1")
//        request2.predicate = NSPredicate(format: "endDate <= nowDate and stage == 2")
//        request3.predicate = NSPredicate(format: "endDate <= nowDate and stage == 3")
        
        do {
            let result1 = try context.fetch(request1)
            let result2 = try context.fetch(request2)
            let result3 = try context.fetch(request3)
            
            for item in result1{
                
                if let stageAct = item as? StageActivity{
                    
                    if nowDate.isInRangeOf(start: stageAct.startDate, end: stageAct.endDate){
                        
                        fetchResult[0] = stageAct.toActivity
                        break
                    }
                }
            }
            
            for item in result2{
                
                if let stageAct = item as? StageActivity{
                    
                    if nowDate.isInRangeOf(start: stageAct.startDate, end: stageAct.endDate){
                        
                        fetchResult[1] = stageAct.toActivity
                        break
                    }
                }
            }
            
            for item in result3{
                
                if let stageAct = item as? StageActivity{
                    
                    if nowDate.isInRangeOf(start: stageAct.startDate, end: stageAct.endDate){
                        
                        fetchResult[2] = stageAct.toActivity
                        break
                    }
                }
            }
            
        } catch {
            print("Couldn't fetch results")
        }
        
        return fetchResult
    }
}
