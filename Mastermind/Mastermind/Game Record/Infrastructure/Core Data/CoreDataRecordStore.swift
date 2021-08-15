//
//  CoreDataRecordStore.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/15.
//

import CoreData

public final class CoreDataRecordStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }
    
    public init(storeURL: URL, modelName: String) throws {
        guard let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataRecordStore.self)) else {
            throw StoreError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(name: modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }
    
    func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        let context = self.context
        var result: Result<R, Error>!
        context.performAndWait { result = action(context) }
        return try result.get()
    }
}

extension CoreDataRecordStore: RecordStore {
    public func totalCount() throws -> Int {
        return 0
    }
    
    public func retrieve() throws -> [PlayerRecord] {
        try performSync { context in
            Result {
                let request = NSFetchRequest<Winner>(entityName: Winner.entity().name!)
                request.returnsObjectsAsFaults = false
                return try context.fetch(request).map {
                    PlayerRecord(playerName: $0.name ?? "", guessCount: Int($0.guessTimes), guessTime: $0.spentTime)
                }
            }
        }
    }
    
    public func insert(_ record: PlayerRecord) throws {
        try performSync { context in
            Result {
                let winner = Winner(context: context)
                winner.name = record.playerName
                winner.guessTimes = Int16(record.guessCount)
                winner.spentTime = record.guessTime
                winner.date = Date()
                
                try context.save()
            }
        }
    }
    
    public func delete(_ records: [PlayerRecord]) throws {
    }
}
