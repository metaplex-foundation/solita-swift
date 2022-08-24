import Foundation
import PathKit

struct SerializerSnippets {
    let importSnippet: String
    let resolveFunctionsSnippet: String
    let serialize: String
    let deserialize: String
}

public class CustomSerializers {
    let serializers: Dictionary<String, String>
    init(serializers: Dictionary<String, String>){
        self.serializers = serializers
    }
    
    static func create(projectRoot: String, serializers: Dictionary<String, String>) -> CustomSerializers{
        var resolvedSerializers: [String:String] = [:]
        for key in serializers.keys {
            let val = serializers[key]!
            resolvedSerializers[key] = (Path(projectRoot) + Path(val)).string
        }
        verifyAccess(serializers: resolvedSerializers)
        return CustomSerializers(serializers: resolvedSerializers)
    }

    static func empty() -> CustomSerializers{
        return CustomSerializers.create(projectRoot: "", serializers: [:])
      }

    func serializerPathFor(typeName: String, modulePath: String) -> String? {
        let fullPath = self.serializers[typeName]
        return (fullPath == nil) ? nil : (Path(modulePath) + Path(fullPath!)).string
    }
    
    func snippetsFor(typeName: String,
                     modulePath: String,
                     builtinSerializer: String
    ) -> SerializerSnippets {
        let p = self.serializerPathFor(typeName: typeName, modulePath: modulePath)
        let mdl: String? = {
            guard let p = p else { return nil }
            return Path(p).lastComponentWithoutExtension
        }()
        
        let importSnippet = mdl == nil ? "" : "import \(mdl!)\n"
        
        let resolveFunctionsSnippet =
              (mdl == nil)
                ? ""
                :
"""
        let serializer = customSerializer
"""
        return SerializerSnippets(importSnippet: importSnippet, resolveFunctionsSnippet: resolveFunctionsSnippet, serialize: (mdl == nil) ? "\(builtinSerializer).serialize" : "resolvedSerialize", deserialize: (mdl == nil) ? "\(builtinSerializer).deserialize" : "resolvedDeserialize")
    }
}

func verifyAccess(serializers: Dictionary<String, String>) {
    var violations: [String] = []
    for key in serializers.keys {
        let val = serializers[key]!
        if !canAccess(p: Path(val)) {
          violations.append( "Cannot access de/serializer for ${key} resolved to \(val)" )
        }
    }
    if (violations.count > 0) {
        fatalError("Encountered issues resolving de/serializers:\n \(violations.joined(separator: "\n  "))")
    }
}
