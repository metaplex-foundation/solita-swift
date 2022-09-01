import Foundation
import SwiftCLI
import Solita
import PathKit

fileprivate func getDencoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    return decoder
}

class SolitaRenderCommand: Command {
    let name = "render"
    
    @Param var idlPath: String
    @Param var outputDir: String
    
    @Key("-p", "--projectName", description: "Project Name")
    var projectName: String?
    
    func execute() throws {
        stdout <<< "Reading \(idlPath)"
        let path = Path(idlPath)
        if !path.isFile {
            stdout <<< "File doesnt exist: \(path)"
            return
        }
        if !path.isReadable {
            stdout <<< "File is not readable: \(path)"
            return
        }
        let idl = try! getDencoder().decode(Idl.self, from: path.read())
        let solita = Solita(idl: idl, projectName: projectName ?? "Generated")
        solita.renderAndWriteTo(outputDir: outputDir)
    }
}

let solanaCli = CLI(name: "solita")
solanaCli.commands = [SolitaRenderCommand()]
solanaCli.go()
