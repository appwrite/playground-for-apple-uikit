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
        .setEndpoint("http://localhost/v1")
        .setProject("playground-for-uikit")
        .setSelfSigned()

    var collectionId = "test"
    var functionId = "test"
    var bucketId = "test"
    var documentId = ""
    var fileId = ""
    var executionId = ""
    var userId = ""
    var userEmail = ""
    
    var dialogText = ""
    var isShowingDialog = false
    
    lazy var account = Account(client)
    lazy var storage = Storage(client)
    lazy var realtime = Realtime(client)
    lazy var database = Database(client)
    lazy var functions = Functions(client)

    var imagePicker: ImagePicker? = nil
    
    @IBOutlet weak var responseText: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    
    @IBAction func createAccount() {
        userEmail = "\(Int.random(in: 1..<Int.max))@example.com"
        
        account.create(
            userId: "unique()",
            email: userEmail,
            password: "password"
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success(let user):
                    self.userId = user.id
                    self.dialogText = String(describing: user.toMap())
                    self.getAccount()
                }
                self.showDialog()
            }
        }
    }
    
    @IBAction func getAccount() {
        account.get { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success(let user):
                    self.dialogText = String(describing: user.toMap())
                }
                self.showDialog()
            }
        }
    }
    
    @IBAction func createSession() {
        account.createSession(
            email: userEmail,
            password: "password"
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success(let session):
                    self.dialogText = String(describing: session.toMap())
                    self.getAccount()
                }
                self.showDialog()
            }
        }
    }
    
    @IBAction func createAnonymousSession() {
        account.createAnonymousSession() { result in
            switch result {
            case .failure(let err):
                DispatchQueue.main.async {
                    self.dialogText = err.message
                    self.showDialog()
                }
            case .success:
                self.getAccount()
            }
        }
    }
    
    @IBAction func listSessions() {
        account.getSessions { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success(let sessions):
                    self.dialogText = String(describing: sessions.toMap())
                }
                self.showDialog()
            }
        }
    }
    
    @IBAction func deleteSessions() {
        account.deleteSessions { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success:
                    self.dialogText = "Sessions Deleted."
                }
                self.showDialog()
            }
        }
    }
    
    @IBAction func deleteSession() {
        account.deleteSession(sessionId: "current") { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success:
                    self.dialogText = "Session Deleted."
                }
                self.showDialog()
            }
        }
    }
    
    @IBAction func subscribe() {
        _ = realtime.subscribe(channels: ["collections.\(collectionId).documents"]) { event in
            DispatchQueue.main.async {
                self.dialogText = String(describing: event.payload!)
            }
        }
    }
    
    @IBAction func createDoc() {
        database.createDocument(
            collectionId: collectionId,
            documentId: "unique()",
            data: ["username": "user 1"],
            read: ["role:all"]
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success(let doc):
                    self.documentId = doc.id
                    self.dialogText = String(describing: doc.toMap())
                }
                self.showDialog()
            }
        }
    }
    
    @IBAction func listDocs() {
        database.listDocuments(collectionId: collectionId) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success(let docs):
                    self.dialogText = String(describing: docs.toMap())
                }
                self.showDialog()
            }
        }
    }
    
    @IBAction func deleteDoc() {
        database.deleteDocument(
            collectionId: collectionId,
            documentId: documentId
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success:
                    self.dialogText = "Document Deleted."
                }
                self.showDialog()
            }
        }
    }
   
//    @IBAction func preview() {
//        storage.getFilePreview(
//            bucketId: bucketId,
//            fileId: fileId,
//            width: 300
//        ) { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .failure(let error):
//                    self.dialogText = error.message
//                    self.showDialog()
//                case .success(let response):
//                    self.downloadedImage = UIImage(data: Data(buffer: response))
//                }
//            }
//        }
//    }
    
    @IBAction func upload() {
        imagePicker!.present()
    }
   
    func uploadFile(image: UIImage) {
        let imageBuffer = ByteBufferAllocator()
            .buffer(data: image.jpegData(compressionQuality: 1)!)
        
        storage.createFile(
            bucketId: bucketId,
            fileId: "unique()",
            file: File(name: "file.png", buffer: imageBuffer),
            onProgress: nil
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success(let file):
                    self.fileId = file.id
                    self.dialogText = String(describing: file.toMap())
                }
                self.showDialog()
            }
        }
    }
    
    @IBAction func listFiles() {
        storage.listFiles(bucketId: bucketId) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success(let files):
                    self.dialogText = String(describing: files.toMap())
                }
                self.showDialog()
            }
        }
    }
    
    @IBAction func deleteFile() {
        storage.deleteFile(
            bucketId: bucketId,
            fileId: fileId
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success:
                    self.dialogText = "File Deleted."
                }
                self.showDialog()
            }
        }
    }
    
    @IBAction func createExecution() {
        functions.createExecution(functionId: functionId) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success(let execution):
                    self.executionId = execution.id
                    self.dialogText = String(describing: execution.toMap())
                }
                self.showDialog()
            }
        }
    }
    
    @IBAction func listExecutions() {
        functions.listExecutions(functionId: functionId) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success(let executions):
                    self.dialogText = String(describing: executions.toMap())
                }
                self.showDialog()
            }
        }
    }
    
    @IBAction func getExecution() {
        functions.getExecution(
            functionId: functionId,
            executionId: executionId
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success(let execution):
                    self.dialogText = String(describing: execution.toMap())
                }
                self.showDialog()
            }
        }
    }
    
    @IBAction func generateJWT() {
        account.createJWT() { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success(let jwt):
                    self.dialogText = String(describing: jwt.toMap())
                }
                self.showDialog()
            }
        }
    }
    
    @IBAction func socialLogin(provider: String) {
        account.createOAuth2Session(provider: provider) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success:
                    self.getAccount()
                    self.dialogText = "OAuth Success!"
                }
                self.showDialog()
            }
        }
    }
    
    private func showDialog() {
        let alert = UIAlertController(
            title: "Alert",
            message: dialogText,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Cancel", comment: "Default action"),
            style: .default
        ) { _ in
            NSLog("The \"OK\" alert occured.")
        })
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        let buffer = ByteBufferAllocator()
            .buffer(data: image!.jpegData(compressionQuality: 1)!)
        
        let file = File(name: "my_image.jpg", buffer: buffer)
        
        storage.createFile(
            bucketId: bucketId,
            fileId: "unique()",
            file: file,
            onProgress: nil
        ) { result in
            switch result {
            case .failure(let error):
                self.dialogText = error.message
            case .success(let file):
                self.fileId = file.id
                self.dialogText = String(describing: file.toMap())
            }
            self.showDialog()
        }
    }
}

