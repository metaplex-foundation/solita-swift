import Foundation
import PathKit

public class Paths {
    private let outputDir: Path
    private let projectName: String
    init(outputDir: String, projectName: String){
        self.outputDir = Path(outputDir)
        self.projectName = projectName
    }
    
    public func root() -> Path {
        return (outputDir)
    }
    
    func sourcesFolder() -> Path {
        return (outputDir + Path("Sources") + Path(projectName))
    }
    
    public func accountsDir() -> Path {
        return sourcesFolder() + Path("accounts")
    }
    
    public func relAccountsDir() -> Path {
        return (Path.current + accountsDir())
    }
    
    public func instructionsDir() -> Path {
        return (sourcesFolder() + Path("instructions"))
    }
    
    public func relInstructionsDir() -> Path {
        return (Path.current + instructionsDir())
    }
    
    public func typesDir() -> Path {
        return (sourcesFolder() + Path("types"))
    }
    
    public func relTypesDir() -> Path {
        return (outputDir + typesDir())
    }
    
    public func errorsDir() -> Path {
        return sourcesFolder() + Path("errors")
    }
    
    public func relErrorsDir() -> Path {
        return (outputDir + errorsDir())
    }
    
    public func accountFile(name: String) -> String {
        return (accountsDir() + Path("\(name).swift")).string
    }
    
    public func instructionFile(name: String) -> String {
        return (instructionsDir() + Path("\(name).swift")).string
    }
    
    public func typeFile(name: String) -> String {
        return (typesDir() + Path("\(name).swift")).string
    }
    
    public func errorFile(name: String) -> String {
        return (errorsDir() + Path("\(name).swift")).string
    }
}
