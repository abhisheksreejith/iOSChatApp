////
////  GenerateToken.swift
////  Milestone 4
////
////  Created by Abhishek-Sreejith on 18/10/23.
////
// import Foundation
// import CryptoKit
// import JOSESwift
// import JWT
//
//// Header and Payload
// struct JWTHeader: Codable {
//    let alg: String = "RS256"
//    let typ: String = "JWT"
// }
//
// struct JWTPayload: Codable {
//    let iss: String // Issuer (your service account email)
//    let sub: String // Subject (your service account email)
//    let iat: Int // Issued at time (UNIX timestamp)
//    let exp: Int // Expiration time (UNIX timestamp)
// }
// class GenerateToken{
//    func generateJWT() {
//        let serviceAccountEmail = "your-service-account-email"
//        let privateKeyPEM = """
//        -----BEGIN PRIVATE KEY-----
//        Your private key
//        -----END PRIVATE KEY-----
//        """
//        let expirationDuration: TimeInterval = 3600
//
//        guard let privateKey = try? P256.Signing.PrivateKey(pemRepresentation: privateKeyPEM.data(using: .utf8)!) else {
//            print("Error loading private key")
//            return
//        }
//
//        let now = Date()
//        let claims = Claims(issuer: IssuerClaim(string: serviceAccountEmail), subject: SubjectClaim(string: serviceAccountEmail),
//  expiration: ExpirationClaim(value: now.addingTimeInterval(expirationDuration)))
//        let jwt = JWT(header: Header(), claims: claims)
//
//        do {
//            let signer = try JWTSigner.es256(privateKey: privateKey)
//            let jwtWithSignature = try jwt.sign(using: signer)
//            let jwtString = String(data: try jwtWithSignature.data(), encoding: .utf8)
//            print("Generated JWT: \(jwtString ?? "")")
//        } catch {
//            print("Error generating JWT: \(error)")
//        }
//    }
// }
//
