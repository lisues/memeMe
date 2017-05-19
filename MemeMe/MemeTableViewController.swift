//
//  TableViewController.swift
//  MemeMe
//
//  Created by Lisue J She on 4/24/17.
//  Copyright © 2017 udacity. All rights reserved.
//

import UIKit

class MemeTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var memes = [Meme]()
    
    @IBOutlet var tableViewData: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableViewData.delegate = self
        getMemesData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMemesData()
        self.tableViewData?.reloadData()
    }
    
    func getMemesData() {
        let memesObj = UIApplication.shared.delegate as! AppDelegate
        memes = memesObj.memes
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memesDataCell")!
        let memesData = self.memes[(indexPath as NSIndexPath).row]
        cell.imageView?.image = memesData.memedImage
        cell.textLabel?.text = memesData.topText+"..."+memesData.bottomText
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailController = self.storyboard?.instantiateViewController(withIdentifier: "MemedDetailViewController") as! MemedDetailViewController
        detailController.myMemed = self.memes[(indexPath as NSIndexPath).row]
        self.navigationController?.pushViewController(detailController, animated: true)
    }
}



