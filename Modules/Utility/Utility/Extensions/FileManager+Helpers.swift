public extension FileManager {
    static func fileName(fileUrl: String) -> String? {
        var fileName = ""
        fileName = URL(fileURLWithPath: fileUrl).lastPathComponent
        return fileName
    }
    
    static func fileExtension(fileUrl: String) -> String? {
        var fileExtension = ""
        fileExtension = URL(fileURLWithPath: fileUrl).pathExtension
        return fileExtension.uppercased()
    }
    
    static func getFileUrlDocuments(withURLString: String) -> URL {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/" + (withURLString as NSString).lastPathComponent
        let url = URL(fileURLWithPath: path)
        return url
    }
    
    static func getFileUrlLibraryDocuments(withURLString: String) -> URL {
        let path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first! + "/" + (withURLString as NSString).lastPathComponent
        let url = URL(fileURLWithPath: path)
        return url
    }
    static func checkIsFileExist(url: URL) -> Bool {
        let filePath = url.path
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath) {
            return true
        } else {
            return false
        }
    }
    
    @discardableResult
    static func removeFile(with url: URL) -> Bool {
        if checkIsFileExist(url: url) {
            do {
                try FileManager.default.removeItem(at: url)
                return true
            } catch {
                DPrint("Unable to remove attachment: \(error.localizedDescription)")
                return false
            }
        }
        return false
    }
}
