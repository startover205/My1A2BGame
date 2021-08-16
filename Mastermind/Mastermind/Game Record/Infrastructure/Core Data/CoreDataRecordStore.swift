//
//  CoreDataRecordStore.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/15.
//

import CoreData

public struct LocalPlayerRecord: Equatable {
    public let playerName: String
    public let guessCount: Int
    public let guessTime: TimeInterval
    public let timestamp: Date
    
    public init(playerName: String, guessCount: Int, guessTime: TimeInterval, timestamp: Date) {
        self.playerName = playerName
        self.guessCount = guessCount
        self.guessTime = guessTime
        self.timestamp = timestamp
    }
}

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
    public func retrieve() throws -> [LocalPlayerRecord] {
        try performSync { context in
            Result {
                let request = NSFetchRequest<Winner>(entityName: Winner.entity().name!)
                request.returnsObjectsAsFaults = false
                return try context.fetch(request).map {
                    LocalPlayerRecord(playerName: $0.name ?? "", guessCount: Int($0.guessTimes), guessTime: $0.spentTime, timestamp: $0.date ?? Date())
                }
            }
        }
    }
    
    public func insert(_ record: LocalPlayerRecord) throws {
        try performSync { context in
            Result {
                let winner = Winner(context: context)
                winner.name = record.playerName
                winner.guessTimes = Int16(record.guessCount)
                winner.spentTime = record.guessTime
                winner.date = record.timestamp
                
                try context.save()
            }
        }
    }
    
    public func delete(_ records: [LocalPlayerRecord]) throws {
    }
}
