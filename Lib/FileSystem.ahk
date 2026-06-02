

class FileSystem {

  ; https://learn.microsoft.com/en-us/office/vba/language/reference/user-interface-help/folder-object

  ; Возвращает все пути к файлам в каталоге dirPath, массивом.
  ; Если файлов нет, или каталога нет, возвращает пустой массив.
  getFilePaths(dirPath) {

    try {
      local objFSO := ComObject("Scripting.FileSystemObject")
      local objFolder := objFSO.GetFolder(dirPath)
      local files := objFolder.Files

      local filePaths := []

      for f in files {
        filePaths.Push(f.path)
      }

      return filePaths

    } catch as e {
      return []
    }

  }


  ; Возвращает все пути к файлам в каталоге dirPath, как массив объектов.
  ; https://learn.microsoft.com/en-us/office/vba/language/reference/user-interface-help/file-object#properties
  ; obj props:
  ; name = name.txt
  ; path = C:\...name.txt
  ; shortName = name.txt
  ; shortPath = C:\...name.txt
  ; size = 3410 (in bytes)
  ; Если файлов нет, или каталога нет, возвращает пустой массив.
  getFilePathObjects(dirPath) {

    try {
      local objFSO := ComObject("Scripting.FileSystemObject")
      local objFolder := objFSO.GetFolder(dirPath)
      local files := objFolder.Files

      local filePaths := []

      for f in files {
        filePaths.Push(f)
      }

      return filePaths

    } catch as e {
      return []
    }

  }


  ; Возвращает массив каталогов объектов в каталоге dirPath.
  ; Каталог содержит объект со свойствами name, path.
  ; Если каталогов нет, или каталога нет, возвращает пустой массив.
  getDirNamesAndPaths(dirPath) {

    try {
      local objFSO := ComObject("Scripting.FileSystemObject")
      local objFolder := objFSO.GetFolder(dirPath)
      local dirs := objFolder.SubFolders

      local dirNamesAndPaths := []

      for d in dirs {
        local objDir := {}
        objDir.name := d.name
        objDir.path := d.path
        dirNamesAndPaths.Push(objDir)
      }

      return dirNamesAndPaths

    } catch as e {
      return []
    }

  }


}


