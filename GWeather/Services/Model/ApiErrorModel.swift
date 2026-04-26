import Foundation

struct ApiErrorModel: Decodable, Error {
    let message: String
    let code: Int
}
