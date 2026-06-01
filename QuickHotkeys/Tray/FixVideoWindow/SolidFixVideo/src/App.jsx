import { createEffect, onMount, createSignal } from "solid-js";

// https://icons8.com/preloaders/en/search/circle

let selectedFilesTest = [
  "D:\\D\\Video\\Favorite 3\\Apolonia and Little Caprice - First touch - XVIDEOSCOM.mp4",
  "D:\\D\\Video\\Favorite 3\\Cute brunette banged by big cocks - XVIDEOSCOM.mp4",
  "D:\\D\\Video\\Favorite 3\\Cute brunette banged by big cocks - XVIDEOSCOM.mp4"
]


function App() {

  const [selectedFiles, setSelectedFiles] = createSignal([]);

  // Вызывается один раз при монтировании.
  onMount(async () => {
    // Test
    let ahk = await window.chrome.webview.hostObjects.ahk;
    let selectedFiles = await ahk.selectedFiles;
    selectedFilesTest = await JSON.parse(selectedFiles);

    let setSelectedFilesArr = []
    selectedFilesTest.forEach(selectedFile => {
      let setSelectedFilesObj = {}
      setSelectedFilesObj.path = selectedFile
      setSelectedFilesObj.status = 0
      setSelectedFilesArr.push(setSelectedFilesObj)
    })
    setSelectedFiles(setSelectedFilesArr);
  });

  // Вызывается в ahk, чтобы установить состояние обработки файла.
  function fromAhk_setFileStatus(statusStr){
    let fileStatus = JSON.parse(statusStr);
    setSelectedFiles(selectedFiles().map(item => {
      if (item.path == fileStatus.path) {
        return {...item, status: fileStatus.status}
      }else{
        return {...item}
      }
    }))
  }

  window.fromAhk_setFileStatus = fromAhk_setFileStatus

  return (
    
    <div class="listContainer">
    <For each={selectedFiles()}>
      {(fileItem, index) =>
 
        // <div class={fileItem.status? "row green" : "row"}>
        <div class="row" classList={{"row green": fileItem.status == 1,
          "row": fileItem.status == "loading",
          "row red": fileItem.status == "error",
          "row": fileItem.status == 0
         }}>
          <div class="left">
            <Show when={fileItem.status == "loading"} fallback={""}>
              <img src="src/assets/loading.svg" class="loading"></img>
            </Show>
            <Show when={fileItem.status == 1} fallback={""}>
            ✓
            </Show>
            <Show when={fileItem.status == "error"} fallback={""}>
            ✕
            </Show>
          </div>
          <div class="right">{fileItem.path}</div>
        </div>

      }
    </For>
    </div>
    
  )
}

export default App;
