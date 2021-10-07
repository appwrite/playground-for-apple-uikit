//
//  ViewController.swift
//  PlaygroundForAppleUIKit
//
//  Created by Jake Barnby on 7/10/21.
//

import Appwrite
import NIO
import UIKit

class ViewController: UIViewController {

    let client = Client()
        .setEndpoint("http://demo.appwrite.io/v1")
        .setProject("60f6a0d6e2a52")

    let collectionId = "6155742223662"
    
    lazy var account = Account(client: client)
    lazy var storage = Storage(client: client)
    lazy var realtime = Realtime(client: client)
    lazy var database = Database(client: client)

    var imagePicker: ImagePicker? = nil
    
    @IBOutlet weak var responseText: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    
    @IBAction func loginWithEmail(_ sender: Any) {
        account.createSession(email: "user@appwrite.io", password: "password") { result in
            var string: String = ""
            
            switch result {
            case .failure(let error): string = error.message
            case .success(var response):
                string = response.body!.readString(length: response.body!.readableBytes) ?? ""
            }

            DispatchQueue.main.async {
                self.responseText.text = string
            }
        }
    }
    
    @IBAction func createDocument(_ sender: Any) {
        database.createDocument(
            collectionId: collectionId,
            data: [
                "name": "Name \(Int.random(in: 0...Int.max))",
                "description": "Description \(Int.random(in: 0...Int.max))"
            ]
        ) { result in
            var string: String = ""
            
            switch result {
            case .failure(let error): string = error.message
            case .success(var response):
                string = response.body!.readString(length: response.body!.readableBytes) ?? ""
            }

            DispatchQueue.main.async {
                self.responseText.text = string
            }
        }
    }
    
    @IBAction func loginWithFacebook(_ sender: Any) {
        account.createOAuth2Session(provider: "facebook") { result in
                var string: String = ""
                
                switch result {
                case .failure(let error): string = error.message
                case .success(let response): string = response.description
                }

                DispatchQueue.main.async {
                    self.responseText.text = string
                }
            }
    }
    
    @IBAction func loginWithGithub(_ sender: Any) {
        account.createOAuth2Session(provider: "github") { result in
                var string: String = ""
                
                switch result {
                case .failure(let error): string = error.message
                case .success(let response): string = response.description
                }

                DispatchQueue.main.async {
                    self.responseText.text = string
                }
            }
    }
    
    @IBAction func loginWithGoogle(_ sender: Any) {
        account.createOAuth2Session(provider: "google") { result in
                var string: String = ""
                
                switch result {
                case .failure(let error): string = error.message
                case .success(let response): string = response.description
                }

                DispatchQueue.main.async {
                    self.responseText.text = string
                }
            }
    }
    
    @IBAction func uploadFile(_ sender: Any) {
        imagePicker!.present()
    }
    
    @IBAction func subscribeToRealtime(_ sender: Any) {
        _ = realtime.subscribe(channels:["collections.\(collectionId).documents"]) { message in
            print(message)
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        account.deleteSession(sessionId: "") { result in
            var string: String = ""
            
            switch result {
            case .failure(let error): string = error.message
            case .success(let response): string = String(describing: response.body!)
            }

            DispatchQueue.main.async {
                self.responseText.text = string
            }
        }
    }
}

extension ViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        var output = ""
        
        let buffer = ByteBufferAllocator()
            .buffer(data: image!.jpegData(compressionQuality: 1)!)
        
        let file = File(name: "my_image.jpg", buffer: buffer)
        
        storage.createFile(file: file) { result in
            switch result {
            case .failure(let error):
                output = error.message
            case .success(var response):
                output = response.body!.readString(length: response.body!.readableBytes) ?? ""
            }
            
            DispatchQueue.main.async {
                self.responseText.text = output
            }
        }
    }
}

