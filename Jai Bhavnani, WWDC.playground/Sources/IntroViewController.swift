import Foundation
import PlaygroundSupport
import SceneKit
import QuartzCore
import AVFoundation
import XCPlayground

/*

View Description: The introductory view, introduces the project. Presented on top of the HomeViewController

*/

public class IntroViewController: UIViewController {
	//Both of these are labels for conveying text to the audience
	var welcomeLabel = UILabel()
	var descLabel = UILabel()

	//The blur and blur effect to provide a visual way to differentiate between the text and the background
	let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
	var blurEffectView = UIVisualEffectView()

	//The text that will bellong within both of the labels defined above
	let welcomeText = "welcome to my shop!"
	let descText = "this is an example of a shop that runs on blockchain to prevent fraud through a public ledger. click on an item inside of the shop to add it to your cart and press on the door to exit and checkout. you are allowed to buy mangoes, bananas, chilis and more! \ndrag to move around and view different perspectives \n\ndouble tap to proceed."

	//When view loads - add a gesture recognizer and blur affect view and setup the labels
	override public func viewDidLoad() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
		tap.numberOfTapsRequired = 2
		view.addGestureRecognizer(tap)

		blurEffectView = UIVisualEffectView(effect: blurEffect)
		blurEffectView.frame = view.bounds
		view.addSubview(blurEffectView)

		setupLabels()
	}

	//Sets up the labels, as called by the viewdidload. It will animate the text within the description label.
	func setupLabels(){
		welcomeLabel = UILabel(frame: CGRect(x: 20, y: self.view.frame.height-300, width: view.frame.width, height: 45))
		welcomeLabel.font = UIFont(name: "Arial", size: 40)
		welcomeLabel.textAlignment = .left
		welcomeLabel.textColor = UIColor.white
		welcomeLabel.text = welcomeText
		self.view.addSubview(welcomeLabel)
		UIView.animate(withDuration: 3, delay: 1, options: [.curveEaseOut], animations: {
			self.welcomeLabel.center.y -= 300
			self.view.layoutIfNeeded()
		}, completion: nil)

		descLabel = UILabel(frame: CGRect(x: 20, y: self.view.frame.height-350, width: view.frame.width-100, height: 300))
		descLabel.font = UIFont(name: "Arial", size: 20)
		descLabel.numberOfLines = 0
		descLabel.textAlignment = .left
		descLabel.textColor = UIColor.white
		descLabel.text = descText
		descLabel.typewriterAnimate(addedText: descText, delayOfCharacters: 0.1)
		self.view.addSubview(descLabel)
		self.descLabel.center.y -= 200
		descLabel.sizeToFit()
	}

	//When the view has been double tapped it will remove the blur effect and labels
	@objc func doubleTapped() {
		UIView.animate(withDuration: 1) {
			self.blurEffectView.effect = nil
		}
		welcomeLabel.removeFromSuperview()
		descLabel.removeFromSuperview()
	}
}
