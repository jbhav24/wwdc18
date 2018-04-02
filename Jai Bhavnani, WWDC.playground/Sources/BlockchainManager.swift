import Foundation
import PlaygroundSupport
import SceneKit
import QuartzCore
import AVFoundation
import XCPlayground

/**

Description: Creates the blockchain

**/

//Creates the block structure itself
struct Block {
	public private(set) var previousBlockHashValue: Int
	public private(set) var transactions:[String]

	//Each block needs its own has, here they are attributed
	var blockHashValue: Int {
		get {
			var hashValues:Float = Float(previousBlockHashValue)

			for transaction in transactions {
				hashValues += Float(transaction.hashValue)
			}

			return String(hashValues).hashValue
		}
	}

	//Initializes the transactions, prev hash value
	init(_ transactions:[String], _ previousBlockHashValue: Int) {
		self.transactions = transactions
		self.previousBlockHashValue = previousBlockHashValue
	}
}

//Creates the blockchain structure
struct BlockChain {
	public private(set) var arrayOfBlocks:[Block] = [Block]() //An array of the structure: Block
	public private(set) var lastBlockHashValue:Int = 0

	mutating func add(_ newBlock: Block) {
		if lastBlockHashValue == 0 || lastBlockHashValue == newBlock.previousBlockHashValue {
			arrayOfBlocks.append(newBlock)
			lastBlockHashValue = newBlock.blockHashValue
		} else {
			print("Failed to add block hash: \(newBlock.blockHashValue)")
		}
	}
}


