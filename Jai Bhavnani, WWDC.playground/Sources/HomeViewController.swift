import Foundation
import PlaygroundSupport
import SceneKit
import QuartzCore
import AVFoundation
import XCPlayground

/**

View Description: The home view, or the shop view built with Scenekit where users will be able to select items and it will be added to the blockchain while it plays music.

**/

public class HomeViewController: UIViewController {
	//A set of purchasable, the user is limited to buying these items
	let purchasable = ["banana", "durian", "chili", "vase", "mango"]

	//An array of what is inside of the shopping cart at any given time
	var shoppingCart = [String]()

	//The child view, it is populated by IntroViewController to present the user with starting information
	var cView = UIView()

	//Background of the cashier view, to allow people to view the text properly
	var cashierView = UIView()

	//The current text view of what is inside the shopping cart
	var shoppingCartTextView = UITextView()

	//The error label, will be presented whenever the user tries to do something that they are not suppose to do
	var errorLabel = UILabel()

	//Determines whether the child view has been hidden or not
	var childHidden = false

	//The audioplayer for playing music
	var player: AVAudioPlayer?

	//View has been loaded
	override public func viewDidLoad() {
		super.viewDidLoad()
		createGenesisBlock()
		setupScene()
		setupChild()
		setupCart()

		playMusic()
	}

	//Creates a timer that will check up on the user to make sure they know how to exit the scene, in case they didn't read the instructions

	
	func setupCheckup(){
		_ = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(conductCheckup), userInfo: nil, repeats: false)
	}

	//Alerts the user as to how they can exit the view if they didn't know
	@objc func conductCheckup(){
		errorMessage(message: "Remember, you press on the door to leave the view and see a visual of your purchases.")
	}

	//Gets song and plays music on an infinite loop
	func playMusic() {
		guard let url = Bundle.main.url(forResource: "song", withExtension: "mp3") else { return }
		do {
			try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
			try AVAudioSession.sharedInstance().setActive(true)
			player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
			guard let player = player else { return }
			player.volume = 0.1
			player.numberOfLoops = -1
			player.play()
		} catch let error {
			print(error.localizedDescription)
		}
	}

	//Sets up the views for showing the user what is inside of their cart, will only show when a user has clicked on an item for their cart
	func setupCart(){
		cashierView = UIView(frame: CGRect(x: playgroundSize.width-130, y: 20, width: 100, height: 200))
		cashierView.backgroundColor = UIColor.white
		view.addSubview(cashierView)
		cashierView.isHidden = true

		shoppingCartTextView = UITextView(frame: cashierView.frame)
		shoppingCartTextView.textColor = UIColor.black
		shoppingCartTextView.text = "Shopping Cart: "
		shoppingCartTextView.font = UIFont(name: "Arial", size: 13)
		shoppingCartTextView.isUserInteractionEnabled = true
		view.addSubview(shoppingCartTextView)
		shoppingCartTextView.isHidden = true
	}

	//Creates the gensis block, it is important to see that the previousHash was 0 because this is the gensis block
	func createGenesisBlock() {
		let genesisBlock = Block(["genesis"], 0)
		blockchain.add(genesisBlock)
	}

	//Sets up the scene usingn the scn file and then adds camera and sets up gesture recognizer
	func setupScene(){
		// create a new scene
		let scene = SCNScene(named: "basar.scn")!

		// create and add a camera to the scene
		let cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		scene.rootNode.addChildNode(cameraNode)
		cameraNode.position = SCNVector3(x: 0, y: -15, z: 5)
		cameraNode.look(at: SCNVector3(x: 0, y: 21, z: -5))

		let scnView = SCNView()
		scnView.scene = scene
		scnView.allowsCameraControl = true
		scnView.backgroundColor = UIColor.cyan
		self.view = scnView

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
		scnView.addGestureRecognizer(tapGesture)
	}

	//Puts the intro view controller on top and then will ensure that the variable 'childHidden' reflects
	func setupChild(){
		let childViewController = IntroViewController()
		cView = childViewController.view
		self.addChildViewController(childViewController)
		self.view.addSubview(cView)

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeChild(_:)))
		cView.addGestureRecognizer(tapGesture)

		childViewController.didMove(toParentViewController: self)
		view.bringSubview(toFront: cView)

		childHidden = true
	}

	//Will remove intro view controller when the view has been tapped, sets up the checkup here so that it will only show once the IntroView has been removed
	@objc func removeChild(_ gestureRecognize: UIGestureRecognizer) {
 		cView.removeFromSuperview()

		setupCheckup()
	}

	//Function so that when something has been added to the cart it will be reflected on the text field and appended to ShoppingCart
	func addToCart(item: String){
		shoppingCartTextView.isHidden = false
		cashierView.isHidden = false

		shoppingCart.append("\(item)")
		shoppingCartTextView.text = "Shopping Cart: "

		for (item, count) in shoppingCart.frequencyTuple() {
			shoppingCartTextView.text.append("\(item) x\(count) \n ")
		}
	}

	//When someone is ready to checkout, it will ensure that they are ready and then add their cart as a new block to the blockchain. If not, it will present their error at hand.
	@objc func checkout(){
		if shoppingCart.count == 0 {
			errorMessage(message: "You have nothing in your cart!\nPress on some items in the shop, like a mango!")
		}else{
			let newBlock = Block(shoppingCart, blockchain.lastBlockHashValue)
			blockchain.add(newBlock)
			eskeetitMoveOn()
		}
	}

	//Develoepd a global access for error messages, so this data didn't need to be established every single time we want to present an error to the user
	func errorMessage(message: String) {
		errorLabel.isHidden = false
		errorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 550, height: 80))
		errorLabel.textAlignment = .center
		errorLabel.numberOfLines = 0
		errorLabel.text = message
		errorLabel.font = UIFont(name: "Arial", size: 25)
		errorLabel.backgroundColor = UIColor.black
		errorLabel.textColor = UIColor.white
		self.view.addSubview(errorLabel)
		errorLabel.center = CGPoint(x: playgroundSize.width/2, y: playgroundSize.height/2)

		_ = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(hideErrorLabel), userInfo: nil, repeats: false)
		
	}

	//Hides the error label after 4 seconds, that should be enough time for them to read what is wrong with it
	@objc func hideErrorLabel(){
		errorLabel.isHidden = true
	}

	//This is what handles the tap. If user taps the door, then they will checkout. If the user taps on an item then it will add it to their cart.
	@objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
		// retrieve the SCNView
		let scnView = self.view as! SCNView

		// check what nodes are tapped
		let p = gestureRecognize.location(in: scnView)
		let hitResults = scnView.hitTest(p, options: [:])
		// check that we clicked on at least one object

		if hitResults.count > 0 {
			// retrieved the first clicked object
			let result = hitResults[0]
			// get its material

			if childHidden == true {
				let material = result.node.geometry!.firstMaterial!
				if material.name! == "doormaterial" {
					checkout()
				}
				for item in purchasable {
					if material.name!.lowercased().range(of:item) != nil {
						addToCart(item: material.name!.cutdown())
						result.node.removeFromParentNode()
					}
				}
			}
		}
	}

	//This is what allows the user to move on 
	func eskeetitMoveOn(){
		let newController = ExpViewController()
		newController.preferredContentSize = playgroundSize
		PlaygroundPage.current.liveView = newController
	}
}
