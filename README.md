# ReactiveRealm
Reactive interface for Realm using ReactiveCocoa

### Installation
- Copy `ReactiveRealm.swift` into your project
- Make sure you have **ReactiveCocoa 3.0** and **RealmSwift** compatible with Swift 2.0

*Note: We'll add CocoaPods and Carthage integration once Swift2.0 is officially launched*

### Features
- It's **Swift 2.0** ready
- Offers static Signal Produced for all Realm operations (saving, deletion, fetching)
- It uses **ReactiveCocoa 3.0** version
- Custom Signal operators for **filtering** and **sorting**

### :octocat: Examples
**Fetching objects**
```swift
Realm.rx_objects(Notification) 
  |> filter("read == NO")
  |> start(next: {
    println("Notifications: \($0)")
  })
```
**Creating objects in a Background Thread**
```swift
Realm.rx_create(type: Notification, value: notification, update = true, thread: .BackgroundThread)
  |> start(completed: {
    // Yay! notification created
  })
```
**Deleting objects**
```swift
Realm.rx_delete(object: notification, thread: .SameThread)
  |> start(completed: {
    // Yay! notification deleted
  })
```
### RealmThread
`RealmThread` is a custom enum that specifies the thread where the operation will be executed.
```swift
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
```

### :golf: Todo
- [ ] Once Swift 2.0 is officially launched, add CocoaPods/Carthage integration steps
- [ ] Include Unit Tests using real models

### License
```
The MIT License (MIT)

Copyright (c) 2015 GitDo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
