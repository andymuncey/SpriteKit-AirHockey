import SpriteKit

class GameScene: SKScene, MalletDelegate {
    
    var puck : SKShapeNode?
    var southMallet : Mallet?
    var northMallet : Mallet?
    
    func createMallets(){
        let southMalletArea = CGRect(x: 0, y: 0, width: size.width, height: size.height/2)
        let southMalletStartPoint = CGPoint(x: frame.midX, y: size.height/4)
        
        let northMalletArea = CGRect(x: 0, y: size.height/2, width: size.width, height: size.height)
        let northMalletStartPoint = CGPoint(x: frame.midX, y: size.height * 0.75)
        
        southMallet = malletAt(position: southMalletStartPoint, withBoundary: southMalletArea)
        northMallet = malletAt(position: northMalletStartPoint, withBoundary: northMalletArea)
    }
    
    func malletAt(position: CGPoint, withBoundary boundary:CGRect) -> Mallet{
        
        let mallet = Mallet(activeArea: boundary)
        mallet.position = position
        mallet.delegate = self
        addChild(mallet)
        return mallet;
    }
    
    func createEdges(){
        
        let bumperDepth = CGFloat(20.0)
        
        let leftEdge = SKSpriteNode(color: UIColor.blue, size: CGSize(width: bumperDepth, height: size.height))
        leftEdge.position = CGPoint(x: bumperDepth/2, y: frame.height/2)
        
        //setup physics for this edge
        leftEdge.physicsBody = SKPhysicsBody(rectangleOf: leftEdge.size)
        leftEdge.physicsBody!.isDynamic = false
        addChild(leftEdge)
        
        //copy the left edge and position it as the right edge
        let rightEdge = leftEdge.copy() as! SKSpriteNode
        rightEdge.position = CGPoint(x: size.width - bumperDepth/2, y: frame.height/2)
        addChild(rightEdge)
        
        //calculate some values for the end bumpers (four needed to allow for goals)
        let endBumperWidth = (size.width / 2) - 150
        let endBumperSize = CGSize(width: endBumperWidth, height: bumperDepth)
        let endBumperPhysics = SKPhysicsBody(rectangleOf: endBumperSize)
        endBumperPhysics.isDynamic = false;
        
        //create a bottom edge
        let bottomLeftEdge = SKSpriteNode(color: UIColor.blue, size: endBumperSize)
        bottomLeftEdge.position = CGPoint(x: endBumperWidth/2, y: bumperDepth/2)
        bottomLeftEdge.physicsBody = endBumperPhysics
        addChild(bottomLeftEdge)
        
        //copy edge to other three locations
        let bottomRightEdge = bottomLeftEdge.copy() as! SKSpriteNode
        bottomRightEdge.position = CGPoint(x: size.width - endBumperWidth/2, y: bumperDepth/2)
        addChild(bottomRightEdge)
        
        let topLeftEdge = bottomLeftEdge.copy() as! SKSpriteNode
        topLeftEdge.position = CGPoint(x: endBumperWidth/2, y: size.height - bumperDepth/2)
        addChild(topLeftEdge)
        
        let topRightEdge = bottomRightEdge.copy() as! SKSpriteNode
        topRightEdge.position = CGPoint(x: size.width - endBumperWidth/2, y: size.height - bumperDepth/2 )
        addChild(topRightEdge)
        
    }
    
    override func didMove(to view: SKView) {
  
        
        drawCenterLine()
        createMallets()
        resetPuck()
        createEdges()
    }
    
    func force(_ force: CGVector, fromMallet mallet: Mallet) {
        
        let collisionDistanceSquared = mallet.radius * mallet.radius + 30 * 30
        
        let actualDistanceX = mallet.position.x - puck!.position.x
        let actualDistanceY = mallet.position.y - puck!.position.y
        
        let actualDistanceSquared = actualDistanceX * actualDistanceX + actualDistanceY * actualDistanceY
        
        if  actualDistanceSquared <= collisionDistanceSquared{
            puck!.physicsBody!.applyImpulse(force)
        }
//        //using boxes method - innacurate
//        if CGRectIntersectsRect(mallet.frame, puck!.frame){
//            puck!.physicsBody!.applyImpulse(force)
//        }
    }
    
    func drawCenterLine(){
        let centerLine = SKSpriteNode(color: UIColor.white, size: CGSize(width: size.width, height: 10))
        centerLine.position = CGPoint(x: size.width/2, y: size.height/2)
        centerLine.colorBlendFactor = 0.5;
        addChild(centerLine)
    }
    
    func resetPuck(){
        
        if  puck == nil{
            
            //create puck object
            puck = SKShapeNode()
            
            //draw puck
            let radius : CGFloat = 30.0
            let puckPath = CGMutablePath()
            let π = CGFloat.pi
           // puckPath.add
            puckPath.addArc(center: CGPoint(x: 0, y:0), radius: radius, startAngle: 0, endAngle: π*2, clockwise: true)
            //CGPathAddArc(puckPath, nil, 0, 0, radius, 0, 2 * π, true)
            puck!.path = puckPath
            puck!.lineWidth = 0
            puck!.fillColor = UIColor.blue
            
            //set puck physics properties
            puck!.physicsBody = SKPhysicsBody(circleOfRadius: radius)
            
            //how heavy it is
            puck!.physicsBody!.mass = 0.02
            puck!.physicsBody!.affectedByGravity = false
            
            //how much momentum is maintained after it hits somthing
            puck!.physicsBody!.restitution = 0.85
            
            //how much friction affects it
            puck!.physicsBody!.linearDamping = 0.4
        }
        
        //set puck position at centre of screen
        puck!.position = CGPoint(x: size.width/2, y: size.height/2)
        puck!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        
        //if not alreay in scene, add to scene
        if puck!.parent == nil{
            addChild(puck!)
        }
    }
    
    func isOffScreen(node: SKShapeNode) -> Bool{
        return !frame.contains(node.position)
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        if  isOffScreen(node: puck!){
            resetPuck()
        }
        
    }
}
