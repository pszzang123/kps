//
//  KakaoAuthVM.swift
//  kps
//
//  Created by mac035 on 6/11/24.
//

import Foundation
import Combine
import KakaoSDKAuth
import KakaoSDKUser

class KakaoAuthVM: ObservableObject{
    var subscriptions = Set<AnyCancellable>()
    
    @Published var isLoggedIn : Bool = false
    @Published var currentUser : String = ""
    
    lazy var loginStatusInfo : AnyPublisher<String?, Never> =
    $isLoggedIn.compactMap{ $0 ? "로그인 상태" : "로그아웃 상태" }.eraseToAnyPublisher()
    
    init() {
        print("KakaoAuthVM - init() called")
    }
    
    
    //카카오톡 앱으로 로그인 인증
    func kakaoLoginWithApp() async -> Bool {
        await withCheckedContinuation{continuation in
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                    continuation.resume(returning: false)
                }
                else {
                    print("loginWithKakaoTalk() success.")
                    
                    //do something
                    _ = oauthToken
                    continuation.resume(returning: true)
                }
            }
        }
    }
    
    //카카오 계정으로 로그인
    func kakaoLoginWithAccount() async -> Bool{
        await withCheckedContinuation{ continuation in
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                    if let error = error {
                        print(error)
                        continuation.resume(returning: false)
                    }
                    else {
                        print("loginWithKakaoAccount() success.")

                        //do something
                        _ = oauthToken
                        continuation.resume(returning: true)
                    }
                }
        }
    }
    
    @MainActor
    func kakaoLogin(){
        print("KakaoAuthVM - handleKakaoLogin() called")
        
        Task{
            // 카카오톡 실행 가능 여부 확인
            if (UserApi.isKakaoTalkLoginAvailable()) {
                // 카카오톡 앱으롤 로그인 인증
                isLoggedIn = await kakaoLoginWithApp()
            }else{//kakao 설치 x
                // 카카오 계정으로 로그인
                isLoggedIn = await kakaoLoginWithAccount()
            }
            currentUser = await getUser()
        }
        
        
    }// login
    
    @MainActor
    func kakaoLogout(){
        Task{
            if await handleKakaoLogout(){
                self.isLoggedIn = false
            }
            currentUser = ""
        }
    }
    
    func handleKakaoLogout() async -> Bool{
        await withCheckedContinuation{continuation in
            UserApi.shared.logout {(error) in
                if let error = error {
                    print(error)
                    continuation.resume(returning: false)
                }
                else {
                    print("logout() success.")
                    continuation.resume(returning: true)
                }
            }
            
        }
    }
    
    // async 함수 정의
    func getUser() async -> String {
        return await withCheckedContinuation { continuation in
            UserApi.shared.me() { user, error in
                if let error = error {
                    print(error)
                    continuation.resume(returning: "")
                } else if let user = user {
                    print("me() success.")
                    let userIdToString = String(user.id!) // Int64를 String으로 변환
                    continuation.resume(returning: userIdToString)
                } else {
                    continuation.resume(returning: "")
                }
            }
        }
    }

}
