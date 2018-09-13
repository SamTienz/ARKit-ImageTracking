//
//  ViewController.swift
//  ARMessage
//
//  Created by Tien on 2018/8/23.
//  Copyright © 2018 Tien. All rights reserved.
//

import UIKit
import ARKit
class ViewController: UIViewController,ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var statusLabel: UILabel!
    lazy var showObjectAction: SCNAction = {
        return .sequence([
            .fadeIn(duration: 0.3),
            .wait(duration: 0.3)
            ])
    }()
    lazy var wolfNode: SCNNode = {
        guard let scene = SCNScene(named: "Wolf.dae") else { return SCNNode() }
        let nodes = SCNNode()
        let childNodes = scene.rootNode.childNodes
        for node in childNodes{
            nodes.addChildNode(node)
        }
        nodes.position = SCNVector3(0, 0, 0)
        nodes.scale = SCNVector3(0.3, 0.3, 0.3)
        nodes.eulerAngles.x = -.pi
        nodes.eulerAngles.z = -.pi/2
        return nodes
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        //自動光源
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        resetTracking()
    }
    
    
    func resetTracking() {
        //設定辨識圖集資料夾名稱
        guard let refImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
        
        //設定AR Seesion 配置方式
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = refImages
        
        //設定ARSCNView Run Option
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        sceneView.session.run(configuration, options: options)
        
        
        statusLabel.text = "Move camera to your piture"
    }
    @IBAction func resetBtnAction(_ sender: Any) {
        resetTracking()
    }
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        let imageName = referenceImage.name ?? "Error"
        
        let objectNode = getObjectNode(detectedImageName: imageName)
        objectNode.opacity = 0
        objectNode.position.y = 0.2
        objectNode.runAction(self.showObjectAction)
        
        node.addChildNode(objectNode)
        
        DispatchQueue.main.async{
            self.statusLabel.text = "Image detected: \"\(imageName)\""
        }
    }
    func getObjectNode(detectedImageName:String) -> SCNNode{
        var node = SCNNode()
        switch detectedImageName {
        case "Apple":
            node = wolfNode
        default:
            node = SCNNode()
        }
        return node
    }
}

