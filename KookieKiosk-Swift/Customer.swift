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

class Customer: SKNode {
  
  let type: String
  let flavor: String
  
  var hasBeenServed = false
  
  init(type: String, flavor: String) {
    self.type = type
    self.flavor = flavor
    super.init()
    
    let customerNode = SKNode()
    let customerFile = String(format: "customer_%i", arc4random() % 3 + 1)
    let customerSprite = SKSpriteNode(imageNamed: customerFile)
    let bubble = SKSpriteNode(imageNamed: "thought_bubble")
    
    let width = max(customerSprite.size.width, bubble.size.width)
    let height = customerSprite.size.height + bubble.size.height
    
    customerSprite.position = CGPoint(x: (width - customerSprite.size.width) / 2, y: -(height - customerSprite.size.height) / 2)
    customerSprite.zPosition = CGFloat(ZPosition.HUDBackground.rawValue)
    bubble.position = CGPoint(x: (width - bubble.size.width) / 2, y: (height - bubble.size.height) / 2 - 10)
    bubble.zPosition = CGFloat(ZPosition.HUDBackground.rawValue)
    customerNode.addChild(customerSprite)
    customerNode.addChild(bubble)
    addChild(customerNode)
    
    let wishSprite = SKSpriteNode(imageNamed: String(format: "wish_%@_%@", type, flavor))
    wishSprite.position = CGPoint(x: 0, y: bubble.size.height * 0.1)
    wishSprite.zPosition = bubble.zPosition + 1
    wishSprite.zPosition = CGFloat(ZPosition.HUDForeground.rawValue)
    bubble.addChild(wishSprite)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
