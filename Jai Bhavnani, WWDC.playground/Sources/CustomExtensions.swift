import Foundation
import PlaygroundSupport
import SceneKit
import QuartzCore
import AVFoundation
import XCPlayground

/**

Description: A set of extensions used throughout the project

**/

//Used to pick a random item within an array
extension Array {
	func randomItem() -> Element? {
		if isEmpty { return nil }
		let index = Int(arc4random_uniform(UInt32(self.count)))
		return self[index]
	}
}

//Used to animate with a typing affect on the intro screen
extension UILabel {
	func typewriterAnimate(addedText: String, delayOfCharacters: TimeInterval) {
		DispatchQueue.main.async {
			self.text = ""
			for (index, character) in addedText.characters.enumerated() {
				DispatchQueue.main.asyncAfter(deadline: .now() + delayOfCharacters * Double(index)) {
					self.text?.append(character)
				}
			}
		}
	}
}

//Used to return a certain count along with a given string per Sequence
extension Sequence where Self.Iterator.Element: Equatable {
	private typealias Element = Self.Iterator.Element
	func frequencyTuple() -> [(element: Element, count: Int)] {
		let empty: [(Element, Int)] = []
		return reduce(empty) { (accu: [(Element, Int)], element) in
			var accu = accu
			for (index, value) in accu.enumerated() {
				if value.0 == element {
					accu[index].1 += 1
					return accu
				}
			}
			return accu + [(element, 1)]
		}
	}
}

//Helps cleanse the arrays, removes the numbers along with the underscores
extension String {
	func cutdown() -> String {
		var string = self.components(separatedBy: CharacterSet.decimalDigits).joined()
		string = string.replacingOccurrences(of: "_", with: "", options: .literal, range: nil)
		return string
	}
}

//Normalizes the vectors for use
func normalizeVector(_ iv: SCNVector3) -> SCNVector3 {
	let length = sqrt(iv.x * iv.x + iv.y * iv.y + iv.z * iv.z)
	if length == 0 {
		return SCNVector3(0.0, 0.0, 0.0)
	}

	return SCNVector3( iv.x / length, iv.y / length, iv.z / length)
}


extension SCNNode {
	//Creates a cylinder in between two different points 
	func cylBetween(from beginningPoint: SCNVector3, to finalPoint: SCNVector3, radius: CGFloat, color: UIColor) -> SCNNode {
		let width = SCNVector3(x: finalPoint.x-beginningPoint.x, y: finalPoint.y-beginningPoint.y, z: finalPoint.z-beginningPoint.z)
		let length = CGFloat(sqrt(width.x * width.x + width.y * width.y + width.z * width.z))
		if length == 0.0 {
			let sphere = SCNSphere(radius: radius)
			sphere.firstMaterial?.diffuse.contents = color
			self.geometry = sphere
			self.position = beginningPoint
			return self
		}

		let cylinder = SCNCylinder(radius: radius, height: length)
		cylinder.firstMaterial?.diffuse.contents = color
		self.geometry = cylinder

		let origVector = SCNVector3(0, length/2.0,0)
		let newVector = SCNVector3((finalPoint.x - beginningPoint.x)/2.0, (finalPoint.y - beginningPoint.y)/2.0,
								   (finalPoint.z-beginningPoint.z)/2.0)
		let axisVector = SCNVector3( (origVector.x + newVector.x)/2.0, (origVector.y+newVector.y)/2.0, (origVector.z+newVector.z)/2.0)

		let av_normalized = normalizeVector(axisVector)
		let q0 = Float(0.0)
		let q1 = Float(av_normalized.x)
		let q2 = Float(av_normalized.y)
		let q3 = Float(av_normalized.z)

		let r_m11 = q0 * q0 + q1 * q1 - q2 * q2 - q3 * q3
		let r_m12 = 2 * q1 * q2 + 2 * q0 * q3
		let r_m13 = 2 * q1 * q3 - 2 * q0 * q2
		let r_m21 = 2 * q1 * q2 - 2 * q0 * q3
		let r_m22 = q0 * q0 - q1 * q1 + q2 * q2 - q3 * q3
		let r_m23 = 2 * q2 * q3 + 2 * q0 * q1
		let r_m31 = 2 * q1 * q3 + 2 * q0 * q2
		let r_m32 = 2 * q2 * q3 - 2 * q0 * q1
		let r_m33 = q0 * q0 - q1 * q1 - q2 * q2 + q3 * q3

		self.transform.m11 = r_m11
		self.transform.m12 = r_m12
		self.transform.m13 = r_m13
		self.transform.m14 = 0.0
		self.transform.m21 = r_m21
		self.transform.m22 = r_m22
		self.transform.m23 = r_m23
		self.transform.m24 = 0.0
		self.transform.m31 = r_m31
		self.transform.m32 = r_m32
		self.transform.m33 = r_m33
		self.transform.m34 = 0.0
		self.transform.m41 = (beginningPoint.x + finalPoint.x) / 2.0
		self.transform.m42 = (beginningPoint.y + finalPoint.y) / 2.0
		self.transform.m43 = (beginningPoint.z + finalPoint.z) / 2.0
		self.transform.m44 = 1.0
		return self
	}
}
