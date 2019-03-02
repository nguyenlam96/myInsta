//
//  CameraController.swift
//  MyInsta
//
//  Created by Nguyen Lam on 2/28/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class CameraController: UIViewController, AVCapturePhotoCaptureDelegate, UIViewControllerTransitioningDelegate {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: -
    let output = AVCapturePhotoOutput()
    
    // MARK: -
    let dismissButton: UIButton = {
       let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "right_arrow_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismissButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleDismissButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    let capturePhotoButton: UIButton = {
       let button = UIButton(type: .system)
           button.setImage(#imageLiteral(resourceName: "capture_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCapturePhotoButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleCapturePhotoButtonPressed() {
        
        let settingsFormat = [ AVVideoCodecKey: AVVideoCodecType.jpeg ]
        let settings = AVCapturePhotoSettings(format: settingsFormat)
        guard let previewPixelFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else {
            LogUtils.LogDebug(type: .error, message: "previewFormatType is nil")
            return
        }
        let previewPhotoFormat = [ kCVPixelBufferPixelFormatTypeKey as String: previewPixelFormatType ]
//                                   kCVPixelBufferWidthKey as String: 160,
//                                   kCVPixelBufferHeightKey as String: 160]
        settings.previewPhotoFormat = previewPhotoFormat
        self.output.capturePhoto(with: settings, delegate: self)
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard error == nil else {
            LogUtils.LogDebug(type: .error, message: error!.localizedDescription)
            return
        }
        
        if let photoData = photo.fileDataRepresentation() {
            
            if let photo = UIImage(data: photoData) {
                
                let containerView = PreviewPhotoContainerView()
                    containerView.previewPhotoView.image = photo
                self.view.addSubview(containerView)
                containerView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
                
            }
            
        } else {
            LogUtils.LogDebug(type: .warning, message: "Fail to convert pixel buffer")
        }
        LogUtils.LogDebug(type: .info, message: "Finish get the photo")
        
        
    }
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupCaptureSession()
        self.setupButtons()
        transitioningDelegate = self
    }
    
    deinit {
        print("=== CameraController is deinit")
    }
    
    let customAnimationPresentor = CustomAnimationPresentor()
    let customAnimationDismisser = CustomAnimationDismisser()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return customAnimationPresentor
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return customAnimationDismisser
    }
    
    // MARK: -
    
    private func setupButtons() {
        // capture photo button
        self.view.addSubview(capturePhotoButton)
        self.capturePhotoButton.anchor(top: nil, left: nil, bottom: self.view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 24, paddingRight: 0, width: 80, height: 80)
        capturePhotoButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        // back button:
        self.view.addSubview(dismissButton)
        self.dismissButton.anchor(top: self.view.topAnchor, left: nil, bottom: nil, right: self.view.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 50)
        
    }
    
    private func setupCaptureSession() {
        
        let captureSession = AVCaptureSession()
        // 1. setup inputs:
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            LogUtils.LogDebug(type: .error, message: error.localizedDescription)
            return
        }
        // 2. setup output:
        if captureSession.canAddOutput(self.output) {
            captureSession.addOutput(self.output)
        }
        // 3. setup output preview:
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = self.view.frame
        self.view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        
    }
}
