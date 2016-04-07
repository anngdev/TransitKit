<p align="center"><img src="https://raw.githubusercontent.com/zoonooz/TransitKit/master/TransitKit.jpg"/></p>

# 🚃 TransitKit
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


**TransitKit** is the library provide you an easiest way to customize the animation when you change from one ViewController to another. You can think of this library as transit system, travel from one station to other station with trains in various lines.

Besides custom transition, Transit also helps you move subviews to the next ViewController with your custom animation.

Transit consists of four parts
- **Station** is each view controller you animating to or from
- **Passenger** is the subviews inside you view controller that you want to animate separately
- **Train** is the data mover that move passengers from one station to another
- **Line** is the animator to tell the library that how you going to animate between view controller

## 🚉 Station (駅)
Station is your view controllers
```
typealias Station = UIViewController
```
Most of the time you are dealing with simple view controller, only if you want to send some passengers to another station then have to extend `StationPassenger` protocol and return the list of passengers you want them to travel.

## 👫 Passenger (旅客)
Passengers are your subviews inside the root view in view controller. They can be identified by `name`. If both current train and destination station have same passenger with same name, thats mean passenger is traveling!
```
struct Passenger {
    var name: String
    var view: UIView
}
```

## 🚇 Train (電車)
Train knows which station they coming from and going to including the passengers on board. You will not use the train directly because the station will create the train for you.

## 🚦 Line (線)
Line is the most important part here to create the animation. There are three Line protocols for you to use.
- **AnimationLine** normal line for `UIView` animation based
- **ProgressLine** use `CADisplayLink` for animation
- **InteractionLine** for interaction transition.

AnimationLine | ProgressLine | InteractionLine
---| --- | ---
![](https://raw.githubusercontent.com/zoonooz/TransitKit/master/line_animation.gif) | ![](https://raw.githubusercontent.com/zoonooz/TransitKit/master/line_progress.gif) | ![](https://raw.githubusercontent.com/zoonooz/TransitKit/master/line_interaction.gif)

## How to use
#### 1. Implement Line protocol
There are three functions in every line you have to implement
- `func duration() -> NSTimeInterval` animation duration
- `func beforeDepart(fromView:toView:inView:direction:)` run before animation start
- `func afterArrived(fromView:toView:inView:direction:)` run after animation finished

`fromView` is current ViewController's view<br/>
`toView` is ViewController's view that going to appear<br/>
`inView` is container view that has `fromView` and `toView` animating inside<br/>
`direction` can be `.Go` for show modal or push and `.Return` for dismissal or pop<br/>

##### Animation Line
Basically animation line do nothing but expect you to create animation in these functions
- `func animate(fromView:toView:inView:direction:)` create transition animation block here
- `func animatePassenger(view:targetFrame:direction:)` create animation block for each subview

##### Progress Line
Progress line use `CADisplayLink` to manage the animation frame and pass the progress value to these functions
- `func progress(fromView:toView:inView:direction:progress:)`
- `func progressPassenger(view:fromFrame:toFrame:direction:progress:)`

##### Interaction Line
For Interaction line, you have to manage the progress by yourself and pass the value back to Transit through these functions
- `func updateInteractLine(percentComplete:)`
- `func finishInteractionLine(withVelocity:)`
- `func cancelInteractionLine(withVelocity:)`

and Transit will call these functions in your implementation
- `func progress(fromView:toView:inView:direction:progress:)`
- `func progressPassenger(view:fromFrame:toFrame:direction:progress:)`
- `func interactFinish(fromView:toView:inView:direction:lastProgress:velocity:) -> NSTimeInterval`
- `func interactCancel(fromView:toView:inView:direction:lastProgress:velocity:) -> NSTimeInterval`
- `func interactPassengerFinish(view:toFrame:duration:)`
- `func interactPassengerCancel(view:toFrame:duration:)`

See [this](https://github.com/zoonooz/TransitKit/tree/master/Example/Lines) for example of implementation

#### 2. Travel!

For modal use
- `func travelBy(line: Line, to: Station) -> Transit`
- `func travelBackBy(line: Line) -> Transit`

For NavigationController use
- `func travelPushBy(line: Line, to: Station) -> Transit`
- `func travelPushBy(line: InteractionLine, to: Station, normalLine: Line) -> Transit`
- `func travelPopBy(line: InteractionLine) -> Transit`

As NavigationController can pop with or without interaction. If you use InteractionLine, you have to provide the AnimationLine or ProgressLine for default pop animation.

#### Example
You can see example of Line implementation in example project and use travel methods to start the transition.
```
let vc = storyboard?.instantiateViewControllerWithIdentifier("vc")
travelBy(SlideInZoomOutAnimation(), to: vc!)
```

## Installation
#### Carthage
```
github "zoonooz/TransitKit"
```
## Author
Amornchai Kanokpullwad, [@zoonref](https://twitter.com/zoonref)
