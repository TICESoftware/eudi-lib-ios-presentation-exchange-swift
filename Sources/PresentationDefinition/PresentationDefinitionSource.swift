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
import Foundation

public enum PresentationDefinitionSource {
  case passByValue(presentationDefinition: PresentationDefinition)
  case fetchByReference(url: URL)
  case implied(scope: [String])
}

public extension PresentationDefinitionSource {
  init(authorizationRequestObject: JSONObject) throws {
    if let presentationDefinitionObject = authorizationRequestObject[Constants.PRESENTATION_DEFINITION] as? JSONObject {

      let jsonData = try JSONSerialization.data(withJSONObject: presentationDefinitionObject, options: [])
      do {
        let presentationDefinition = try JSONDecoder().decode(PresentationDefinition.self, from: jsonData)
        self = .passByValue(presentationDefinition: presentationDefinition)
      } catch {
        print(String(data: jsonData, encoding: .utf8)!)
        print(error)
        throw error
      }
    } else if let uri = authorizationRequestObject[Constants.PRESENTATION_DEFINITION_URI] as? String,
              let uri = URL(string: uri) {
      self = .fetchByReference(url: uri)
    } else if let scope = authorizationRequestObject[Constants.SCOPE] as? String,
              !scope.components(separatedBy: " ").isEmpty {
      self = .implied(scope: scope.components(separatedBy: " "))

    } else {

      throw PresentationError.invalidPresentationDefinition
    }
  }

  init(authorizationRequestData: AuthorisationRequestObject) throws {
    if let presentationDefinitionString = authorizationRequestData.presentationDefinition {
      guard
        presentationDefinitionString.isValidJSONString
      else {
        throw PresentationError.invalidPresentationDefinition
      }

      let parser = Parser()
      let result: Result<PresentationDefinitionContainer, ParserError> = parser.decode(
        json: presentationDefinitionString
      )
      guard
        let presentationDefinition = try? result.get().definition
      else {
        throw PresentationError.invalidPresentationDefinition
      }
      self = .passByValue(presentationDefinition: presentationDefinition)
    } else if let presentationDefinitionUri = authorizationRequestData.presentationDefinitionUri,
              let uri = URL(string: presentationDefinitionUri) {
      self = .fetchByReference(url: uri)
    } else if let scopes = authorizationRequestData.scope?.components(separatedBy: " "),
              !scopes.isEmpty {
      self = .implied(scope: scopes)
    } else {

      throw PresentationError.invalidPresentationDefinition
    }
  }
}
