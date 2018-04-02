import Foundation
import PlaygroundSupport
import SceneKit
import QuartzCore
import AVFoundation
import XCPlayground

//Set up the controller, live view and size, indefinite execution for loops
let controller = HomeViewController()
controller.preferredContentSize = CGSize(width: 800, height: 800)
PlaygroundPage.current.liveView = controller
PlaygroundPage.current.needsIndefiniteExecution = true
