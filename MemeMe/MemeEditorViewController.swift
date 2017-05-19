//
//  ViewController.swift
//  MemeMe
//
//  Created by Lisue J She on 4/4/17.
//  Copyright © 2017 udacity. All rights reserved.
//

import UIKit


class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topTextField: UITextField!
    
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var topRight: UIToolbar!
    @IBOutlet weak var topLeft: UIToolbar!
    @IBOutlet weak var bottomLeft: UIToolbar!
    @IBOutlet weak var bottomRight: UIToolbar!
    var textAdjustHeight:CGFloat = 0
    
    let memeTextAttributes:[String:Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 35)!,
        NSForegroundColorAttributeName: UIColor.white,
        NSStrokeWidthAttributeName: -3.0
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTextFieldLoad( textField: topTextField )
        initTextFieldLoad( textField: bottomTextField )
    }
    
    func initTextFieldLoad( textField: UITextField ) {
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = NSTextAlignment.center
        textField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear( animated )
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        actionButton.isEnabled = false
        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear( animated )
        unsubscribeFromKeyboardNotifications()
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
  
    
    @IBAction func share(_ sender: Any) {
         let memedImage = generateMemedImage()
         let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
         present(controller, animated: true, completion: nil)
    
         controller.completionWithItemsHandler = {
            (activity, success, items, error) in
            if success {
                self.save( memedImage: memedImage )
            } else {
                print("Activity: \(activity) Success: \(success) Items: \(items) Error: \(error)")
            }
            self.dismiss(animated: true, completion: nil)
         }
    }
    
    
    @IBAction func pickAnImageByCamera(_ sender: Any) {
        pickAnImage( sourceType: .camera )
    }
    
    @IBAction func pickAnImageByAlbum(_ sender: Any) {
        pickAnImage( sourceType: .photoLibrary )
    }
    
    func pickAnImage( sourceType: UIImagePickerControllerSourceType ) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = sourceType
        present(pickerController, animated: true, completion: nil)
    }

   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.contentMode = .scaleAspectFit
            imagePickerView.image = image
            adjustTextFieldPosition()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func adjustTextFieldPosition() {
        if ( topTextField.frame.origin.y != 0 ) {
            topTextField.frame = topTextField.frame.offsetBy(dx: 0, dy: -textAdjustHeight)
            bottomTextField.frame = bottomTextField.frame.offsetBy(dx: 0, dy: textAdjustHeight)
        }
        
        if imagePickerView.image != nil {
            let imageHeight = imagePickerView.frame.height
            textAdjustHeight = (imageHeight/2) - (topTextField.frame.height) - 60
            if textAdjustHeight > 0 {
                topTextField.frame = topTextField.frame.offsetBy(dx: 0, dy: textAdjustHeight)
                bottomTextField.frame = bottomTextField.frame.offsetBy(dx: 0, dy: -textAdjustHeight)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if topTextField.isFirstResponder && topTextField.text == "" {
            topTextField.text = "TOP"
        } else if bottomTextField.isFirstResponder && bottomTextField.text == "" {
            bottomTextField.text = "BOTTOM"
        }
        textField.resignFirstResponder()
        view.frame.origin.y = 0
        enableActionButton()
        return true
    }
    
    func enableActionButton() {
        if imagePickerView.image != nil {
            if ( topTextField.text != "" && bottomTextField.text != "" &&
                topTextField.text != "TOP" && bottomTextField.text != "BOTTOM" ) {
                actionButton.isEnabled = true
            }
        }
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    func keyboardWillShow(_ notification:Notification) {
        let keyH = getKeyboardHeight(notification)
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = -keyH
        } else if topTextField.isFirstResponder {
            let viewHigh = view.frame.height / 2
            if  keyH > viewHigh {
                topTextField.frame.origin.y = -(keyH - viewHigh)
            }
            
        }
    }

    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func displayToolbars( hidden: Bool ) {
       topRight.isHidden = hidden
       topLeft.isHidden = hidden
       bottomLeft.isHidden = hidden
       bottomRight.isHidden = hidden
    }
    
    func generateMemedImage() -> UIImage {
        displayToolbars( hidden: true )
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        displayToolbars( hidden: false )
        return memedImage
    }
    
    func save( memedImage: UIImage ) {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
        
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
}

