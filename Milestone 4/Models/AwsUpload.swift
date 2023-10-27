//
//  AwsUpload.swift
//  Milestone 4
//
//  Created by Abhishek-Sreejith on 06/10/23.
//

import Foundation
import AWSS3
import AWSCore
class AwsUpload {
    static let shared = AwsUpload()
    var imageUrl: String = ""
    func uploadImage(imagaData image: UIImage, imageName imgName: String) {
        let accessKey = "AKIAXREEJEXVN35MHXPV"
        let secretKey = "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"
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let confguration = AWSServiceConfiguration(region: .APSouth1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = confguration
        let s3BucketName = "abhishek-milestone4"
        let remoteName = imgName
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(imgName)
        let image = image
        let data = image.jpegData(compressionQuality: 0.5)
        do {
            try data?.write(to: fileURL)
        } catch {}
        let uploadRequest = AWSS3TransferManagerUploadRequest()!
        uploadRequest.body = fileURL
        uploadRequest.key = remoteName
        uploadRequest.bucket = s3BucketName
        uploadRequest.contentType = "image/jpeg"
       // uploadRequest.acl = .publicRead
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest).continueWith { (task) -> Any? in
            if let error = task.error {
                print("Upload failed with error: \(error.localizedDescription)")
            }
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
                if let absoluteString = publicURL?.absoluteString {
                    print("Uploaded to: \(absoluteString)")
                    self.imageUrl = absoluteString
                    print(self.imageUrl)
                }
        }
            return self.imageUrl
        }
    }
}
