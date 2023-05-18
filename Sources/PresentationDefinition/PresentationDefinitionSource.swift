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
      let presentationDefinition = try JSONDecoder().decode(PresentationDefinition.self, from: jsonData)

      self = .passByValue(presentationDefinition: presentationDefinition)
    } else if let uri = authorizationRequestObject[Constants.PRESENTATION_DEFINITION_URI] as? String,
              let uri = URL(string: uri),
              uri.scheme == Constants.HTTPS {
      self = .fetchByReference(url: uri)
    } else if let scope = authorizationRequestObject[Constants.SCOPE] as? String,
              !scope.components(separatedBy: " ").isEmpty {
      self = .implied(scope: scope.components(separatedBy: " "))

    } else {

      throw PresentationError.invalidPresentationDefinition
    }
  }

  init(authorizationRequestData: AuthorizationRequestUnprocessedData) throws {
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
              let uri = URL(string: presentationDefinitionUri),
              uri.scheme == Constants.HTTPS {
      self = .fetchByReference(url: uri)
    } else if let scopes = authorizationRequestData.scope?.components(separatedBy: " "),
              !scopes.isEmpty {
      self = .implied(scope: scopes)
    } else {

      throw PresentationError.invalidPresentationDefinition
    }
  }
}
