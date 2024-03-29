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
        .setEndpoint("YOUR_ENDPOINT")
        .setProject("YOUR_PROJECT_ID")
        .setSelfSigned()

    var databaseId = "YOUR_DATABASE_ID"
    var collectionId = "YOUR_COLLECTION_ID"
    var functionId = "YOUR_FUNCTION_ID"
    var bucketId = "YOUR_BUCKET_ID"
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
    lazy var databases = Databases(client)
    lazy var functions = Functions(client)

    var imagePicker: ImagePicker? = nil
    
    @IBOutlet weak var responseText: UITextView!
    @IBOutlet weak var downloadedImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    
    @IBAction func createAccount() {
        userEmail = "\(Int.random(in: 1..<Int.max))@example.com"
        
        Task {
            do {
                let user = try await account.create(
                    userId: ID.unique(),
                    email: userEmail,
                    password: "password"
                )
                userId = user.id
                dialogText = String(describing: user.toMap())
            } catch {
                dialogText = error.localizedDescription
            }
            showDialog()
        }
    }
    
    @IBAction func getAccount() {
        Task {
            do {
                let user = try await account.get()
                dialogText = String(describing: user.toMap())
            } catch {
                dialogText = error.localizedDescription
            }
            showDialog()
        }
    }
    
    @IBAction func createSession() {
        Task {
            do {
                let session = try await account.createEmailSession(
                    email: userEmail, 
                    password: "password"
                )
                dialogText = String(describing: session.toMap())
            } catch {
                dialogText = error.localizedDescription
            }
            showDialog()
            getAccount()
        }
    }
    
    @IBAction func createAnonymousSession() {
        Task {
            do {
                let session = try await account.createAnonymousSession()
                dialogText = String(describing: session.toMap())
            } catch {
                dialogText = error.localizedDescription
            }
            showDialog()
            getAccount()
        }
    }
    
    @IBAction func listSessions() {
        Task {
            do {
                let sessions = try await account.listSessions()
                dialogText = String(describing: sessions.toMap())
            } catch {
                dialogText = error.localizedDescription
            }
            showDialog()
        }
    }
    
    @IBAction func deleteSessions() {
        Task {
            do {
                _ = try await account.deleteSessions()
                dialogText = "Sessions Deleted."
            } catch {
                dialogText = error.localizedDescription
            }
            showDialog()
        }
    }
    
    @IBAction func deleteSession() {
        Task {
            do {
                _ = try await account.deleteSession(sessionId: "current")
                dialogText = "Session Deleted."
            } catch {
                dialogText = error.localizedDescription
            }
            showDialog()
        }
    }
    
    @IBAction func subscribe() {
        _ = realtime.subscribe(channels: ["databases.\(databaseId).collections.\(collectionId).documents"]) { event in
            DispatchQueue.main.async {
                self.dialogText = String(describing: event.payload!)
                self.showDialog()
            }
        }
    }
    
    @IBAction func createDoc() {
        Task {
            do {
                let document = try await databases.createDocument(
                    databaseId: databaseId,
                    collectionId: collectionId,
                    documentId: ID.unique(),
                    data: ["username": "Apple UIKit"],
                    permissions: [
                        Permission.read(Role.users()),
                        Permission.update(Role.users()),
                        Permission.delete(Role.users()),
                    ]
                )
                documentId = document.id
                dialogText = String(describing: document.toMap())
            } catch {
                dialogText = error.localizedDescription
            }
            showDialog()
        }
    }
    
    @IBAction func listDocs() {
        Task {
            do {
                let documents = try await databases.listDocuments(
                    databaseId: databaseId,
                    collectionId: collectionId,
                    queries: [
                        Query.equal("username", value: "Apple UIKit")
                    ]
                )
                dialogText = String(describing: documents.toMap())
            } catch {
                dialogText = error.localizedDescription
            }
            showDialog()
        }
    }
    
    @IBAction func deleteDoc() {
        Task {
            do {
                _ = try await databases.deleteDocument(
                    databaseId: databaseId,
                    collectionId: collectionId,
                    documentId: documentId
                )
                dialogText = "Document Deleted."
            } catch {
                dialogText = error.localizedDescription
            }
            showDialog()
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
        let file = InputFile.fromData(
            image.jpegData(compressionQuality: 1)!,
            filename: "file.png",
            mimeType: "image/png"
        )

        Task {
            do {
                let file = try await storage.createFile(
                    bucketId: bucketId,
                    fileId: ID.unique(),
                    file: file,
                    permissions: [
                        Permission.read(Role.users()),
                        Permission.update(Role.users()),
                        Permission.delete(Role.users()),
                    ]
                )
                fileId = file.id
                dialogText = String(describing: file.toMap())
            } catch {
                dialogText = error.localizedDescription
            }
            showDialog()
        }
    }
    
    @IBAction func listFiles() {
        Task {
            do {
                let files = try await storage.listFiles(
                    bucketId: bucketId
                )
                dialogText = String(describing: files.toMap())
            } catch {
                dialogText = error.localizedDescription
            }
            showDialog()
        }
    }
    
    @IBAction func deleteFile() {
        Task {
            do {
                _ = try await storage.deleteFile(
                    bucketId: bucketId,
                    fileId: fileId
                )
                dialogText = "File Deleted."
            } catch {
                dialogText = error.localizedDescription
            }
            showDialog()
        }
    }
    
    @IBAction func createExecution() {
        Task {
            do {
                let execution = try await functions.createExecution(
                    functionId: functionId
                )
                executionId = execution.id
                dialogText = String(describing: execution.toMap())
            } catch {
                dialogText = error.localizedDescription
            }
            showDialog()
        }
    }
    
    @IBAction func listExecutions() {
        Task {
            do {
                let executions = try await functions.listExecutions(
                    functionId: functionId
                )
                dialogText = String(describing: executions.toMap())
            } catch {
                dialogText = error.localizedDescription
            }
            showDialog()
        }
    }
    
    @IBAction func getExecution() {
        Task {
            do {
                let execution = try await functions.getExecution(
                    functionId: functionId,
                    executionId: executionId
                )
                dialogText = String(describing: execution.toMap())
            } catch {
                dialogText = error.localizedDescription
            }
            showDialog()
        }
    }
    
    @IBAction func generateJWT() {
        Task {
            do {
                let jwt = try await account.createJWT()
                dialogText = String(describing: jwt.toMap())
            } catch {
                dialogText = error.localizedDescription
            }
            showDialog()
        }
    }
    
    @IBAction func socialLogin(provider: String) {
        Task {
            do {
                _ = try await account.createOAuth2Session(
                    provider: provider
                )
                dialogText = "OAuth Success!"
            } catch {
                dialogText = error.localizedDescription
            }
            showDialog()
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
        uploadFile(image: image!)
    }
}

