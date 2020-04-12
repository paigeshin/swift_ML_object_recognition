//
//  ViewController.swift
//  Swift_machine_learning
//
//  Created by shin seunghyun on 2020/04/11.
//  Copyright © 2020 shin seunghyun. All rights reserved.
//

import UIKit

//Info.plist 에 값을 추가
//Privacy - Camera Usage Description
//Privacy - Photo Library Additions Usage Description

//Import CoreML and Vision
//import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        //예를들어 유저가 cropping도 할 수 있고 편집할 수 있게 해주는 API.
        imagePicker.allowsEditing = false
        
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
           
            //Machine Learning Framework code implemetation
            //ML을 위해서 CIImage로 만듬. NSObject에 있음.
            //Classification 작업
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert UIImage into CIImage")
            }
            //to take advantage of the built-in Core Image filters when processing images
            //Although a CIImage object has image data associated with it, it is not an image. You can think of a CIImage object as an image “recipe.”
            
            detect(image: ciimage)
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    /*
     Supervised Learning, Classification
     모두 Vision Framework에서 온 Object들
     
     1. VNCoreMLModel - ciImage를 받아서 model로 만들어준다.
     2. VNCoreMLRequest - 만든 모델을 토대로 request object를 만듬.
     3. VNImageRequestHandler - 실제로 실행한다.
     
     */
    func detect(image: CIImage) {
        
        //* Model
        //VNCoreMLModel - Vision Framework에서 가져온 object
        //Class화 된 Inceptionv3() 를 가져와서 model로 만든다.
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed.")
        }
        
        //* Classification
        //Model 값을 던지고 request를 만들어준다.
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            print(results) //복잡한 math가 나옴. 쭉 보다보면 classification 결과가 나온다. 예를들어 computer는 computer로 보여줌. 가장 위에 있는 값이 Highest Confidence 값이다.
            
            //results.first가 the height confidence value 이다.
            if let firstResult = results.first {
//                if firstResult.identifier.contains("hotdog"){
//                    self.navigationItem.title = "Hotdog!"
//                } else {
//                    self.navigationItem.title = "Not Hotdog"
//                }
                self.navigationItem.title = firstResult.identifier
            }
            
        }
        
        //* Perform Request
        //실행
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request]) //실제로 실행
        } catch {
            print(error)
        }
        
        
    }
    
}

