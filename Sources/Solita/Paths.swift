import Foundation
import PathKit

public class Paths {
    private let outputDir: Path
    init(outputDir: String){
        self.outputDir = Path(outputDir)
    }
    
    public func root() -> Path {
        return (outputDir)
    }
    
    public func accountsDir() -> Path {
        return (outputDir + "accounts")
    }
    
    public func relAccountsDir() -> Path {
        return (Path.current + accountsDir())
    }
    
    public func instructionsDir() -> Path {
        return (outputDir + Path("instructions"))
    }
    
    public func relInstructionsDir() -> Path {
        return (Path.current + instructionsDir())
    }
    
    public func typesDir() -> Path {
        return (outputDir + Path("types"))
    }
    
    public func relTypesDir() -> Path {
        return (outputDir + typesDir())
    }
    
    public func errorsDir() -> Path {
        return (outputDir + Path("errors"))
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
