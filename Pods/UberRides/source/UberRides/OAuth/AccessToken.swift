//
//  AccessToken.swift
//  UberRides
//
//  Copyright © 2015 Uber Technologies, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

/// Stores information about an access token used for authorizing requests.
@objc(UBSDKAccessToken) public class AccessToken: NSObject, NSCoding, Decodable {
    
    /// String containing the bearer token.
    @objc public private(set) var tokenString: String?
    
    /// String containing the refresh token.
    @objc public private(set) var refreshToken: String?
    
    /// The expiration date for this access token
    @objc public private(set) var expirationDate: Date?
    
    /// The scopes this token is valid for
    @objc public private(set) var grantedScopes: [RidesScope] = []
    
    /**
     Initializes an AccessToken with the provided tokenString
     
     - parameter tokenString: The tokenString to use for this AccessToken
     
     - returns: an initialized AccessToken object
     */
    @objc public init(tokenString: String) {
        super.init()
        self.tokenString = tokenString
    }
    
    /**
     Initializer to build an accessToken from the provided NSCoder. Allows for 
     serialization of an AccessToken
     
     - parameter decoder: The NSCoder to decode the AcccessToken from
     
     - returns: An initialized AccessToken, or nil if something went wrong
     */
    @objc public required init?(coder decoder: NSCoder) {
        super.init()
        guard let token = decoder.decodeObject(forKey: "tokenString") as? String else {
            return nil
        }
        tokenString = token
        refreshToken = decoder.decodeObject(forKey: "refreshToken") as? String
        expirationDate = decoder.decodeObject(forKey: "expirationDate") as? Date
        if let scopesString = decoder.decodeObject(forKey: "grantedScopes") as? String {
            grantedScopes = scopesString.toRidesScopesArray()
        }
    }
    
    /**
     Encodes the AccessToken. Required to allow for serialization
     
     - parameter coder: The NSCoder to encode the access token on
     */
    @objc public func encode(with coder: NSCoder) {
        coder.encode(self.tokenString, forKey: "tokenString")
        coder.encode(self.refreshToken, forKey:  "refreshToken")
        coder.encode(self.expirationDate, forKey: "expirationDate")
        coder.encode(self.grantedScopes.toRidesScopeString(), forKey: "grantedScopes")
    }
    
    /**
     Mapping function used by ObjectMapper. Builds an AccessToken using the provided
     Map data
     
     - parameter map: The Map to use for populatng this AccessToken.
     */
    enum CodingKeys: String, CodingKey {
        case tokenString         = "access_token"
        case refreshToken        = "refresh_token"
        case expirationDate      = "expiration_date"
        case scopesString        = "scope"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tokenString = try container.decode(String.self, forKey: .tokenString)
        refreshToken = try container.decodeIfPresent(String.self, forKey: .refreshToken)
        expirationDate = try container.decodeIfPresent(Date.self, forKey: .expirationDate)
        let scopesString = try container.decodeIfPresent(String.self, forKey: .scopesString)
        grantedScopes = scopesString?.toRidesScopesArray() ?? []
    }
}
