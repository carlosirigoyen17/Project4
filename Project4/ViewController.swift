//
//  ViewController.swift
//  Project4
//
//  Created by Carlos Irigoyen on 4/29/19.
//  Copyright © 2019 Carlos Irigoyen. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
  
  var webView: WKWebView!
  var progressView: UIProgressView!
  var websites = ["hackingwithswift.com","apple.com", "applio/jhg"]
  
  override func loadView() {
    webView = WKWebView()
    webView.navigationDelegate = self
    view = webView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
    
    let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
    
    // Add Progress Bar
    progressView = UIProgressView(progressViewStyle: .bar)
    progressView.sizeToFit()
    let progressButton = UIBarButtonItem(customView: progressView)
    
    
    toolbarItems = [progressButton, spacer,refresh]
    navigationController?.isToolbarHidden = false
    
    
    // Use addObserve force to uses observeValue Func
    webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    
    
    let url = URL(string: "https://" + websites[0])!
    webView.load(URLRequest(url: url))
    webView.allowsBackForwardNavigationGestures = true
  }

  @objc func openTapped() {
    let alertController = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)
    for website in websites {
      alertController.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
    }
    
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    alertController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
    present(alertController, animated: true, completion: nil)
  }
  
  func openPage(action: UIAlertAction) {
    // Basic way
    //    let url = URL(string: "https://"+action.title!)!
    
    // Correct way
    guard let actionTitle = action.title else { return }
    guard let url = URL(string: "https://" + actionTitle ) else { return }
    webView.load(URLRequest(url: url))
    
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    title = webView.title
  }
  
  func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    title = "Cargando..."
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "estimatedProgress" {
      progressView.progress = Float(webView.estimatedProgress)
    }
  }
  
  // Allow or Cancel request by code verification
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    let url = navigationAction.request.url
    print(url ?? "No hay nada")
    if let host = url?.host {
      for website in websites {
        if host.contains(website) {
          decisionHandler(.allow)
          return
        }
      }
    }
    
    
    let alertController = UIAlertController(title: "Error", message: "Can't load Page", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Continue", style: .default, handler: nil))
    //  alertController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
    present(alertController, animated: true, completion: nil)
    
    
    print("Fue rechazada")
    decisionHandler(.cancel)
    
    
  }

}

