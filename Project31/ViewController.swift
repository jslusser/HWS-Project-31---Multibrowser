//
//  ViewController.swift
//  Project31
//
//  Created by James Slusser on 7/27/17.
//  Copyright © 2017 James Slusser. All rights reserved.
//  https://www.hackingwithswift.com/read/31/overview
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var addressBar: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    
    weak var activeWebView: UIWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaultTitle()
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWebView))
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteWebView))
        navigationItem.rightBarButtonItems = [delete, add]
    }
    
    func setDefaultTitle() {
        title = "Multibrowser"
    }
    
    func addWebView() {
        let webView = UIWebView()
        webView.delegate = self
        
        stackView.addArrangedSubview(webView)
        
        let url = URL(string: "https://www.hackingwithswift.com")!
        webView.loadRequest(URLRequest(url: url))
        
        webView.layer.borderColor = UIColor.blue.cgColor
        selectWebView(webView)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(webViewTapped))
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)
    }
    
    func deleteWebView() {
        // safely unwrap our webview
        if let webView = activeWebView {
            if let index = stackView.arrangedSubviews.index(of: webView) {
                // we found the current webview in the stack view! Remove it from the stack view
                stackView.removeArrangedSubview(webView)
                
                // now remove it from the view hierarchy – this is important!
                webView.removeFromSuperview()
                
                if stackView.arrangedSubviews.count == 0 {
                    // go back to our default UI
                    setDefaultTitle()
                } else {
                    // convert the Index value into an integer
                    var currentIndex = Int(index)
                    
                    // if that was the last web view in the stack, go back one
                    if currentIndex == stackView.arrangedSubviews.count {
                        currentIndex = stackView.arrangedSubviews.count - 1
                    }
                    
                    // find the web view at the new index and select it
                    if let newSelectedWebView = stackView.arrangedSubviews[currentIndex] as? UIWebView {
                        selectWebView(newSelectedWebView)
                    }
                }
            }
        }
    }
    
    func selectWebView(_ webView: UIWebView) {
        for view in stackView.arrangedSubviews {
            view.layer.borderWidth = 0
        }
        
        activeWebView = webView
        webView.layer.borderWidth = 3
        
        updateUI(for: webView)
    }
    
    func webViewTapped(_ recognizer: UITapGestureRecognizer) {
        if let selectedWebView = recognizer.view as? UIWebView {
            selectWebView(selectedWebView)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let webView = activeWebView, let address = addressBar.text {
            if let url = URL(string: address) {
                webView.loadRequest(URLRequest(url: url))
            }
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.horizontalSizeClass == .compact {
            stackView.axis = .vertical
        } else {
            stackView.axis = .horizontal
        }
    }
    
    func updateUI(for webView: UIWebView) {
        title = webView.stringByEvaluatingJavaScript(from: "document.title")
        addressBar.text = webView.request?.url?.absoluteString ?? ""
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if webView == activeWebView {
            updateUI(for: webView)
        }
    }
}

