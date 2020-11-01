//
//  ViewController.swift
//  DrawingWithPencilKit
//
//  Created by paw on 01.11.2020.
//

import UIKit
import PencilKit
import PhotosUI

class ViewController: UIViewController {

    @IBAction func saveDrawingToCameraRoll(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, UIScreen.main.scale)
        canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let image = image{
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { (isSuccess, error) in
                
            }

        }
    }
    @IBAction func toggleFingerOrPencil(_ sender: Any){
        switch canvasView.drawingPolicy {
        case .anyInput:
            canvasView.drawingPolicy = .pencilOnly
        default:
            canvasView.drawingPolicy = .anyInput
        }
        pencilButton.title = canvasView.drawingPolicy == .anyInput ? "Pencil" : "Finger"
    }
    let canvasWidth: CGFloat = 768
    let canvasOverscrollHight: CGFloat = 500
    var drawing = PKDrawing()
    var toolPicker = PKToolPicker()
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var pencilButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView.delegate = self
        canvasView.drawing = drawing
        canvasView.alwaysBounceVertical = true
        canvasView.drawingPolicy = .anyInput
        
        
        if #available(iOS 14.0, *) {
            toolPicker = PKToolPicker()
        } else {
            let window = parent?.view.window
            toolPicker = PKToolPicker.shared(for: window!)!
        }
        
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            canvasView.becomeFirstResponder()
        
        // Do any additional setup after loading the view.
    }
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateContentSizeForDrawing()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let canvasScale = canvasView.bounds.width / canvasWidth
        canvasView.minimumZoomScale = canvasScale
        canvasView.maximumZoomScale = canvasScale
        canvasView.zoomScale = canvasScale
        updateContentSizeForDrawing()
        canvasView.contentOffset = CGPoint(x: 0, y: -canvasView.adjustedContentInset.top)
    }
    override var prefersHomeIndicatorAutoHidden: Bool{
        return true
    }
    func updateContentSizeForDrawing(){
        let drawing = canvasView.drawing
        let contentHeight: CGFloat
        if !drawing.bounds.isNull {
            contentHeight = max(canvasView.bounds.height, (drawing.bounds.maxY + self.canvasOverscrollHight) * canvasView.zoomScale)
        }else{
            contentHeight = canvasView.bounds.height
        }
        canvasView.contentSize = CGSize(width: canvasWidth * canvasView.zoomScale, height: contentHeight)
    }
}

extension ViewController: PKCanvasViewDelegate, PKToolPickerObserver{
    
}
