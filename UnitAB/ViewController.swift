//
//  ViewController.swift
//  UnitAB
//
//  Created by Jesus Martinez on 2/4/19.
//  Copyright © 2019 Jesus Martinez. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var puntoMarcadores = [SCNNode]()
    var puntoResultados = [SCNNode]()
    var resultadoNode   = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTest = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let hitResult = hitTest.first {
                    agregarPunto(hitResult: hitResult)
            }
        }
    }
    func agregarPunto(hitResult: ARHitTestResult){
        let punto = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
        punto.materials = [material]
        let puntoNode = SCNNode(geometry: punto)
        puntoNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(puntoNode)
        puntoMarcadores.append(puntoNode)
        if (puntoMarcadores.count >= 2){
            calcular()
        }
    }
    func calcular(){
        let a      = puntoMarcadores.count - 2
        let b      = puntoMarcadores.count - 1
        let puntoA = puntoMarcadores[a]
        let puntoB = puntoMarcadores[b]
        
        let x = puntoB.position.x - puntoA.position.x
        let y = puntoB.position.y - puntoA.position.y
        let z = puntoB.position.z - puntoA.position.z
        
        let distancia = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2))
        
        let resultado = abs(distancia)
        
        if resultado >= 1 {
            let metros = String(format: "%.2f", resultado)
            agregarResultado(resultado: "\(metros) mts.", positionTexto: puntoB.position)
        } else {
            let cm = String(resultado)
            let resCm = Array(cm)
            agregarResultado(resultado: "\(resCm[2])\(resCm[3]) cm.", positionTexto: puntoB.position)
        }
        print(abs(distancia))
    }
    func agregarResultado(resultado: String, positionTexto: SCNVector3){
        //resultadoNode.removeFromParentNode()
        let texto = SCNText(string: resultado, extrusionDepth: 1.0)
        texto.firstMaterial?.diffuse.contents = UIColor.red
        resultadoNode = SCNNode(geometry: texto)
        resultadoNode.position = SCNVector3(positionTexto.x, positionTexto.y + 0.01, positionTexto.z)
        resultadoNode.scale = SCNVector3Make(0.007, 0.007, 0.007)
        sceneView.scene.rootNode.addChildNode(resultadoNode)
        puntoResultados.append(resultadoNode)
    }
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    @IBAction func resetViewArk(_ sender: Any) {
        for puntoNodo in puntoMarcadores {
            puntoNodo.removeFromParentNode()
        }
        for puntoNodo in puntoResultados {
            puntoNodo.removeFromParentNode()
        }
        resultadoNode.removeFromParentNode()
        puntoMarcadores = [SCNNode]()
    }
}
