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

class StockItem: SKNode {
  
  let type: String
  let flavor: String
  private var amount: Int
  
  private let maxAmount: Int
  private let relativeX: Float
  private let relativeY: Float
  private let stockingSpeed: Float
  private let sellingSpeed: Float
  private let stockingPrice: Int
  private let sellingPrice: Int
  
  private var gameDelegate: GameDelegate
  
  private var stockingTimer = SKLabelNode(fontNamed: "TrebuchetMS-Bold")
  private var progressBar: ProgressBar
  private var sellButton = SKSpriteNode(imageNamed: "sell_button")
  private var priceTag = SKSpriteNode(imageNamed: "price_tag")
  
  var state: State
  private var lastStateSwitchTime: CFAbsoluteTime
  
  init(stockItemData: [String: AnyObject], stockItemConfiguration: [String: NSNumber], gameDelegate: GameDelegate) {
    self.gameDelegate = gameDelegate
    
    // initialize item from data
    // instead of loadValuesWithData method
    maxAmount = (stockItemConfiguration["maxAmount"]?.intValue)!
    stockingSpeed = (stockItemConfiguration["stockingSpeed"]?.floatValue)! * TimeScale
    sellingSpeed = (stockItemConfiguration["sellingSpeed"]?.floatValue)! * TimeScale
    stockingPrice = (stockItemConfiguration["stockingPrice"]?.intValue)!
    sellingPrice = (stockItemConfiguration["sellingPrice"]?.intValue)!
    
    type = stockItemData["type"] as AnyObject? as! String
    amount = stockItemData["amount"] as AnyObject? as! Int
    relativeX = stockItemData["x"] as AnyObject? as! Float
    relativeY = stockItemData["y"] as AnyObject? as! Float
    
    var relativeTimerPositionX: Float? = stockItemConfiguration["timerPositionX"]?.floatValue
    if relativeTimerPositionX == nil {
      relativeTimerPositionX = Float(0.0)
    }
    var relativeTimerPositionY: Float? = stockItemConfiguration["timerPositionY"]?.floatValue
    if relativeTimerPositionY == nil {
      relativeTimerPositionY = Float(0.0)
    }
    
    flavor = stockItemData["flavor"] as AnyObject? as! String
    
    // Create progress bar
    if type == "cookie" {
      let baseName = String(format: "item_%@", type) + "_tray_%i"
      progressBar = DiscreteProgressBar(baseName: baseName)
      
    } else {
      let emptyImageName = NSString(format: "item_%@_empty", type)
      let fullImageName = NSString(format: "item_%@_%@", type, flavor)
      progressBar = ContinuousProgressBar(emptyImageName: emptyImageName as String, fullImageName: fullImageName as String)
    }
    
    let stateAsObject: AnyObject? = stockItemData["state"]
    let stateAsInt = stateAsObject as! Int
    state = State(rawValue: stateAsInt)!
    
    lastStateSwitchTime = stockItemData["lastStateSwitchTime"] as AnyObject? as! CFAbsoluteTime
    
    super.init()
    setupPriceLabel()
    setupStockingTimer(relativeX: relativeTimerPositionX!, relativeY: relativeTimerPositionY!)
    
    addChild(progressBar.node)
    isUserInteractionEnabled = true
    sellButton.zPosition = CGFloat(ZPosition.HUDForeground.rawValue)
    
    addChild(priceTag)
    addChild(stockingTimer)
    addChild(sellButton)
    
    switchTo(state: state)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupPriceLabel() {
    // Create price label tag
    let priceTagLabel = SKLabelNode(fontNamed: "TrebuchetMS-Bold")
    priceTagLabel.fontSize = 24
    priceTagLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
    priceTagLabel.text = String(format: "%i$", maxAmount * stockingPrice)
    priceTagLabel.fontColor = SKColor.black
    priceTagLabel.zPosition = CGFloat(ZPosition.HUDForeground.rawValue)
    priceTag.zPosition = CGFloat(ZPosition.HUDBackground.rawValue)
    priceTag.addChild(priceTagLabel)
  }
  
  func setupStockingTimer(relativeX: Float, relativeY: Float) {
    // Create stocking Timer
    stockingTimer.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
    stockingTimer.fontSize = 30
    stockingTimer.fontColor = SKColor(red: 198/255.0, green: 139/255.0, blue: 207/255.0, alpha: 1.0)
    stockingTimer.position = CGPoint(x: Int(relativeX * Float(progressBar.node.calculateAccumulatedFrame().size.width)), y: Int(relativeY * Float(progressBar.node.calculateAccumulatedFrame().size.height)))
    stockingTimer.zPosition = CGFloat(ZPosition.HUDForeground.rawValue)
  }
  
  func updateStockingTimerText() {
    let stockingTimeTotal = CFTimeInterval(Float(maxAmount) * stockingSpeed)
    let currentTime = CFAbsoluteTimeGetCurrent()
    let timePassed = currentTime - lastStateSwitchTime
    let stockingTimeLeft = stockingTimeTotal - timePassed
    stockingTimer.text = String(format: "%.0f", stockingTimeLeft)
  }
  
  func switchTo(state: State) {
    if self.state != state {
      lastStateSwitchTime = CFAbsoluteTimeGetCurrent()
    }
    self.state = state
    switch state {
    case .empty:
      stockingTimer.isHidden = true
      sellButton.isHidden = true
      priceTag.isHidden = false
    case .stocking:
      stockingTimer.isHidden = false
      sellButton.isHidden = true
      priceTag.isHidden = true
    case .stocked:
      stockingTimer.isHidden = true
      sellButton.isHidden = false
      priceTag.isHidden = true
      progressBar.setProgress(percentage: 1)
    case .selling:
      stockingTimer.isHidden = true
      sellButton.isHidden = true
      priceTag.isHidden = true
    }
  }
  
  func update() {
    let currentTimeAbsolute = CFAbsoluteTimeGetCurrent()
    let timePassed = currentTimeAbsolute - lastStateSwitchTime
    switch state {
    case .stocking:
      updateStockingTimerText()
      amount = min(Int(Float(timePassed) / stockingSpeed), maxAmount)
      if amount == maxAmount {
        switchTo(state: .stocked)
      }
    case .selling:
      let previousAmount = amount
      amount = maxAmount - min(maxAmount, Int(Float(timePassed) / sellingSpeed))
      let amountSold = previousAmount - amount
      if amountSold >= 1 {
        let _ = gameDelegate.updateMoney(by: sellingPrice * amountSold)
        progressBar.setProgress(percentage: Float(amount) / Float(maxAmount))
        if amount <= 0 {
          switchTo(state: .empty)
        }
      }
    default:
      break
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    switch state {
    case .empty:
      let bought = gameDelegate.updateMoney(by: -stockingPrice * maxAmount)
      if bought {
        switchTo(state: .stocking)
      } else {
        let playSound = SKAction.playSoundFileNamed("hit.wav", waitForCompletion: true)
        run(playSound)
        
        let rotateLeft = SKAction.rotate(byAngle: 0.2, duration: 0.1)
        let rotateRight = rotateLeft.reversed()
        let shakeAction = SKAction.sequence([rotateLeft, rotateRight])
        let repeatAction = SKAction.repeat(shakeAction, count: 3)
        priceTag.run(repeatAction)
      }
    case .stocked:
      switchTo(state: .selling)
    case .selling:
      gameDelegate.serveCustomerWithItemOfType(type: type, flavor: flavor)
    default:
      break
    }
  }
  
  func notificationMessage() -> String? {
    switch state {
    case .selling:
      return String(format: "Your %@ %@ sold out! Remember to restock.", flavor, type)
    case .stocking:
      return String(format: "Your %@ %@ is now fully stocked and ready for sale.", flavor, type)
    default:
      return nil
    }
  }
  
  func notificationTime() -> TimeInterval {
    switch state {
    case .selling:
      return TimeInterval(sellingSpeed * Float(amount))
    case .stocking:
      let stockingTimeRequired = stockingSpeed * Float(maxAmount - amount)
      return TimeInterval(stockingTimeRequired)
    default:
      return -1
    }
  }
  
  // MARK: - Write dictionary for storage of StockItem
  func data() -> NSDictionary {
    let data = NSMutableDictionary()
    data["type"] = type
    data["flavor"] = flavor
    data["amount"] = amount
    data["x"] = relativeX
    data["y"] = relativeY
    data["state"] = state.rawValue
    data["lastStateSwitchTime"] = lastStateSwitchTime
    return data
  }
  
}
