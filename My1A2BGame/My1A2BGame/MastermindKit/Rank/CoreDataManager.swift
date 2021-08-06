//
//  CoreDataManager.swift
//  MyCoreDataManager
//
//  Created by Ming-Ta Yang on 2018/7/18.
//  Copyright © 2018年 Ming-Ta Yang. All rights reserved.
//

import CoreData

public typealias SaveDoneHandler = (_ success: Bool) -> Void

class CoreDataManager<T: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    
    private let momdFilename: String
    private let dbFilename: String
    private let dbFilePathURL: URL
    private let entityName: String
    private var sortKey: String?
    private var ascending = false
    
    private var sortDescriptors = [NSSortDescriptor]()
    private var saveDoneHandler: SaveDoneHandler?
    
    // Custom
    init(momdFilename: String, //資料模型(xcdatamodeld)的檔名
        dbFilename: String? = nil, //資料庫的檔名，如果是nil就與資料模型同名
        dbFilePathURL: URL? = nil, //資料庫的檔案放置路徑，如果是nil就放在documents目錄
        entityName: String, //資料型別名稱
        sortKey: String, asending: Bool) { //排序
        
        self.momdFilename = momdFilename
        if let filename = dbFilename{
            self.dbFilename = filename
        } else {
            self.dbFilename = momdFilename
        }
        if let url = dbFilePathURL {
            self.dbFilePathURL = url
        } else {
            self.dbFilePathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        self.entityName = entityName
        self.sortKey = sortKey
        self.ascending = asending
        
        super.init()
    }
    
    init(momdFilename: String = "Model", //資料模型(xcdatamodeld)的檔名
        dbFilename: String? = nil, //資料庫的檔名，如果是nil就與資料模型同名
        dbFilePathURL: URL? = nil, //資料庫的檔案放置路徑，如果是nil就放在documents目錄
        entityName: String, //資料型別名稱
        sortDescriptors: [NSSortDescriptor]) { //排序
        
        self.momdFilename = momdFilename
        if let filename = dbFilename{
            self.dbFilename = filename
        } else {
            self.dbFilename = momdFilename
        }
        if let url = dbFilePathURL {
            self.dbFilePathURL = url
        } else {
            self.dbFilePathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        self.entityName = entityName
        self.sortDescriptors = sortDescriptors
        
        super.init()
    }
    
    //Private methods/properties(從舊架構空白範本的appDelegate跟MasterViewController而來)
    private lazy var managedObjectModel: NSManagedObjectModel = { //被第二呼叫->第三
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: momdFilename, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private lazy var url = dbFilePathURL.appendingPathComponent(dbFilename + ".sqlite")
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = { //被第一呼叫->第二
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil) //有許多Type，也有關閉App資料就消失的Type
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            let failureReason = "There was an error creating or loading the application's saved data."
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            
            #if DEBUG
            abort()
            #endif
        }
        
        return coordinator
    }()
    
    private lazy var managedObjectContext: NSManagedObjectContext = { //第一被用到，主要溝通物件
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType) //有三種Type，可改用background-thread(不建議，有時會出現難以釐清的問題)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: self.managedObjectContext)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20 //空間換取時間，batch大小，至少大於15(tableView一頁的資料量)
        
        // Edit the sort key as appropriate.
        if !sortDescriptors.isEmpty{
            fetchRequest.sortDescriptors = sortDescriptors
        } else {
            let sortDescriptor = NSSortDescriptor(key: sortKey!, ascending: ascending)
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: entityName) //二維資料庫keyPath不能填nil
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController as NSFetchedResultsController<NSFetchRequestResult>
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            #if DEBUG
            abort()
            #endif
        }
        
        return _fetchedResultsController!
    }
    private var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) { //當資料有修改時會被呼叫
        saveDoneHandler?(true) //回傳成功給doneHandler並清除他，假如是nil回傳不會有作用
        saveDoneHandler = nil
    }

}

// MARK: - Public
extension CoreDataManager {
    
    func saveContext (completion: SaveDoneHandler?) {
        if managedObjectContext.hasChanges { //context有被改變才存檔
            do {
                //檢查是否目前有人正在存檔->假如有，自己就取消存檔
                guard saveDoneHandler == nil else {
                    completion?(false)
                    return
                }
                
                saveDoneHandler = completion
                
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                
                completion?(false)
                #if DEBUG
                abort()
                #endif
            }
        } else {
            completion?(true) //如果context沒有被改變就直接回傳true給doneHandler
        }
    }
    
    var totalCount: Int {
        let sectionInfo = self.fetchedResultsController.sections![0] //一維資料庫寫0
        return sectionInfo.numberOfObjects
    }
    
    func createObject() -> T {
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: self.managedObjectContext) as! T
    }
    
    func delete(object: T) {
        self.managedObjectContext.delete(object)
    }
    
    func fetchObject(at: Int) -> T? {
        let indexPath = IndexPath(row: at, section: 0)
        return self.fetchedResultsController.object(at: indexPath) as? T
    }
    
    func fetchAllObjects() -> [T] {
        return self.fetchedResultsController.fetchedObjects as? [T] ?? [T]()
    }
    
    func searchBy(keyword: String, field: String) -> [T]? {
        
        let request = NSFetchRequest<T>(entityName: entityName)
        
        let predicate = NSPredicate(format: field + " CONTAINS[cd] \"\(keyword)\"")
        //搜尋含關鍵字的結果； name CONTAINS[cd] "Lee" 蘋果規定的predicate寫法，cd代表不管大小寫
        request.predicate = predicate
        
        do {
            return try managedObjectContext.fetch(request)
        } catch  {
            assertionFailure("Fail to fetch: \(error)")
        }
        return nil
    }
    
    func deleteAllObjects() -> Bool{
        do {
            try persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType, options: nil)
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            _fetchedResultsController = nil
            _ = fetchedResultsController
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            let failureReason = "There was an error creating or loading the application's saved data."
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            
            return false
        }
        return true
    }
    
    func apply(newSortDiscripter: [NSSortDescriptor]) {
        self.sortDescriptors = newSortDiscripter
    }
}
