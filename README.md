# ReactiveRealm
Reactive interface for Realm using ReactiveCocoa


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
**Craeting objects**
```swift
Realm.rx_create(type: Notification, value: notification, update = true, thread: .BackgroundThread)
  |> start(completed: {
    // Yay! notification created
  })
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
