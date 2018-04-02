import Foundation
import PlaygroundSupport
import SceneKit
import QuartzCore
import AVFoundation
import XCPlayground

/**

Description: Establishes a few global variables so that all of the classes can share data

**/

//Allows for global sharing of information on the blockchain, when something is added within the shop, it will be reflected within the ExpViewController
var blockchain = BlockChain()

//Establishes a clear size that will dictate lots of layout variables within the plagyround
let playgroundSize = CGSize(width: 800, height: 800)

//So that the ExpViewController will be able to tell how many messages has been presented from the MessageViewController 
var messagesIndex = 0

//The amount of blocks to be added to the chainadded
var blockAmount = 7

//Determines when blocks can be adjusted; in terms of messagesIndexadded
let adjustableAllowedOn = 15

