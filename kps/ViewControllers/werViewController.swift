//
//  werViewController.swift
//  kps
//
//  Created by mac035 on 6/18/24.
//

import UIKit

class werViewController: UIViewController {

    @IBAction func tao(_ sender: UIButton) {
        if let text = label.text {
            print(text)
        }
    }
    @IBOutlet weak var label: UITextField!
    var wer: String = "qr"
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
