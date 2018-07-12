/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SpriteKit
import Foundation

class ContinuousProgressBar: ProgressBar {
  var node: SKNode
  var emptyItem: SKSpriteNode
  var fullItem: SKCropNode
  var fullSprite: SKSpriteNode
  
  init(emptyImageName: String, fullImageName: String) {
    node = SKNode()
    emptyItem = SKSpriteNode(imageNamed: emptyImageName)
    emptyItem.zPosition = CGFloat(ZPosition.stockItemsBackground.rawValue)
    fullItem = SKCropNode()
    fullItem.zPosition = CGFloat(ZPosition.stockItemsForeground.rawValue)
    fullSprite = SKSpriteNode(imageNamed: fullImageName)
    fullItem.addChild(fullSprite)
    node.addChild(emptyItem)
    node.addChild(fullItem)
    setProgress(percentage: 0)
  }
  
  func setProgress(percentage: Float) {
    let mask = SKShapeNode()
    mask.fillColor = mask.strokeColor
    
    let maskRect = CGRect(x: Int(-fullSprite.size.width) / 2, y: Int(-fullSprite.size.height), width: Int(fullSprite.size.width), height: Int(Float(fullSprite.size.height) * percentage))
    
    mask.path = CGPath(rect: maskRect, transform: nil)
    let view = SKView()
    let maskTexture = view.texture(from: mask)
    fullItem.maskNode = SKSpriteNode(texture: maskTexture)
  }
  
}
