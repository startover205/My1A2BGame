//
//  ExponentialBackoffDecoratorTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2022/1/8.
//  Copyright © 2022 Ming-Ta Yang. All rights reserved.
//

import XCTest
@testable import My1A2BGame

private protocol Loader {
    typealias Result = Swift.Result<String, Error>
    
    func load(completion: @escaping (Result) -> Void)
}

extension ExponentialBackoffDecorator: Loader where T: Loader {
    func load(completion: @escaping (Loader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.handle(result: result, completion: completion) { [weak self] in self?.load(completion: completion) }
        }
    }
}

class ExponentialBackoffDecoratorTests: XCTestCase {
    
    func test_init_doesNotMessaageDecoratee() {
        let (_, loader, _) = makeSUT()
        
        XCTAssertTrue(loader.receivedMessages.isEmpty)
    }
    
    func test_load_messageDecoratee() {
        let (sut, loader, _) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(loader.receivedMessages, [.load])
    }
    
    func test_loadTwice_messageDecorateeTwice() {
        let (sut, loader, _) = makeSUT()
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(loader.receivedMessages, [.load, .load])
    }
    
    func test_load_deliversDataOnSuccessfulLoading() {
        let (sut, loader, _) = makeSUT()
        let loadData = "proper data"
        var capturedResult: Loader.Result?
        
        sut.load { capturedResult = $0 }
        loader.completeLoading(with: loadData)
        
        switch capturedResult {
        case .success(let data):
            XCTAssertEqual(data, loadData)
        default:
            XCTFail("Expect success case, got \(String(describing: capturedResult)) instead")
        }
    }
    
    func test_load_retriesAsyncOnFirstLoadError() {
        let (sut, loader, asyncAfter) = makeSUT()
        let loadError = anyNSError()
        
        sut.load { _ in }
        loader.completeLoading(with: loadError)
        
        XCTAssertEqual(loader.receivedMessages, [.load], "Expect no load until async task executes")
        
        asyncAfter.completeAsyncTask()
        
        XCTAssertEqual(loader.receivedMessages, [.load, .load], "Expect another load when async task executes")
    }
    
    func test_load_retriesTwiceAsyncOnLoadErrorTwice() {
        let (sut, loader, asyncAfter) = makeSUT()
        let loadError = anyNSError()
        
        sut.load { _ in }
        
        loader.completeLoading(with: loadError, at: 0)
        XCTAssertEqual(loader.receivedMessages, [.load], "Expect no retry until async task executes")
        
        asyncAfter.completeAsyncTask(at: 0)
        XCTAssertEqual(loader.receivedMessages, [.load, .load], "Expect 2nd load when async task executes")
        
        loader.completeLoading(with: loadError, at: 1)
        XCTAssertEqual(loader.receivedMessages, [.load, .load], "Expect no 3rd load before async task executes")

        asyncAfter.completeAsyncTask(at: 1)
        XCTAssertEqual(loader.receivedMessages, [.load, .load, .load], "Expect 3rd load when async task executes")
    }
    
    func test_load_retriesAsyncExponentiallyBackoffOnLoadError() {
        let baseDelay = 3.0
        let (sut, loader, asyncAfter) = makeSUT(baseDelay: baseDelay)
        let loadError = anyNSError()
        
        sut.load { _ in }
        
        loader.completeLoading(with: loadError, at: 0)
        XCTAssertEqual(asyncAfter.capturedDelays, [3], "Expect async task delay 3 seconds for the 1st retry")
        
        asyncAfter.completeAsyncTask(at: 0)
        loader.completeLoading(with: loadError, at: 1)
        XCTAssertEqual(asyncAfter.capturedDelays, [3, 9], "Expect async task delay 9 seconds for the 2nd retry")

        asyncAfter.completeAsyncTask(at: 1)
        loader.completeLoading(with: loadError, at: 2)
        XCTAssertEqual(asyncAfter.capturedDelays, [3, 9, 27], "Expect async task delay 27 seconds for the 3rd retry")
    }
    
    func test_load_retriesAsyncExponentiallyBackoffWithJitterOnLoadError() {
        let baseDelay = 3.0
        var jitters = [0.2, 0.3, 0.1]
        let jitterDelay: () -> TimeInterval = { jitters.removeFirst() }
        let (sut, loader, asyncAfter) = makeSUT(baseDelay: baseDelay, jitterDelay: jitterDelay)
        let loadError = anyNSError()
        
        sut.load { _ in }
        
        loader.completeLoading(with: loadError, at: 0)
        XCTAssertEqual(asyncAfter.capturedDelays, [3.2], "Expect async task delay 3 seconds for the 1st retry")
        
        asyncAfter.completeAsyncTask(at: 0)
        loader.completeLoading(with: loadError, at: 1)
        XCTAssertEqual(asyncAfter.capturedDelays, [3.2, 9.3], "Expect async task delay 9 seconds for the 2nd retry")

        asyncAfter.completeAsyncTask(at: 1)
        loader.completeLoading(with: loadError, at: 2)
        XCTAssertEqual(asyncAfter.capturedDelays, [3.2, 9.3, 27.1], "Expect async task delay 27 seconds for the 3rd retry")
    }
    
    func test_load_retryCountDoesNotExceedMaxOnLoadError() {
        let retryMaxCount = 1
        let (sut, loader, asyncAfter) = makeSUT(retryMaxCount: retryMaxCount)
        let loadError = anyNSError()
        
        sut.load { _ in }
        
        loader.completeLoading(with: loadError, at: 0)
        XCTAssertEqual(asyncAfter.tasksCount, 1, "Expect 1 async task on load error")
        
        asyncAfter.completeAsyncTask(at: 0)
        
        loader.completeLoading(with: loadError, at: 1)
        XCTAssertEqual(asyncAfter.tasksCount, 1, "Expect no more async task since retry max count is reached")
    }

    func test_load_deliversErrorOnMaxRetryCountReached_onLoadError() {
        let retryMaxCount = 1
        let (sut, loader, asyncAfter) = makeSUT(retryMaxCount: retryMaxCount)
        let loadError = anyNSError()
        var capturedResult: Loader.Result?
        
        sut.load { capturedResult = $0 }
        
        loader.completeLoading(with: loadError, at: 0)
        XCTAssertNil(capturedResult)
        
        asyncAfter.completeAsyncTask(at: 0)
        loader.completeLoading(with: loadError, at: 1)
        switch capturedResult {
        case .failure(let error as NSError):
            XCTAssertEqual(error, loadError)
        default:
            XCTFail("Expect failure case, got \(String(describing: capturedResult)) instead")
        }
    }
    
    func test_load_retryDelayDoesNotExceedMaxDelayWithJitterOnLoadError() {
        let baseDelay = 2.0
        let maxDelay = 1.0
        var jitters = [0.2, -0.3]
        let jitterDelay: () -> TimeInterval = { jitters.removeFirst() }
        let (sut, loader, asyncAfter) = makeSUT(baseDelay: baseDelay, maxDelay: maxDelay, jitterDelay: jitterDelay)
        let loadError = anyNSError()
        
        sut.load { _ in }
        
        loader.completeLoading(with: loadError, at: 0)
        XCTAssertEqual(asyncAfter.capturedDelays, [1.2], "Expect async task delays 1 seconds + 0.2 jitter for the 1st retry")
        
        asyncAfter.completeAsyncTask(at: 0)
        loader.completeLoading(with: loadError, at: 1)
        XCTAssertEqual(asyncAfter.capturedDelays, [1.2, 0.7], "Expect async task still delays 1 seconds with jitter for the 2nd retry because the calculated delay is bigger than the max delay")
    }
    
    func test_loadTwice_resetsRetryDelayOnSuccessfulLoad() {
        let baseDelay = 2.0
        let (sut, loader, asyncAfter) = makeSUT(baseDelay: baseDelay)
        let loadError = anyNSError()
        
        sut.load { _ in }
        loader.completeLoading(with: loadError, at: 0)
        XCTAssertEqual(asyncAfter.capturedDelays, [2], "Expect async task delay 2 seconds for the 1st retry of the first load")
        asyncAfter.completeAsyncTask(at: 0)
        loader.completeLoading(with: "proper data")
        
        sut.load { _ in }
        loader.completeLoading(with: loadError, at: 1)
        XCTAssertEqual(asyncAfter.capturedDelays, [2, 2], "Expect async task delay 2 seconds since the first retry succeeded")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        baseDelay: TimeInterval = 2.0,
        maxDelay: TimeInterval = 300,
        jitterDelay: @escaping () -> TimeInterval = { 0.0 },
        retryMaxCount: Int = 10,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (ExponentialBackoffDecorator<LoaderSpy>, LoaderSpy, LoaderSpy) {
        let spy = LoaderSpy()
        let sut = ExponentialBackoffDecorator(spy, baseDelay: baseDelay, maxDelay: maxDelay, jitterDelay: jitterDelay, retryMaxCount: retryMaxCount, asyncAfter: spy.asyncAfter)
        
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, spy, spy)
    }
}

private final class LoaderSpy: Loader {
    enum Message: Equatable {
        case load
    }
    
    private(set) var receivedMessages = [Message]()
    private var capturedCompletions = [(Loader.Result) -> Void]()
    private(set) var capturedDelays = [TimeInterval]()
    private(set) var capturedTasks = [() -> Void]()
    
    var tasksCount: Int { capturedTasks.count }
    
    func load(completion: @escaping (Loader.Result) -> Void) {
        receivedMessages.append(.load)
        capturedCompletions.append(completion)
    }
    
    func completeLoading(with error: Error, at index: Int = 0) {
        capturedCompletions[index](.failure(error))
    }
    
    func completeLoading(with data: String, at index: Int = 0) {
        capturedCompletions[index](.success(data))
    }
    
    func asyncAfter(delay: TimeInterval, task: @escaping () -> Void) {
        capturedDelays.append(delay)
        capturedTasks.append(task)
    }
    
    func completeAsyncTask(at index: Int = 0) {
        capturedTasks[index]()
    }
}
