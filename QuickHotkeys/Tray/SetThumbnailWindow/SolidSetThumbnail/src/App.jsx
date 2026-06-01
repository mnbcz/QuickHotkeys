import { createEffect, onMount, createSignal } from "solid-js";

// https://icons8.com/preloaders/en/search/circle

let selectedFileTest = "D:\Sources\Autohotkey\QuickHotkeys-4\video\Lidia Pirelli is great - XVIDEOSCOM.mp4"

function App() {

  const [selectedFile, setSelectedFile] = createSignal('')

  // Вызывается один раз при монтировании.
  onMount(async () => {
    // Test
    let ahk = await window.chrome.webview.hostObjects.ahk;
    setSelectedFile(await ahk.selectedFile)

    // setSelectedFile(selectedFileTest)

  });

  function buttonClick(e){
    // alert("buttonClick()")
    let timeValue = document.querySelector("#time").value.trim()
    let video = document.querySelector("#video").value.trim()
    if(video == ""){
      document.querySelector("#error").innerHTML = "The field 'Path to video' cannot be empty!"
      return
    }
    if(timeValue == ""){
      document.querySelector("#error").innerHTML = "The field 'Frame time' cannot be empty!"
      return
    }
    // Убираем кавычки " из начала и из конца строки. 
    timeValue = timeValue.replace(/^"?(.+?)"?$/,'$1');
    // 00:20:30.900, 00:20.800
    let regex = new RegExp("^[0-9]+\:[0-9]+(\:[0-9]+)?(\.[0-9]+)?$", "i")
    if(!regex.test(timeValue)){
      regex = new RegExp("^[a-z]\:", "i")
      if(!regex.test(timeValue)){
        document.querySelector("#error").innerHTML = "Incorrect path to the image file, or incorrect time specified."
        return
      }
    }
    document.querySelector("#error").innerHTML = ""
    // Отключаем кнопку
    document.querySelector("button").disabled = "disabled"
    document.querySelector("button").innerHTML = '<img src="src/assets/loading.svg" class="loading"></img>'
    sendToAhk_timeValue(video, timeValue)
  }

  async function sendToAhk_timeValue(video, timeValue){
    // alert("sendToAhk_timeValue")
    let ahk = await window.chrome.webview.hostObjects.ahk;
    let result_from_ahk = await ahk.timeValueCallback(video, timeValue);
    // ahk.timeValueCallback(timeValue);
    document.querySelector("#error").innerHTML = result_from_ahk
  }

  async function selectVideo(e){
    let ahk = await window.chrome.webview.hostObjects.ahk;
    let selectedFile = await ahk.selectFile();
    document.querySelector("#video").value = selectedFile
  }

  async function selectThumbnail(e){
    let ahk = await window.chrome.webview.hostObjects.ahk;
    let selectedFile = await ahk.selectFile();
    document.querySelector("#time").value = selectedFile
  }

  // window.fromAhk_setFileStatus = fromAhk_setFileStatus

  return (
    <div class="form">
      <label for="video">Path to video:</label>
      <div class="row">
        <input type="text" id="video" value={selectedFile()}></input>
        
        <label class="custom-file-upload" onClick={selectVideo} title="Select file">
          ...
          {/* <input type="file" id="selectVideo" onChange={selectVideo} /> */}
        </label>
      </div>

      <label for="time">Frame time (like 01:30.700), or path to thumbnail image:</label>
      <div class="row">
        <input type="text" id="time"></input>
        <label class="custom-file-upload" onClick={selectThumbnail} title="Select file">
          ...
          {/* <input type="file" id="selectThumbnail" onChange={selectThumbnail} /> */}
        </label>
      </div>
      
      <div class="row">
        <button onClick={buttonClick}>Go</button>
      </div>

      <div class="row error" id="error">
        
      </div>
    </div>
  )
}

export default App;
