import SpriteKit

protocol MalletDelegate {
    func force(_ force: CGVector, fromMallet mallet: Mallet)
}


class Mallet: SKShapeNode {
    
    //keep track of previous touch time (will use to calculate vector)
    var lastTouchTimeStamp: Double?
    
    //delegate will refer to class which will act on mallet force
    var delegate:MalletDelegate?
    
    //this will determine the allowable area for the mallet
    let activeArea:CGRect
    
    //define mallet size
    let radius:CGFloat = 40.0
    
    //when we instantiate the class we will set the active area
    init(activeArea: CGRect) {
        //set the active area variable this class with the variable passed in
        self.activeArea = activeArea
        
        //ensure we pass the init call to the base class
        super.init()
        
        //allow the mallet to handle touch events
        isUserInteractionEnabled = true
        
        //create a mutable path (later configured as a circle)
        let circularPath = CGMutablePath()
        
        //define pi as CGFloat (type π using alt-p)
        let π = CGFloat.pi
        
               
        //create the circle shape
        circularPath.addArc(center: CGPoint(x: 0, y:0), radius: radius, startAngle: 0, endAngle: 2*π, clockwise: true)
       // CGPathAddArc(circularPath, nil, 0, 0, radius, 0, π*2, true)
        
        //assign the path to this SKShapeNode's path property
        path = circularPath
        
        lineWidth = 0;
        
        fillColor = .red
        
        //set physics properties (note physicsBody is an optional)
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody!.mass = 500;
        physicsBody!.affectedByGravity = false;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        var releventTouch:UITouch!
        
        //convert set to known type
        let touchSet = touches 
        
        //get array of touches so we can loop through them
        let orderedTouches = Array(touchSet)
        
        for touch in orderedTouches{
            //if we've not yet found a relevent touch
            if releventTouch == nil{
                //look for a touch that is in the activeArea (Avoid touches by opponent)
                if activeArea.contains(touch.location(in: parent!)){
                    releventTouch = touch
                }
            }
        }
        
        if (releventTouch != nil){
            
            //get touch position and relocate mallet
            let location = releventTouch!.location(in: parent!)
            position = location
            
            //find old location and use pythagoras to determine length between both points
            let oldLocation = releventTouch!.previousLocation(in: parent!)
            let xOffset = location.x - oldLocation.x
            let yOffset = location.y - oldLocation.y
            let vectorLength = sqrt(xOffset * xOffset + yOffset * yOffset)
            
            //get eleapsed and use to calculate speed
            if  lastTouchTimeStamp != nil{
                let seconds = releventTouch.timestamp - lastTouchTimeStamp!
                let velocity = 0.01 * Double(vectorLength) / seconds
                
                //to calculate the vector, the velcity needs to be converted to a CGFloat
                let velocityCGFloat = CGFloat(velocity)
                
                //calculate the impulse
                let directionVector = CGVector(dx: velocityCGFloat * xOffset / vectorLength, dy: velocityCGFloat * yOffset / vectorLength)
                
                //pass the vector to the scene (so it can apply an impulse to the puck)
                delegate?.force(directionVector, fromMallet: self)
            }
            //update latest touch time for next calculation
            lastTouchTimeStamp = releventTouch.timestamp
            
        }
    }
    
    
    
}
