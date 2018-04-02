import Foundation
import PlaygroundSupport
import SceneKit
import QuartzCore
import AVFoundation
import XCPlayground

/**

View Description: The message view that goes on top of the ExpViewController to present a set of predefined messages. ALSO allows user to add more blocks to the blockchain

**/

public class MessageViewController: UIViewController {

	//The label that will be animating up and down to bring text to the audience
	var helperLabel = UILabel()

	//The boolean that will determine whether it should speak or not
	var shouldSpeak = false

	//The view size
	var viewFrame = CGSize()

	//The button that will permit it's speaking
	var speakerButton = UIButton()

	//A set of messages that will be conveyed to the user using the label above and the speaker button if needed
	let messages = ["Press on the volume button (top left) if you need dictation.",
					"Welcome to the public ledger, a visualization of the purchases currently on the blockchain.",
					"The first block is called the genesis block. The second block will have your transactions, try tapping on them!",
					"Cool, huh?",
					"What is a blockchain?",
					"A blockchain is an array of blocks. Blocks have three main parts",
					"The first part is the hash, it is a unique identifier for each block.",
					"The second part is the hash of the previous block.",
					"The third part is the data. In our case, it was your transactions at the shop.",
					"I've added a few more blocks to the chain, try and play around with them! Double tap to recenter yourself.",
					"Why would anybody use a blockchain?",
					"The hashes built into the chain make it very difficult to add fake transactions. This prevents fraud.",
					"If someone attempted to change any data within a single block, it would invalidate all of the following blocks.",
					"This technology could be deployed to applications like loan management, tax collection, and many others.",
					"Try adding more blocks by pressing on the button!",
					"Thank you so much for watching! I hope you learned something and I hope to see you at WWDC!"
	]

	//Set up buttons for adjustment
	var moreButton = UIButton()

	//View did load
	override public func viewDidLoad() {
		viewFrame = self.view.frame.size
		setupText()
		setupSpeaker()
		setupMoreButton()
	}

	//Sets up the button for easy addition of blocks to the chain
	func setupMoreButton(){
		_ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(check), userInfo: nil, repeats: true)

		moreButton = UIButton(frame: CGRect(x: view.frame.width-200, y: 100, width: 120, height: 50))
		moreButton.backgroundColor = UIColor.blue
		moreButton.setTitle("Add Block", for: .normal)
		moreButton.addTarget(self, action: #selector(addTo), for: .touchUpInside)
		moreButton.layer.cornerRadius = 10
		moreButton.layer.masksToBounds = true
		self.view.addSubview(moreButton)
		moreButton.titleLabel?.font = UIFont(name: "Arial", size: 16)
		moreButton.isHidden = true
	}

	//Adds to the global block amount variable; makes text reflect it
	@objc func addTo(){
		blockAmount = blockAmount + 1
	}

	//Checks up on the messageIndex and will permit adding dependant on that
	@objc func check(){
		if messagesIndex >= adjustableAllowedOn {
			moreButton.isHidden = false
		}
	}

	//Establishes the button where people can press on it for dictation
	func setupSpeaker(){
		speakerButton = UIButton(frame: CGRect(x: 100, y: self.viewFrame.height*0.05, width: 20, height: 20))
		speakerButton.tintColor = .green
		speakerButton.addTarget(self, action: #selector(needsSpeaking), for: .touchUpInside)
		speakerButton.setImage(UIImage(named: "volume.png"), for: UIControlState.normal)
		self.view.addSubview(speakerButton)
	}

	//Function called to change the variable determining whether it should sepak
	@objc func needsSpeaking(){
		if shouldSpeak == true {
			shouldSpeak = false
			speakerButton.tintColor = UIColor.white
		}else if shouldSpeak == false {
			shouldSpeak = true
			speakerButton.tintColor = UIColor.green
		}
	}

	//Sets up the text on a timer of 10 seconds that will animate the label coming in and out
	func setupText(){
		helperLabel = UILabel(frame: CGRect(x: self.viewFrame.width/2, y: 900, width: 500, height: 90))
		helperLabel.font = UIFont(name: "Arial", size: 20)
		helperLabel.textAlignment = .center
		helperLabel.textColor = UIColor.white
		resetText()
		view.addSubview(helperLabel)
		showText()

		_ = Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(showText), userInfo: nil, repeats: true)
	}

	//Shows text coming in and out using UIView's animations
	@objc func showText() {
		UIView.animate(withDuration: 1, delay:2, options: [.curveEaseInOut], animations: {
			self.helperLabel.center = CGPoint(x: self.viewFrame.width/2, y: self.viewFrame.height*0.625)
		}, completion: {
			(value: Bool) in
			UIView.animate(withDuration: 1, delay: 4, options: [.curveEaseInOut], animations: {
				self.helperLabel.center = CGPoint(x: self.viewFrame.width/2, y: 900)
			}, completion: {
				(value: Bool) in
				self.resetText()
			})
		})
	}

	//Resets the text using the timer established above as a guideline to move onto the next message
	func resetText(){
		if messages.count > messagesIndex {
			let message = messages[messagesIndex]
			messagesIndex = messagesIndex + 1
			helperLabel.text = message
			if shouldSpeak == true {
				speak(input: message)
			}
		}else{
			helperLabel.text = ""
			UIView.animate(withDuration: 1) {
				self.speakerButton.center.y = self.speakerButton.center.y + 1000
			}
		}
		helperLabel.numberOfLines = 0
	}

	//Speaks, for those who need to be spoken to 
	func speak(input: String) {
		let speaker = AVSpeechUtterance(string: input)
		speaker.voice = AVSpeechSynthesisVoice(language: "en-US")
		let synthesizer = AVSpeechSynthesizer()
		synthesizer.speak(speaker)
	}
}

