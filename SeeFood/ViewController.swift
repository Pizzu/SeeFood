//
//  ViewController.swift
//  SeeFood
//
//  Created by Luca Lo Forte on 14/03/18.
//  Copyright © 2018 Luca Lo Forte. All rights reserved.
//

import UIKit
import CoreML
import Vision //permette di processare immagini più facilmente

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var answerImage: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }
    
    //MARK: - ImagePicker delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIImage")
            }
            detect(image: ciImage)
            
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    func detect(image : CIImage){
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {fatalError("Loading CoreML model failed.")}
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            guard let results = request.results as? [VNClassificationObservation] else { fatalError("Model failed to process image.")}
            
            if let firstResult = results.first {
                
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "HotDog!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.green
                    self.answerImage.image = UIImage(named: "hotdog")
                } else {
                    self.navigationItem.title = "Not HotDog!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.red
                    self.answerImage.image = UIImage(named: "not-hotdog")
                }
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
}

