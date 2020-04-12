# swift_machine_learning

https://www.notion.so/Swift-Machine-Learning-87289761998846179e235ff1318200e7

# Link

https://developer.apple.com/machine-learning/

=> document 읽자

[https://developer.apple.com/machine-learning/build-run-models/](https://developer.apple.com/machine-learning/build-run-models/)

# Resource

[https://docs-assets.developer.apple.com/coreml/models/Inceptionv3.mlmodel](https://docs-assets.developer.apple.com/coreml/models/Inceptionv3.mlmodel)

#  Theory

##  Machine Learning

- The field of study that gives computers the ability to learn without being explicitly programmed. - Arther Samuel
- Testing Data → Model → Output
- Classification ⇒ Create a good generic model,
- supervised learning vs unsupervised learning

##   Supervised Learning

- with labeled data

### Discrete vs Continuous Data

- Discrete → Data that fits into specific camp
- Continuous → Regression Model
- Number of Lines

##  Unsupervised Learning

- Observe whole bunch of data
- Make a structure to make computer understand data  e.g) divide roughly data, this might be some group of data
- Computer absorbs a whole bunch of data and tries to make a structure

###  Clustering

- Just by looking at grouped data, you or computer can understand a specific category of data group. "Cluster appears"

##  Reinforcement Learning

- Reinforcement learning is an area of machine learning concerned with how software agents ought to take actions in an environment in order to maximize the notion of cumulative reward.

#  So what CoreML provides?

1. Load a Pre-Trained Model
2. Make Predictions

###  Classification or Regression

- No Training
- Static Model
- Not Encrypted


# Actual Practice - Object Recognition App

### Process

1. .mlmodel extension을 가진 파일을 가져온다.
2. xCode에 가져다 놓으면 자동으로 class가 생성된다.
3. Import `Vision`
4. CIImage ⇒ image file을 filter하여 새로운 데이터를 만듬. NSObject
5. `VNCoreMLModel` ⇒ 이미 만들어진 .mlmodel을 가져온다.
6. `VNCoreMLRequest` ⇒ VNCoreMLModel을 토대로 request를 만든다. 이 부분에 callback 함수가 달려있는데 결과값을 가져옴.
7. `VNImageRequestHandler` ⇒ VNImageRequestHandler에다가 비교하고 싶은 데이터를 넣는다. 


### Code 

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
             
             1. VNCoreMLModel - mlModel을 만든다
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
