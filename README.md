# 🚃 Transit

**Transit** is the library provide you an easiest way to customize the animation when you change from one ViewController to another. You can think of this library as transit system, passengers travel from one station to other station with trains in various lines.

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
Line is the most important part here to create the animation. There are tree base lines for you to use.
- **AnimationLine** normal line for `UIView` animation based
- **ProgressLine** use `CADisplayLink` for animation
- **InteractionLine** for interaction transition.

## How to use
## Installation
## Author
Amornchai Kanokpullwad, [@zoonref](https://twitter.com/zoonref)
