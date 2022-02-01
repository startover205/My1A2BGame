//
//  ExponentialBackoffDecorator.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2022/1/9.
//  Copyright © 2022 Ming-Ta Yang. All rights reserved.
//

import Foundation

final class ExponentialBackoffDecorator<T> {
    let decoratee: T
    private let baseDelay: TimeInterval
    private let maxDelay: TimeInterval
    private let jitterDelay: () -> TimeInterval
    private let asyncAfter: AsyncAfter
    private let retryMaxCount: Int
    private var retryCount = 0
    
    init(_ decoratee: T,
         baseDelay: TimeInterval = 2.0,
         maxDelay: TimeInterval = 300.0,
         jitterDelay: @escaping () -> TimeInterval = { TimeInterval.random(in: 0...1) },
         retryMaxCount: Int = 10,
         asyncAfter: @escaping AsyncAfter = { time, work in
        DispatchQueue.global().asyncAfter(deadline: .now() + time, execute: work)
    })  {
        self.decoratee = decoratee
        self.baseDelay = baseDelay
        self.maxDelay = maxDelay
        self.retryMaxCount = retryMaxCount
        self.jitterDelay = jitterDelay
        self.asyncAfter = asyncAfter
    }
    
    func handle<U>(result: Result<U, Error>, completion: @escaping (Result<U, Error>) -> Void, onRetry: @escaping () -> Void) {
        switch result {
        case .success(let data):
            retryCount = 0
            completion(.success(data))
            
        case .failure(let error):
            if retryCount >= retryMaxCount {
                completion(.failure(error))
            } else {
                retryCount += 1
                
                let delay = min(TimeInterval(pow(Float(baseDelay), Float(retryCount))), maxDelay) + jitterDelay()
                
                asyncAfter(delay, onRetry)
            }
        }
    }
}
