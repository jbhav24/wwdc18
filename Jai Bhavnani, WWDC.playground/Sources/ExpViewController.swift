import Foundation
import PlaygroundSupport
import SceneKit
import QuartzCore
import AVFoundation
import XCPlayground

/**

View Description: The view that will allow the user to visualize the entire blockchain. Once they are done visualizing the blockchain they will be able to add fake, random data to the blockchain. 

**/

public class ExpViewController: UIViewController {

	//Nodes that need to be accessed from everywhere
	var selectedNode = SCNNode()
	var previousNode = SCNNode()
	let cameraNode = SCNNode()

	//Initial value of the first cube's x position
	var currentCubePosX = Float(-4)

	//Scene
	let scene = SCNScene()
	let scnView = SCNView()

	//Text that needs to be declared outside of function to be recalled
	var previousText = SCNText()
	var previousHash = SCNText()
	var previousPreviousHash = SCNText()

	var moreBlocks = SCNText()
	var lessBlocks = SCNText()
	var currentAmountOfBlocks = SCNText()

	//Timer that will check when it should present new views
	var messagesTimer : Timer?

	//Vector so all functions can locate the clicked cube position
	var nodePosition = SCNVector3()

	//Establishes previous selected block amountall
	var previousBlockAmount = 0

	//Determines whether it has added the 5 blocks
	var hasAdded5 = false

	//When the view loads
	override public func viewDidLoad() {
		super.viewDidLoad()
		setupScene()
		setupBlocks()
		setupChild()

		if messagesTimer == nil {
			messagesTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(check), userInfo: nil, repeats: true)
		}
	}

	//This checks for messages, when the message index reaches a certain amount, it will input randomly generated data so the user can understand blockchain. Also checks for other things
	@objc func check() {
		if messagesIndex == 10 && hasAdded5 == false {
			resetWith(amountOfBlocks: 5)
			hasAdded5 = true
		}
		if messagesIndex >= adjustableAllowedOn {
			if previousBlockAmount != blockAmount && blockAmount > previousBlockAmount {
				resetWith(amountOfBlocks: 1)
			}
			previousBlockAmount = blockAmount
		}
	}

	//Helps reset the scene with new cubes once it has been called
	func resetWith(amountOfBlocks: Int) {
		for i in 1...amountOfBlocks {
			addRBlocks()
			if i == amountOfBlocks {
				scene.rootNode.enumerateChildNodes { (node, stop) -> Void in
					node.removeFromParentNode()
				}
				currentCubePosX = Float(-4)
				setupScene()
				setupBlocks()
			}
		}
	}

	//Creates child scene so that the messages are viewable and also that the button for adding blocks is visible 
	func setupChild(){
		let messageViewController = MessageViewController()
		let messageView = messageViewController.view
		self.addChildViewController(messageViewController)
		self.view.addSubview(messageView!)
		messageViewController.didMove(toParentViewController: self)
	}

	//Randomly generates blocks for the blockchain, using purchasable items from the store
	func addRBlocks(){
		let purchasable = ["banana", "durian", "chili", "vase", "mango"]
		let newBlock = Block([purchasable.randomItem()!], blockchain.lastBlockHashValue)
		blockchain.add(newBlock)
	}

	//Sets up scene with initial cube, animations, cameras and gesture controls
	func setupScene(){
		let cubeGeometry = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0.25)
		let genesisCubeNode = SCNNode(geometry: cubeGeometry)
		genesisCubeNode.position = SCNVector3(x: currentCubePosX, y: 0, z: 0)
		scene.rootNode.addChildNode(genesisCubeNode)

		let spin = CABasicAnimation(keyPath: "rotation")
		spin.toValue = NSValue(scnVector4: SCNVector4(x: 0.0, y: 1.0, z: 1.0, w: Float(Double.pi)))
		spin.duration = 5
		spin.repeatCount = HUGE
		genesisCubeNode.addAnimation(spin, forKey: "spin me!")

		// create and add a camera to the scene
		cameraNode.camera = SCNCamera()
		cameraNode.name = "camera"
		scene.rootNode.addChildNode(cameraNode)

		// place the camera
		cameraNode.position = SCNVector3(x: 0, y: 0, z: 20)

		scnView.scene = scene
		scnView.allowsCameraControl = true
		scnView.backgroundColor = UIColor.gray
		scnView.loops = true

		switchCamera()

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
		scnView.addGestureRecognizer(tapGesture)

		self.view.frame.size = playgroundSize
		self.view = scnView
	}

	//Centers the camera on the cubes in the frame
	@objc func switchCamera() {
		let width = blockchain.arrayOfBlocks.count * 4
		let center = width/2

		let move = SCNAction.move(to: SCNVector3(x: Float(center-4), y: Float(0), z: Float(30)), duration: 1)
		cameraNode.runAction(move)
	}

	//Adds a block to the visual for every block inside of the blockchain
	func setupBlocks(){
		let chainArray = blockchain.arrayOfBlocks
		if chainArray.count > 0 {
			for _ in 1...chainArray.count-1 {
				newCube()
			}
		}
	}

	//Creates a new cube, animates its entrance
	func newCube(){
		let position = SCNVector3(x: currentCubePosX + 4, y: 10, z: 0)
		let cubeGeometry = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0.25)
		let newCubeNode = SCNNode(geometry: cubeGeometry)
		newCubeNode.position = position
		scene.rootNode.addChildNode(newCubeNode)

		SCNTransaction.begin()
		SCNTransaction.animationDuration = 3
		newCubeNode.position.y = 0
		SCNTransaction.completionBlock = {
			let connectorNode = SCNNode()
			let beg = SCNVector3(x: position.x-4, y: 0, z: 0)
			let end = SCNVector3(x: position.x, y: 0, z: 0)
			self.scene.rootNode.addChildNode(connectorNode.cylBetween(from: beg, to: end, radius: 0.2, color: .yellow))

			let spin = CABasicAnimation(keyPath: "rotation")
			spin.toValue = NSValue(scnVector4: SCNVector4(x: 0.0, y: 1.0, z: 1.0, w: Float(Double.pi)))
			spin.duration = 5
			spin.repeatCount = HUGE
			newCubeNode.addAnimation(spin, forKey: "spin me!")
		}
		self.currentCubePosX = position.x
		SCNTransaction.commit()
	}

	//Checks what nodes are tapped and will add the data nessecary
	@objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
		let scnView = self.view as! SCNView

		let p = gestureRecognize.location(in: scnView)
		if let hit = scnView.hitTest(p, options: nil).first {
			addTextData(hit: hit.node)
		}
	}

	//Will add the previous hash, current hash and block data through a text
	func addTextData(hit: SCNNode) {
		previousText.string = ""
		previousHash.string = ""
		previousPreviousHash.string = ""
		previousNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white

		nodePosition = hit.position
		hit.geometry?.firstMaterial?.diffuse.contents = UIColor.green

		let indexPos = (nodePosition.x + 4)/4

		let block = blockchain.arrayOfBlocks[Int(indexPos)]
		var transactionString = String()

		for transact in block.transactions {
			let txs = "\(transact) \n"
			transactionString.append(txs)
		}

		let dataText = SCNText(string: "Data:\n\(transactionString)", extrusionDepth: 0.1)
		dataText.firstMaterial?.diffuse.contents = UIColor.white
		dataText.font = UIFont(name: "Arial", size: 1)
		let dataTextNode = SCNNode(geometry: dataText)
		dataTextNode.position = SCNVector3(x: nodePosition.x, y: nodePosition.y+2, z: nodePosition.z)
		scene.rootNode.addChildNode(dataTextNode)

		let hashText = SCNText(string: "Hash:\n\(block.blockHashValue)", extrusionDepth: 0.1)
		hashText.firstMaterial?.diffuse.contents = UIColor.white
		hashText.font = UIFont(name: "Arial", size: 1)
		let blockTextNode = SCNNode(geometry: hashText)
		blockTextNode.position = SCNVector3(x: nodePosition.x, y: nodePosition.y-5, z: nodePosition.z)
		scene.rootNode.addChildNode(blockTextNode)

		let previousHashText = SCNText(string: "Previous Hash:\n\(block.previousBlockHashValue)", extrusionDepth: 0.1)
		previousHashText.firstMaterial?.diffuse.contents = UIColor.white
		previousHashText.font = UIFont(name: "Arial", size: 1)
		let prevHashNode = SCNNode(geometry: previousHashText)
		prevHashNode.position = SCNVector3(x: nodePosition.x, y: nodePosition.y-8, z: nodePosition.z)
		scene.rootNode.addChildNode(prevHashNode)

		//Sets as previous hash so that we can remove the previous nodes once we load new ones
		previousText = dataText
		previousPreviousHash = previousHashText
		previousHash = hashText
		previousNode = hit
	}

}

