//
//  ViewController.swift
//  AR-Portal
//
//  Created by Gautam on 5-05-2018
//

import UIKit
import SceneKit
import ARKit
class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var planeDetected: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    let videoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
    struct AspectRatio {
        static let width: CGFloat = 500
        static let height: CGFloat = 400
    }
//    let AspectDiv: CGFloat = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        // Detect the Horizontal Planes
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        // Execute the delegate function
        self.sceneView.delegate = self
        // Add the Tap Gesture, if a tap is recognized, execute the Handle Tap function
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        // Add tap gesture recognizer to the Scene View
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Function to handle Tap Gesture in Scene View
    @objc func handleTap(sender: UITapGestureRecognizer) {
        // Check if tap was performed, then move forward else, return
        guard let sceneView = sender.view as? ARSCNView else {return}
        // Get the location of the touch in the Scene View
        let touchLocation = sender.location(in: sceneView)
        // use hit test to get the location of tap
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        if !hitTestResult.isEmpty {
            // if tap is recognized, add the portal in front of camera
            self.addPortal(hitTestResult: hitTestResult.first!)
        } else {
            ////
        }
    }
    
    // Function to add the Portal in front of the Camera location
    func addPortal(hitTestResult: ARHitTestResult ) {
        // Define the Portal Scene
        let portalScene = SCNScene(named: "Portal.scnassets/Portal.scn")
        // Create the portal node, recursive as there are multiple levels in its children
        let portalNode = portalScene!.rootNode.childNode(withName: "Portal", recursively: false)!
        // Get the transform matrix from the hit test
        let transform = hitTestResult.worldTransform
        
        // get the x, y and z positions from the transform matrix
        let planeXposition = transform.columns.3.x
        let planeYposition = transform.columns.3.y
        let planeZposition = transform.columns.3.z
        
        // Place the portal in the location of the x ,y ,z coordinates obtained
        portalNode.position =  SCNVector3(planeXposition, planeYposition, planeZposition)
        // Add the portal node to the scene view
        self.sceneView.scene.rootNode.addChildNode(portalNode)
        
        let redCarpet1 = portalNode.childNode(withName: "redCarpet", recursively: false)!
        let redCarpet2 = portalNode.childNode(withName: "redCarpet2", recursively: false)!
        let redCarpet3 = portalNode.childNode(withName: "redCarpet3", recursively: false)!
        let redCarpet4 = portalNode.childNode(withName: "redCarpet4", recursively: false)!

        // Add image to the walls on inside of the portal room
        self.addPlane(nodeName: "roof", portalNode: redCarpet1, imageName: "1_t")
        self.addPlane(nodeName: "floor", portalNode: redCarpet1, imageName: "1_bo")
        // right wall
        self.addWalls(nodeName: "sideWallA", portalNode: redCarpet1, imageName: "1_r")
        // left wall
        self.addWalls(nodeName: "sideWallB", portalNode: redCarpet1, imageName: "1_l")
        // return left
        self.addWalls(nodeName: "sideDoorA", portalNode: redCarpet1, imageName: "1_lg")
        // return right
        self.addWalls(nodeName: "sideDoorB", portalNode: redCarpet1, imageName: "1_rg")
        // front
        self.addWalls(nodeName: "backWall", portalNode: redCarpet1, imageName: "1_b")
        
        // 2 Room to the right, can add game over here
        self.addPlane(nodeName: "roof", portalNode: redCarpet2, imageName: "2_t")
        self.addPlane(nodeName: "floor", portalNode: redCarpet2, imageName: "2_bo")
        self.addWalls(nodeName: "leftWall", portalNode: redCarpet2, imageName: "2_r")
        self.addWalls(nodeName: "rightWall", portalNode: redCarpet2, imageName: "2_r")
        self.addWalls(nodeName: "backWall", portalNode: redCarpet2, imageName: "2_b")
        
        // 3
        // top plance
        self.addPlane(nodeName: "roof", portalNode: redCarpet3, imageName: "1_t")
        // bottom plane
        self.addPlane(nodeName: "floor", portalNode: redCarpet3, imageName: "1_bo")
        // replace with hackinout and sponsors
        self.addWalls(nodeName: "leftWall", portalNode: redCarpet3, imageName: "inout_1")
        self.addWalls(nodeName: "rightWall", portalNode: redCarpet3, imageName: "inout_2")
        self.addVideoWall(nodeName: "backWall", rootWall: redCarpet3)
        
        // 4
//        self.addPlane(nodeName: "roof", portalNode: redCarpet4, imageName: "1_t")
//        self.addPlane(nodeName: "floor", portalNode: redCarpet4, imageName: "1_bo")
//        self.addWalls(nodeName: "sideWallA", portalNode: redCarpet4, imageName: "1_r")
//        self.addWalls(nodeName: "sideWallB", portalNode: redCarpet4, imageName: "1_l")
//        self.addWalls(nodeName: "sideDoorA", portalNode: redCarpet4, imageName: "1_lg")
//        self.addWalls(nodeName: "sideDoorB", portalNode: redCarpet4, imageName: "1_rg")
        self.addVideoWall(nodeName: "backWall", rootWall: redCarpet4, videoPath: videoURL!)
//
    }
    
    func create(stars geometry: SCNGeometry, and diffuse: SKScene?, and specular: UIImage?, and emission: UIImage?, and normal: UIImage?, and position: SCNVector3) -> SCNNode {
        let node = SCNNode()
        node.geometry = geometry
        node.geometry?.firstMaterial?.diffuse.contents = diffuse
        node.geometry?.firstMaterial?.specular.contents = specular
        node.geometry?.firstMaterial?.normal.contents = normal
        node.geometry?.firstMaterial?.emission.contents = emission
        node.position = position
        node.geometry?.firstMaterial?.isDoubleSided = true
        
        return node
    }

    
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        DispatchQueue.main.async {
            // Keep the plane detected label as hidden
            self.planeDetected.isHidden = false
        }
        
        // if horizontal plane found, display plane detected for 3 seconds and then make it hidden
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.planeDetected.isHidden = true
        }
    }
    
    // Add images to the walls of the portal
    func addWalls(nodeName: String, portalNode: SCNNode, imageName: String) {
        // Add top and bottom to the portal
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/\(imageName).jpeg")
        // By default the rendering order of walls, roof and bottom is "0".
        // More the rendering Order, more the transparency
        // Using this, the mask will be rendered first and then the walls. so, they appear transparent
        child?.renderingOrder = 200
        if let mask = child?.childNode(withName: "mask", recursively: false) {
            // Make masks completely Transparent
            mask.geometry?.firstMaterial?.transparency = 0.000001
        }
    }
    
    
    // Add images to the walls of the portal
    func addVideoWall(nodeName: String, rootWall: SCNNode, videoPath: URL) {
        
        // create a web view
        let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: 640, height: 480))
        let request = URLRequest(url: URL(string: "http://192.168.15.121:8080/jsfs.html")!)
        
        webView.loadRequest(request)
        webView.allowsInlineMediaPlayback = true;
        
        
        let videoNode = rootWall.childNode(withName: nodeName, recursively: true)

        videoNode?.geometry?.firstMaterial?.diffuse.contents = webView
        videoNode?.geometry?.firstMaterial?.isDoubleSided = true
        
        
        // By default the rendering order of walls, roof and bottom is "0".
        // More the rendering Order, more the transparency
        // Using this, the mask will be rendered first and then the walls. so, they appear transparent
        videoNode?.renderingOrder = 200
    }
    
//    // Add images to the walls of the portal
    func addVideoWall(nodeName: String, rootWall: SCNNode) {
        
        // create AVPlayer
        let player = AVPlayer(url: URL(string: "https://raw.githubusercontent.com/satwikkansal/vision_ar/master/myVivo.mp4")!)
                // place AVPlayer on SKVideoNode
                let playerNode = SKVideoNode(avPlayer: player)
                // flip video upside down
                playerNode.yScale = -1
        
        // create SKScene and set player node on it
                let spriteKitScene = SKScene(size: CGSize(width: AspectRatio.width, height: AspectRatio.height))
                spriteKitScene.scaleMode = .aspectFit
                playerNode.position = CGPoint(x: spriteKitScene.size.width/2, y: spriteKitScene.size.height/2)
                playerNode.size = spriteKitScene.size
                spriteKitScene.addChild(playerNode)

        let videoNode = rootWall.childNode(withName: nodeName, recursively: true)

        videoNode?.geometry?.firstMaterial?.diffuse.contents = spriteKitScene
        videoNode?.geometry?.firstMaterial?.isDoubleSided = true
        playerNode.play()
        // By default the rendering order of walls, roof and bottom is "0".
        // More the rendering Order, more the transparency
        // Using this, the mask will be rendered first and then the walls. so, they appear transparent
        videoNode?.renderingOrder = 200
    }
    
    
    // Add images to the roof and floor of the portal
    // Rule of Thumb: If an opaque object is rendered way after the translucent object, then the colors will mix.
    // Since mask is transparent, it'll make the walls to appear transparent as well.
    func addPlane(nodeName: String, portalNode: SCNNode, imageName: String) {
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/\(imageName).jpeg")
        // render floor and ceiling after the mask rendering
        child?.renderingOrder = 200
    }
    
}

