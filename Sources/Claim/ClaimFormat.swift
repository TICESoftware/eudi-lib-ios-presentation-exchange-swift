/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
public enum ClaimFormat: Equatable, Hashable {
  case msoMdoc
  case jwtType(JWTType)
  case ldpType(LDPType)
  case sdJWT(SDJWTType)
    
  public enum JWTType: Equatable, Hashable {
    case jwt
    case jwt_vc
    case jwt_vp
  }

  public enum SDJWTType: Equatable, Hashable {
    case vc
    case vc_zkp
  }

  public enum LDPType: Equatable, Hashable {
    case ldp
    case ldp_vc
    case ldp_vp
  }
  
  public var formatIdentifier: String {
    switch self {
    case .msoMdoc: "mso_mdoc"
    case .jwtType(let jwtType):
      switch jwtType {
      case .jwt: "jwt"
      case .jwt_vc: "jwt_vc"
      case .jwt_vp: "jwt_vp"
      }
    case .ldpType(let ldpType):
      switch ldpType {
      case .ldp: "ldp"
      case .ldp_vc: "ldp_vc"
      case .ldp_vp: "ldp_vp"
      }
    case .sdJWT(let sdJWTType):
      switch sdJWTType {
      case .vc: "vc+sd-jwt"
      case .vc_zkp: "vc+sd-jwt+zkp"
      }
    }
  }
  
  public init?(formatIdentifier: String) {
    switch formatIdentifier {
    case "mso_mdoc": self = .msoMdoc
    case "jwt": self = .jwtType(.jwt)
    case "jwt_vc": self = .jwtType(.jwt_vc)
    case "jwt_vp": self = .jwtType(.jwt_vp)
    case "ldp": self = .ldpType(.ldp)
    case "ldp_vc": self = .ldpType(.ldp_vc)
    case "ldp_vp": self = .ldpType(.ldp_vp)
    case "vc+sd-jwt": self = .sdJWT(.vc)
    case "vc+sd-jwt+zkp": self = .sdJWT(.vc_zkp)
    default: return nil
    }
  }
}
