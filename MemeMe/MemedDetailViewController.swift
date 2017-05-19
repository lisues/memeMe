//
//  MemedDetailViewController.swift
//  MemeMe
//
//  Created by Lisue She on 4/30/17.
//  Copyright © 2017 udacity. All rights reserved.
//

import UIKit

class MemedDetailViewController: UIViewController {

    var myMemed: Meme!
    
    @IBOutlet weak var memedImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.memedImage!.image = myMemed.memedImage
    }
   
}
