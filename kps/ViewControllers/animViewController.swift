

import UIKit
import Lottie
import Combine

class animViewController: UIViewController {
    
    let animationView: LottieAnimationView = {
        let animView = LottieAnimationView(name: "bookAnimation")
        animView.frame = CGRect(x:0, y:0, width:400, height:400)
        animView.contentMode = .scaleAspectFill

        return animView
    }() // 시작 애니메이션 화면
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        view.addSubview(animationView)
        animationView.center = view.center

        //애니메이션 실행
        animationView.play{
            (finish) in print("애니메이션 종료.")
            
            self.performSegue(withIdentifier: "navigateToMain", sender: self)
        }

    } //viewDidLoad()
}
extension animViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "navigateToMain" {
            segue.destination.modalPresentationStyle = .fullScreen
        }
        // 다른 segue에 대해서도 처리할 수 있으면 여기에 추가합니다.
    }
}// segue 화면 처리
