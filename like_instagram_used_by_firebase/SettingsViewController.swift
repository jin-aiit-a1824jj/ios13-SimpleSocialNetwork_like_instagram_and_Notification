//
//  SettingsViewController.swift
//  like_instagram_used_by_firebase
//
//  Created by JONGWOO JIN on 2020/04/16.
//  Copyright © 2020 JONGWOO JIN. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func logoutClicked(_ sender: Any) {
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    

}
