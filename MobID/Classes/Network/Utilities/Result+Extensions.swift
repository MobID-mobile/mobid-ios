//  Created by admin on 23.12.2020.

import Foundation

func identity<Value>(_ value: Value) -> Value {
  return value
}

func empty<Value>(_ value: Value) -> Value? {
  return nil
}

func liftValue<Value, Error>(_ value: Value) -> Result<Value, Error> {
  return .success(value)
}

func liftError<Value, Error>(_ error: Error) -> Result<Value, Error> {
  return .failure(error)
}

extension Result {
  
  // MARK: - Public properties
  
  var value: Success? {
    return self.analysis(ifValue: identity, ifError: { _ in nil })
  }
  
  var error: Failure? {
    return self.analysis(ifValue: { _ in nil }, ifError: identity)
  }
  
  // MARK: - Public methods
  
  func analysis<Result>(ifValue: (Success) -> Result, ifError: (Failure) -> Result) -> Result {
    switch self {
    case let .success(value): return ifValue(value)
    case let .failure(error): return ifError(error)
    }
  }
  
  // MARK: - Result value related
  
  func flatMap<T, E>(ifSuccess: @escaping (Success) -> Result<T, E>,
                     ifFailure: @escaping (Failure) -> Result<T, E>) -> Result<T, E> {
    return self.analysis(ifValue: ifSuccess, ifError: ifFailure)
  }
  
  func flatMapValue<T>(transform: @escaping (Success) -> Result<T, Failure>) -> Result<T, Failure> {
    return self.flatMap(ifSuccess: transform, ifFailure: liftError)
  }
  
  func flatMapError<E>(transform: @escaping (Failure) -> Result<Success, E>) -> Result<Success, E> {
    return self.flatMap(ifSuccess: liftValue, ifFailure: transform)
  }
  
}
