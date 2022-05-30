//
//  GameScene.swift
//  Project11
//
//  Created by CHURILOV DMITRIY on 23.05.2022.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel: SKLabelNode!
    var editLabel: SKLabelNode!
    var ballsLabel: SKLabelNode!
    var balls = [SKSpriteNode]()
    
    var ballsCount = 5 {
        didSet {
            ballsLabel.text = "Balls left: \(ballsCount)"
        }
    }
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        balls.append(SKSpriteNode(imageNamed: "ballBlue"))
        balls.append(SKSpriteNode(imageNamed: "ballCyan"))
        balls.append(SKSpriteNode(imageNamed: "ballGreen"))
        balls.append(SKSpriteNode(imageNamed: "ballGrey"))
        balls.append(SKSpriteNode(imageNamed: "ballPurple"))
        balls.append(SKSpriteNode(imageNamed: "ballYellow"))
        
        makeSlot(at: CGPoint(x: 128, y: 46), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 46), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 46), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 46), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 40))
        makeBouncer(at: CGPoint(x: 256, y: 40))
        makeBouncer(at: CGPoint(x: 512, y: 40))
        makeBouncer(at: CGPoint(x: 768, y: 40))
        makeBouncer(at: CGPoint(x: 1024, y: 40))
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 650)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 650)
        addChild(editLabel)
        
        ballsLabel = SKLabelNode(fontNamed: "Chalkduster")
        
        ballsLabel.position = CGPoint(x: 450, y: 650)
        addChild(ballsLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        
        if objects.contains(editLabel) {
            editingMode.toggle()
        } else {
            if editingMode {
                //create a box
                let size = CGSize(width: Int.random(in: 60...128), height: 16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location
                box.name = "box"
                
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                addChild(box)
                
            } else {
//                let ball = SKSpriteNode(imageNamed: "ballRed")
                if (ballsCount - 5) < 5 {
                guard let ball = balls.randomElement() else { return }
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                ball.physicsBody?.restitution = 0.4
                ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                ball.position = CGPoint(x: location.x, y: 650)
                ball.name = "ball"
                ball.removeFromParent()
                addChild(ball)
                    ballsCount -= 1
                }
                if ballsCount == 0 {
                    ballsCount = 5
                }
            }
        }
    }

    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody.init(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collision(between ball: SKNode, and box: SKNode, object: SKNode) {
        if object.name == "good" {
            destroyBall(ball: ball)
            ballsCount += 1
            score += 1
        } else if object.name == "bad" {
            destroyBall(ball: ball)
            score -= 1
        } else if object.name == "box" {
            destroyBox(box: box)
        }
    }
    
    func destroyBall(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        
        ball.removeFromParent()
    }
    
    func destroyBox(box: SKNode) {
        box.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let bodyA = contact.bodyA.node else { return }
        guard let bodyB = contact.bodyB.node else { return }
        
        if contact.bodyA.node?.name == "ball" {
            collision(between: bodyA, and: bodyB, object: bodyB)
        } else if contact.bodyB.node?.name == "ball" {
            collision(between: bodyB, and: bodyA, object: bodyA)
        }
    }

}

