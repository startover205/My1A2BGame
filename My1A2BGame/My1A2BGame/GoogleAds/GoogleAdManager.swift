//
//  GoogleAdManager.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2023/11/6.
//  Copyright © 2023 Ming-Ta Yang. All rights reserved.
//

import GoogleMobileAds
import UserMessagingPlatform

public final class GoogleAdManager {
    static let shared = GoogleAdManager()
    
    private init() {}
    
    private(set) var hasInitializedGoogleAdSDK = false
    private var hasSetAdForBanner = false
    private(set) var bannerAd: GADBannerView?
    
    /// This method should be called after the first time `appBecomesActive` to ensure App Tracking Transparency request can be displayed normally..
    public func initializeGoogleAdSDKIfNeeded(completion: @escaping () -> Void) {
        guard !hasInitializedGoogleAdSDK else {
            DispatchQueue.main.async {
                completion()
            }
            return
        }
        
        func startGoogleMobileAdsSDK() {
            DispatchQueue.main.async { [self] in
                guard !hasInitializedGoogleAdSDK else {
                    print("\(Date())-\(#filePath)-\(#line)--\(#function)-[Dev🍎]-GADMobileAds already initialized-")
                    return
                }
                
                print("\(Date())-\(#filePath)-\(#line)--\(#function)-[Dev🍎]-GADMobileAds initialize!!-")
                GADMobileAds.sharedInstance().start()
                hasInitializedGoogleAdSDK = true
                setAdForBannerIfReadyAndNeeded()
                completion()
            }
        }
        
        let parameters = UMPRequestParameters()
        parameters.tagForUnderAgeOfConsent = false

        let debugSettings = UMPDebugSettings()
        debugSettings.geography = .EEA
        debugSettings.testDeviceIdentifiers = ["75D7D6A9-C9FC-49C7-8157-F5ABDBD9055D"]
        parameters.debugSettings = debugSettings
        
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) { [weak self] error in
            guard let self else { return }
            
            if let error {
                print("\(Date())-\(#filePath)-\(#line)--\(#function)-[Dev⚠️]-error while requesting consent info update: \(error)-")
                return
            }
            
            guard let topVC = self.topViewController() else {
                print("\(Date())-\(#filePath)-\(#line)--\(#function)-[Dev⚠️]-topVC not ready to present UMPConsentForm-")
                return
            }
            
            // handle UDPR or App Tracking Transparency according to the users region
            UMPConsentForm.loadAndPresentIfRequired(from: topVC) { error in
                if let error {
                    print("\(Date())-\(#filePath)-\(#line)--\(#function)-[Dev⚠️]-error while loading `UMPConsentForm`: \(error)-")
                    // don't return as it will always throw error when using App Tracking Transparency
                }
                
                startGoogleMobileAdsSDK()
            }
        }
        
        // load ad immediatly if possible to reduce latency
        if UMPConsentInformation.sharedInstance.canRequestAds {
            startGoogleMobileAdsSDK()
            return
        }
    }
    
    public func configureBannerAd(on tabController: UITabBarController) {
        let tabBar = tabController.tabBar
        let bannerWidth = tabBar.frame.inset(by: tabBar.safeAreaInsets).size.width
        
        let bannerAd = GADBannerView()
        bannerAd.adSize = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(bannerWidth)
        bannerAd.rootViewController = tabController
        bannerAd.adUnitID = GoogleAPIKeys.bottomAdID
        
        tabBar.addSubview(bannerAd)
        bannerAd.translatesAutoresizingMaskIntoConstraints = false
        tabBar.topAnchor.constraint(equalTo: bannerAd.bottomAnchor).isActive = true
        tabBar.leftAnchor.constraint(equalTo: bannerAd.leftAnchor).isActive = true
        tabBar.rightAnchor.constraint(equalTo: bannerAd.rightAnchor).isActive = true
        
        let newInset = UIEdgeInsets(top: 0, left: 0, bottom: bannerAd.bounds.height, right: 0)
        for child in tabController.children {
            child.additionalSafeAreaInsets = newInset
        }
        self.bannerAd = bannerAd
        
        self.setAdForBannerIfReadyAndNeeded()
    }
    
    public func hideBannerAd(on tabController: UITabBarController) {
        bannerAd?.alpha = 0
        tabController.children.forEach {
            $0.additionalSafeAreaInsets = .zero
        }
    }
    
    private func setAdForBannerIfReadyAndNeeded() {
        guard !hasSetAdForBanner, hasInitializedGoogleAdSDK else { return }
        hasSetAdForBanner = true
        
        bannerAd?.load(GADRequest())
    }
    
    private func topViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.connectedScenes
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
        
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            return topController
        }
        
        return nil
    }
}
