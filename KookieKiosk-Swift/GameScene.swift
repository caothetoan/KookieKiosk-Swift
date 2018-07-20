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
import UserNotifications

class GameScene: SKScene {
  var money = 0
  var stockItems: [StockItem] = []
  var stockItemConfigurations = [String: [String: NSNumber]]()
  
  var moneyLabel = SKLabelNode(fontNamed: "TrebuchetMS-Bold")
  
  let hitSound = SKAction.playSoundFileNamed("hit.wav", waitForCompletion: false)
  let coinSound = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
  
  var customer: Customer?
  var timeOfLastCustomer: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
  var timeTillNextCustomer: CFTimeInterval!
  
  override func didMove(to view: SKView) {
    NotificationCenter.default.addObserver(self, selector: #selector(saveGameData), name: NSNotification.Name(rawValue: "saveGameData"), object: nil)
    
    // Draw background
    let background = SKSpriteNode(imageNamed: "bg_kookiekiosk")
    background.position = CGPoint(x: size.width/2, y: size.height/2)
    background.zPosition = CGFloat(ZPosition.background.rawValue)
    addChild(background)
    
    // Draw HUD in top right corner that displays the amount of money the player has
    let moneyBackground = SKSpriteNode(imageNamed: "bg_money")
    moneyBackground.position = CGPoint(x: size.width - moneyBackground.size.width/2 - 10, y: size.height - moneyBackground.size.height/2 - 13)
    moneyBackground.zPosition = CGFloat(ZPosition.HUDBackground.rawValue)
    addChild(moneyBackground)
    
    moneyLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
    moneyLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
    moneyLabel.position = CGPoint(x: size.width - 60, y: size.height - 115)
    moneyLabel.fontColor = SKColor(red: 156/255.0, green: 179/255.0, blue: 207/255.0, alpha: 1.0)
    moneyLabel.fontSize = 50
    moneyLabel.zPosition = CGFloat(ZPosition.HUDForeground.rawValue)
    addChild(moneyLabel)
    
    loadGameData()
    determineTimeTillNextCustomer()
    
    NotificationCenter.default.addObserver(self, selector: #selector(scheduleNotifications), name: NSNotification.Name(rawValue: "scheduleNotifications"), object: nil)
  }
  
  func determineTimeTillNextCustomer() {
    timeTillNextCustomer = CFTimeInterval(Float((arc4random_uniform(UInt32(15)) + 15)) * TimeScale)
  }
  
  override func update(_ currentTime: TimeInterval) {
    for stockItem in stockItems {
      stockItem.update()
    }
    
    // 1
    let currentTimeAbsolute = CFAbsoluteTimeGetCurrent()
    if customer == nil && currentTimeAbsolute - timeOfLastCustomer > timeTillNextCustomer {
      // 2
      var potentialWishes: [StockItem] = []
      for stockItem in stockItems {
        if stockItem.state == .selling || stockItem.state == .stocked {
          potentialWishes.append(stockItem)
        }
      }
      // 3
      if potentialWishes.count > 0 {
        let random = arc4random_uniform(UInt32(potentialWishes.count))
        let randomStockItem = potentialWishes[Int(random)]
        customer = Customer(type: randomStockItem.type, flavor: randomStockItem.flavor)
        customer!.position = CGPoint(x: frame.size.width + customer!.calculateAccumulatedFrame().size.width / 2, y: customer! .calculateAccumulatedFrame().size.height / 2)
        // 4
        let moveLeft = SKAction.move(by: CGVector(dx: -customer!.calculateAccumulatedFrame().size.width, dy: 0), duration: 1)
        customer?.run(moveLeft)
        addChild(customer!)
      }
    }
  }
  
  func scheduleNotificationWith(body: String, intervalInSeconds: TimeInterval, badgeNumber: Int) {
    // 1
    let localNotification = UNMutableNotificationContent()
    
    // 2
    localNotification.body = body
    localNotification.sound = UNNotificationSound.default()
    localNotification.badge = badgeNumber as NSNumber?
    
    // 3
    let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: intervalInSeconds, repeats: false)
    let request = UNNotificationRequest.init(identifier: body, content: localNotification, trigger: trigger)
    
    // 4
    let center = UNUserNotificationCenter.current()
    center.add(request)
  }
  
  func scheduleNotifications() {
    let itemsSortedByNotificationTime = stockItems.sorted(by: { $0.notificationTime() < $1.notificationTime() })
    var count = 1
    for stockItem in itemsSortedByNotificationTime {
      let notificationMessage = stockItem.notificationMessage()
      if notificationMessage != nil {
        scheduleNotificationWith(body: notificationMessage!, intervalInSeconds: stockItem.notificationTime(), badgeNumber: count)
        count += 1
      }
    }
  }
  
  // MARK: - Load and save plist file
  func saveGameData() {
    let path = documentFilePath(fileName: "gamedata.plist")
    let stockItemData = NSMutableArray()
    for stockItem : StockItem in stockItems {
      stockItemData.add(stockItem.data())
    }
    var stockItemConfigurationsObjects = [AnyObject]()
    var stockItemConfigurationsKeys = [NSCopying]()
    for (key, stockItemConfiguration) in stockItemConfigurations {
      stockItemConfigurationsKeys.append(key as NSCopying)
      stockItemConfigurationsObjects.append(stockItemConfiguration as AnyObject)
    }
    
    let stockItemConfigurationsNSDictionary = NSDictionary(objects: stockItemConfigurationsObjects, forKeys: stockItemConfigurationsKeys)
    let objects = [stockItemConfigurationsNSDictionary, money, stockItemData] as [Any]
    let keys = ["stockItemConfigurations", "money", "stockItemData"]
    let gameData = NSDictionary(objects: objects, forKeys: keys as [NSCopying])
    gameData.write(toFile: path, atomically: true)
  }
  
  func loadGameData() {
    var path = documentFilePath(fileName: "gamedata.plist")
    var gameData : NSDictionary? = NSDictionary(contentsOfFile: path)
    // Load gamedata template from mainBundle if no saveFile exists
    if gameData == nil {
      let mainBundle = Bundle.main
      path = mainBundle.path(forResource: "gamedata", ofType: "plist")!
      gameData = NSDictionary(contentsOfFile: path)
    }
    
    stockItemConfigurations = gameData!["stockItemConfigurations"] as! [String: [String: NSNumber]]
    money = gameData!["money"] as! Int
    moneyLabel.text = String(format: "%i $", money)
    let stockItemDataSet = gameData!["stockItemData"] as! [[String: AnyObject]]
    for stockItemData in stockItemDataSet {
      let itemType = stockItemData["type"] as! String
      let stockItemConfiguration = stockItemConfigurations[itemType] as [String: NSNumber]?
      let stockItem  = StockItem(stockItemData: stockItemData, stockItemConfiguration: stockItemConfiguration!, gameDelegate: self)
      let relativeX = stockItemData["x"]?.floatValue
      let relativeY = stockItemData["y"]?.floatValue
      stockItem.position = CGPoint(x: Int(relativeX! * Float(size.width)), y: Int(relativeY! * Float(size.height)))
      addChild(stockItem)
      stockItems.append(stockItem)
    }
  }
  
  func documentFilePath(fileName: String) -> String {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentsURL.appendingPathComponent(fileName)
    return fileURL.path
  }
  
}

// MARK: - GameDelegate
extension GameScene: GameDelegate {
  
  func updateMoney(by delta: Int) -> Bool {
    if money + delta < 0 {
      return false
    }
    let deltaLabel = SKLabelNode(fontNamed: "TrebuchetMS-Bold")
    if delta < 0 {
      deltaLabel.fontColor = SKColor(red: 198/255.0, green: 139/255.0, blue: 207/255.0, alpha: 1.0)
    } else {
      deltaLabel.fontColor = SKColor(red: 156/255.0, green: 179/255.0, blue: 207/255.0, alpha: 1.0)
    }
    deltaLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
    deltaLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.bottom
    deltaLabel.position = moneyLabel.position
    deltaLabel.text = String(format: "%i $", delta)
    deltaLabel.fontSize = moneyLabel.fontSize
    deltaLabel.zPosition = CGFloat(ZPosition.HUDForeground.rawValue)
    addChild(deltaLabel)
    
    let moveLabelAction = SKAction.move(by: CGVector(dx: 0, dy: 20), duration: 0.5)
    let fadeLabelAction = SKAction.fadeOut(withDuration: 0.5)
    let labelAction = SKAction.group([moveLabelAction, fadeLabelAction])
    deltaLabel.run(labelAction, completion: {deltaLabel.removeFromParent()})
    
    money += delta
    moneyLabel.text = String(format: "%i $", money)
    
    return true
  }
  
  func serveCustomerWithItemOfType(type: String, flavor: String) {
    // 1
    if customer?.type == type && customer?.flavor == flavor {
      let _ = updateMoney(by: 50)
      let playSound = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: true)
      run(playSound)
    } else {
      let playSound = SKAction.playSoundFileNamed("hit.wav", waitForCompletion: true)
      run(playSound)
    }
    if customer != nil {
      // 2
      let moveRight = SKAction.move(by: CGVector(dx: customer!.calculateAccumulatedFrame().size.width, dy: 0), duration: 1)
      customer!.run(moveRight, completion: {
        self.customer?.removeFromParent()
        self.customer = nil
      })
      // 3
      timeOfLastCustomer = CFAbsoluteTimeGetCurrent()
      determineTimeTillNextCustomer()
    }
  }
  
}
