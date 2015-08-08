//
//  ReactiveRealm.swift
//  GitDoCore
//
//  Created by Pedro Piñera Buendía on 08/08/15.
//  Copyright © 2015 GitDo. All rights reserved.
//

import Foundation
import RealmSwift
import ReactiveCocoa

// MARK: - Realm extension that adds a reactive interface to Realm
public extension Realm {
    
    /**
    Enum that represents a Realm within a thread (used for operations)
    
    - MainThread:             Operations executed in the Main Thread Realm. Completion called in Main Thread
    - BackgroundThread        Operations executed in a New Background Thread Realm. Completion called in the Main Thread
    - SameThread:             Operations executed in the given Background Thread Realm. Completion called in the same Thread
    */
    enum RealmThread {
        case MainThread
        case BackgroundThread
        case SameThread(Realm)
    }
    
    enum RealmError: ErrorType {
        case WrongThread
        case InvalidRealm
        case InvalidReadThread
    }
    
    // MARK: - Helpers
    
    /// Realm save closure
    typealias OperationClosure = (realm: Realm) -> ()
    
    /// Executes the given operation passing the read to the operation block. Once it's completed the completion closure is called passing error in case of something went wrong
    static var realmOperation: (thread: RealmThread, writeOperation: Bool, completion: (error: RealmError?) -> (), operation: OperationClosure) -> () {
        get {
            return { (thread: RealmThread, writeOperation: Bool, completion: (error: RealmError?) -> (), save: OperationClosure) -> () in
                switch thread {
                case .MainThread:
                    if !NSThread.isMainThread() {
                        completion(error: .WrongThread)
                    }
                    do {
                        let realm = try Realm()
                        if writeOperation { realm.beginWrite() }
                        save(realm: realm)
                        if writeOperation { realm.commitWrite() }
                        completion(error: nil)
                    }
                    catch {
                        completion(error: .InvalidRealm)
                    }
                case .BackgroundThread:
                    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                    dispatch_async(dispatch_get_global_queue(priority, 0)) {
                        do {
                            let realm = try Realm()
                            if writeOperation { realm.beginWrite() }
                            save(realm: realm)
                            if writeOperation { realm.commitWrite() }
                            dispatch_async(dispatch_get_main_queue()) {
                                completion(error: nil)
                            }
                        }
                        catch {
                            dispatch_async(dispatch_get_main_queue()) {
                                completion(error: .InvalidRealm)
                            }
                        }
                    }
                case .SameThread(let realm):
                    if writeOperation { realm.beginWrite() }
                    save(realm: realm)
                    if writeOperation { realm.commitWrite() }
                    completion(error: nil)
                }
            }
        }
    }
    
    /// Generates the SignalProducer that executes the given write operation
    static var realmWriteOperationSignalProducer: (thread: RealmThread, writeOperation: Bool, operation: OperationClosure) -> SignalProducer<AnyObject, RealmError> {
        get {
            return { (thread: RealmThread, writeOperation: Bool, operation: OperationClosure) -> SignalProducer<AnyObject, RealmError> in
                return SignalProducer<AnyObject, RealmError> { (sink, disposable) -> () in
                    realmOperation(thread: thread, writeOperation: writeOperation, completion: { (error) -> () in
                        if let error = error {
                            sink(.Error(error))
                        }
                        else {
                            sink(.Completed)
                        }
                    }, operation: operation)
                }
            }
        }
    }
    
    
    // MARK: - Creation
    
    /**
    Add the objects to Realm
    
    :param: objects    objects to be added
    :param: update     true if they have to be updated in case of existing under the same primary key
    :param: thread     RealmThread where the operation will be executed
    
    :returns: Signal Producer that fires operation
    */
    static func rx_add<S: SequenceType where S.Generator.Element: Object>(objects: S, update: Bool = false, thread: RealmThread = .BackgroundThread) -> SignalProducer<AnyObject, RealmError> {
        return realmWriteOperationSignalProducer(thread: thread, writeOperation: true, operation: { (realm: Realm) -> () in
            realm.add(objects)
        })
    }
    
    /**
    Creates the object in Realm
    
    :param: type       object type
    :param: value      object value
    :param: update     true if the object has to be update in case of existing under the same primary key
    :param: thread     RealmThread where the operation will be executed
    
    :returns: Signal Producer that fires the operation
    */
    static func rx_create<T: Object>(type: T.Type, value: AnyObject = [:], update: Bool = false, thread: RealmThread = .BackgroundThread) -> SignalProducer<AnyObject, RealmError> {
        return realmWriteOperationSignalProducer(thread: thread, writeOperation: true, operation: { (realm: Realm) -> () in
            realm.create(type, value: value, update: update)
        })
    }
    
    
    // MARK: - Deletion
    
    /**
    Deletes the object from Realm
    
    :param: object     object to be deleted
    :param: thread     RealmThread where the operation will be executed
    
    :returns: Signal Producer that fires the operation
    */
    static func rx_delete(object: Object, thread: RealmThread) -> SignalProducer<AnyObject, RealmError> {
        return realmWriteOperationSignalProducer(thread: thread, writeOperation: true, operation: { (realm: Realm) -> () in
            realm.delete(object)
        })
    }
    
    /**
    Deletes the objects from Realm
    
    :param: objects objects to be deleted
    :param: thread  RealmThread where the operation will be executed
    
    :returns: Signal Producer that fires the operation
    */
    static func rx_delete<S: SequenceType where S.Generator.Element: Object>(objects: S, thread: RealmThread) -> SignalProducer<AnyObject, RealmError> {
        return realmWriteOperationSignalProducer(thread: thread, writeOperation: true, operation: { (realm: Realm) -> () in
            realm.delete(objects)
        })
    }
    
    /**
    Deletes the objects from Realm
    
    :param: objects objects to be deleted
    :param: thread  RealmThread where the operation will be executed
    
    :returns: Signal Producer that fires the operation
    */
    static func rx_delete<T: Object>(objects: List<T>, thread: RealmThread) -> SignalProducer<AnyObject, RealmError> {
        return realmWriteOperationSignalProducer(thread: thread, writeOperation: true, operation: { (realm: Realm) -> () in
            realm.delete(objects)
        })
    }
    
    /**
    Deletes the objects from Realm
    
    :param: objects objects to be deleted
    :param: thread  RealmThread where the operation will be executed
    
    :returns: Signal Producer that fires the operation
    */
    static func rx_delete<T: Object>(objects: Results<T>, thread: RealmThread) ->  SignalProducer<AnyObject, RealmError> {
        return realmWriteOperationSignalProducer(thread: thread, writeOperation: true, operation: { (realm: Realm) -> () in
            realm.delete(objects)
        })
    }
    
    /**
    Deletes all the objects from Realm
    
    :returns: Signal Producer that fires the operation
    */
    static func rx_deleteAll(thread: RealmThread) -> SignalProducer<AnyObject, RealmError> {
        return realmWriteOperationSignalProducer(thread: thread, writeOperation: true, operation: { (realm: Realm) -> () in
            realm.deleteAll()
        })
    }

    
    // MARK: - Querying
    
    /**
    Returns objects of the given type
    Note: This signal has to be subscribed in the Main Thread
    
    :param: type object type
    
    :returns: Signal Producer that fires the operation
    */
    static func rx_objects<T: Object>(type: T.Type) -> SignalProducer<Results<T>, RealmError> {
        return SignalProducer<Results<T>, RealmError> { (sink, disposable) -> () in
            if !NSThread.isMainThread() {
                sink(.Error(.InvalidReadThread))
            }
            else {
                do {
                    let realm = try Realm()
                    sink(.Next(realm.objects(type)))
                    sink(.Completed)
                }
                catch  {
                    sink(.Error(.InvalidRealm))
                }
            }
        }
    }
    
    /**
    Returns the object with the given primary key
    
    :param: type object type
    :param: key  primary key
    
    :returns: Signal Producer that fires the operation
    */
    static func rx_objectForPrimaryKey<T: Object>(type: T.Type, key: AnyObject) -> SignalProducer<T?, RealmError> {
        return SignalProducer<T?, RealmError> { (sink, disposable) -> () in
            if !NSThread.isMainThread() {
                sink(.Error(.InvalidReadThread))
            }
            else {
                do {
                    let realm = try Realm()
                    sink(.Next(realm.objectForPrimaryKey(type, key: key)))
                    sink(.Completed)
                }
                catch  {
                    sink(.Error(.InvalidRealm))
                }
            }
        }
    }
}


// MARK: - Reactive Operators

/**
Filters the signal of Results<T> applying an NSPredicate

:param: predicate filtering predicate

:returns: filtered Signal
*/
public func filter<T, E>(predicate: NSPredicate) -> Signal<Results<T>, E> -> Signal<Results<T>, E> {
    return { (signal: Signal<Results<T>, E>) ->  Signal<Results<T>, E> in
        return Signal<Results<T>, E> { observer in
            return signal.observe({ (event: Event<Results<T>,E>) -> () in
                switch event {
                case let .Next(value):
                    sendNext(observer, value.filter(predicate))
                case .Error(let error):
                    sendError(observer, error)
                case .Completed:
                    sendCompleted(observer)
                default:
                    break
                }
            })
        }
    }
}

/**
Filters the signal of Results<T> applying a predicate string

:param: predicateSring filtering predicate

:returns: filtered Signal
*/
public func filter<T, E>(predicateString: String) -> Signal<Results<T>, E> -> Signal<Results<T>, E> {
    return { (signal: Signal<Results<T>, E>) ->  Signal<Results<T>, E> in
        return Signal<Results<T>, E> { observer in
            return signal.observe({ (event: Event<Results<T>,E>) -> () in
                switch event {
                case let .Next(value):
                    sendNext(observer, value.filter(predicateString))
                case .Error(let error):
                    sendError(observer, error)
                case .Completed:
                    sendCompleted(observer)
                default:
                    break
                }
            })
        }
    }
}

/**
Sorts the signal of Results<T> using a key an the ascending value

:param: key key the results will be sorted by
:param: ascending true if the results sort order is ascending

:returns: sorted Signal
*/
public func sorted<T, E>(key: String, ascending: Bool = true) -> Signal<Results<T>, E> -> Signal<Results<T>, E> {
    return { (signal: Signal<Results<T>, E>) ->  Signal<Results<T>, E> in
        return Signal<Results<T>, E> { observer in
            return signal.observe({ (event: Event<Results<T>,E>) -> () in
                switch event {
                case let .Next(value):
                    sendNext(observer, value.sorted(key, ascending: ascending))
                case .Error(let error):
                    sendError(observer, error)
                case .Completed:
                    sendCompleted(observer)
                default:
                    break
                }
            })
        }
    }
}
    
