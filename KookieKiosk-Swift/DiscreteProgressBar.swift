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

class DiscreteProgressBar: ProgressBar {
  
  var node : SKNode
  private var currentSprite = SKSpriteNode()
  private let sprites: [SKTexture]
  
  init(baseName: String) {
    node = SKNode()
    var spritesTemp = [SKTexture]()
    var count = 0
    var fileExists: Bool
    repeat {
      let fileName = String(format: baseName, count)
      let image : UIImage? = UIImage(named: fileName)
      if image == nil {
        fileExists = false
      } else {
        spritesTemp.append(SKTexture(image: image!))
        fileExists = true
      }
      count += 1
    } while fileExists
    sprites = spritesTemp
    currentSprite = SKSpriteNode(texture: spritesTemp[0])
    currentSprite.zPosition = CGFloat(ZPosition.stockItemsBackground.rawValue)
    node.addChild(currentSprite)
    setProgress(percentage: 0)
  }
  
  func setProgress(percentage: Float) {
    let spriteNumber = min(Int(percentage * Float(sprites.count)), sprites.count - 1)
    let texture = sprites[spriteNumber]
    currentSprite.texture = texture
  }
  
}
