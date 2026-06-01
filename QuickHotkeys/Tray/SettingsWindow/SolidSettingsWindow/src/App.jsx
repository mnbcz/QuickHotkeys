
import { createSignal, createEffect, For, onMount, ErrorBoundary } from "solid-js";
import { FormCheck, Form, FormControl, InputGroup, Button, Modal } from "solid-bootstrap";


import HotkeyList from './components/HotkeyList';
import HotkeyAliases from './components/HotkeyAliases/HotkeyAliases';
import HotkeysDisabled from './components/HotkeyDisabled/HotkeysDisabled';


import ConfirmModal, { showConfirmModal } from './components/ConfirmModal';
import { hotkeys, setHotkeys } from './components/HotkeyList'
// В начале скомпилированного файла указать
// let main_fromAhk_ResponseToSelectKey


const data = [
    {
      "id": "Move_resize_window_with_left_right_mouse_button",
      "type": "noHotkey",
      "title": "Move & Resize window",
      "desc": "Simultaneous pressing of the <kbd>left</kbd> and <kbd>right</kbd> mouse buttons, turns on the window moving mode, or window resizing. Then, if only the <kbd>left</kbd> button is held down, then this moves the window. If only the <kbd>right</kbd> button is held down, then this changes the window size. <br/>If hold down <kbd>Ctrl</kbd> while moving, the window will move straight, vertically, or horizontally. By holding down only <kbd>Ctrl</kbd> and releasing the <kbd>left</kbd> mouse button, can move the window again by pressing the <kbd>left</kbd> mouse button.",
      "isEnable": 1,
      "function": "move_resize_window_with_left_right_mouse_button_setHotkeys"
    },
    {
      "id": "minimizeMaximizeWindowByModWheel",
      "type": "noHotkey",
      "title": "Minimize & Maximize window by Wheel",
      "desc": "Holding down the modifier key, and turning the <kbd>wheel</kbd>, maximizes or minimizes the window. If turn the wheel twice, it goes into full-screen.",
      "isEnable": 1,
      "hotkeyDisplay": "LWin",
      "hotkeyModifiers": "<#",
      "function": "minimizeMaximizeWindowByWheelSetHotkeys",
      "sc": "Wheel",
      "index": 2,
      "scope": "Wheel"
    },
    {
      "id": "minimizeMaximizeBackWindowsByWheel",
      "type": "noHotkey",
      "title": "Maximize/minimize all windows on the screen, except the active one",
      "desc": "Holding down the modifier keys, and turning the <kbd>wheel</kbd>, it minimizes/maximizes all windows, except the active one. This remembers minimized windows made by <kbd>WheelDown</kbd>, and maximizes them via <kbd>WheelUp</kbd>.",
      "isEnable": 1,
      "hotkeyDisplay": "LWin+LAlt",
      "hotkeyModifiers": "<#<!",
      "function": "minimizeBackWindowsByWheel_SetHotkeys",
      "sc": "Wheel",
      "scope": "Wheel"
    },
    {
      "id": "moveWindowByWheel",
      "type": "noHotkey",
      "title": "Move window by Wheel",
      "desc": "Holding down the key (CapsLock), and turning the <kbd>wheel</kbd>, it moves window.",
      "isEnable": 1,
      "hotkeyDisplay": "CapsLock",
      "hotkeyModifiers": "Wheel",
      "function": "moveWindowByWheel_SetHotkeys",
      "sc": "Wheel",
      "scope": "Wheel"
    },
    {
      "id": "RButtonAndWheel",
      "type": "noHotkey",
      "title": "Minimize & Maximize window by Right mouse button & Wheel",
      "desc": "Holding down the <kbd>Right</kbd> mouse button, and turning the <kbd>wheel</kbd>, maximizes or minimizes the window. If turn the wheel twice, it goes into full-screen.",
      "isEnable": 1,
      "function": "RButtonAndWheel_SetFunction",
      "list": {
        "desc": "Action",
        "value": "minimizeMaximizeWindow",
        "items": [
          {
            "function": "minimizeMaximizeWindow",
            "display": "Minimize Maximize Window"
          },
          {
            "function": "nextPrevTab",
            "display": "Scroll tabs"
          }
        ]
      }
    },
    {
      "id": "closeTab",
      "type": "mod&key",
      "title": "Closes the tab",
      "desc": "RButton - right mouse button.",
      "isEnable": 1,
      "hotkeyDisplay": "LCtrl+RButton",
      "hotkeyModifiers": "<^",
      "function": "closeTab",
      "sc": "RButton",
      "scope": "RButton"
    },
    {
      "id": "closeWindow",
      "type": "mod&key",
      "title": "Closes the window",
      "desc": "RButton - right mouse button.",
      "isEnable": 1,
      "hotkeyDisplay": "LWin+RButton",
      "hotkeyModifiers": "<#",
      "function": "closeWindow",
      "sc": "RButton",
      "scope": "RButton"
    },
    {
      "id": "nextPreviousTabByWheel",
      "type": "noHotkey",
      "title": "Scrolls tabs forward/backward by Wheel",
      "desc": "Holding down the modifier key, and turning the <kbd>wheel</kbd>, it scrolls through the tabs. <br><b>Warning!</b>: <kbd>Shift+Wheel</kbd> disables horizontal scrolling. To scroll, use <kbd>Alt+Wheel</kbd> (by default), or <kbd>Shift+Win+Wheel</kbd>.",
      "isEnable": 1,
      "hotkeyDisplay": "LShift",
      "hotkeyModifiers": "<+",
      "function": "nextPreviousTabByWheel_SetHotkeys",
      "sc": "Wheel",
      "index": 8,
      "scope": "Wheel"
    },
    {
      "id": "scrollToTopBottomByWheel",
      "type": "noHotkey",
      "title": "Scrolls the page to Top/Bottom by Wheel",
      "desc": "Holding down the modifier key, and turning the <kbd>wheel</kbd>, this scrolls the page to the top or to the bottom. <br><b>Warning!</b>: <kbd>Ctrl+Wheel</kbd> disables window zooming. To zoom a window, use <kbd>Ctrl++</kbd>, <kbd>Ctrl+-</kbd>, or <kbd>Ctrl+Win+Wheel</kbd>, or <kbd>Ctrl+Shift+Alt+Wheel</kbd>. <br/> If hold LShift, it selects text, or files.",
      "isEnable": 1,
      "hotkeyDisplay": "LCtrl",
      "hotkeyModifiers": "<^",
      "function": "scrollToTopBottomByWheel_SetHotkeys",
      "sc": "Wheel",
      "scope": "Wheel"
    },
    {
      "id": "zoomByWheel",
      "type": "noHotkey",
      "title": "Zoom the page by Wheel",
      "desc": "Holding down the modifier key, and turning the <kbd>wheel</kbd>, this zooms the page.",
      "isEnable": 1,
      "hotkeyDisplay": "LCtrl+LWin",
      "hotkeyModifiers": "<^<#",
      "function": "zoomByWheel_SetHotkeys",
      "sc": "Wheel",
      "scope": "Wheel"
    },
    {
      "id": "scrollSelectByWheel",
      "type": "noHotkey",
      "title": "Scrolls down or up and selects text",
      "desc": "Holding down the modifier keys, and turning the <kbd>wheel</kbd>, it's scrolls the page up or down, and selects text.",
      "isEnable": 1,
      "hotkeyDisplay": "LCtrl+LShift",
      "hotkeyModifiers": "<^<+",
      "function": "scrollSelectByWheel_SetHotkeys",
      "sc": "Wheel",
      "scope": "Wheel"
    },
    {
      "id": "scrollHorizontal",
      "type": "noHotkey",
      "title": "Horizontal Scrolling",
      "desc": "Holding down the modifier key, and turning the <kbd>wheel</kbd>, this scrolls the page horizontally.",
      "isEnable": 1,
      "hotkeyDisplay": "LAlt",
      "hotkeyModifiers": "<!",
      "function": "scrollHorizontal_SetHotkeys",
      "sc": "Wheel",
      "scope": "Wheel"
    },
    {
      "id": "hideDesktopIcons",
      "type": "mod&key",
      "title": "Hides/shows icons from the desktop.",
      "desc": "D - Desktop. Windows hokey <kbd>Win+D</kbd> - minimizes all windows and maximizes them again.",
      "isEnable": 1,
      "hotkeyDisplay": "LCtrl+LWin+D",
      "hotkeyModifiers": "<^<#",
      "function": "hideDesktopIcons",
      "sc": "sc20",
      "scope": ""
    },
    {
      "id": "removeWindowCaption",
      "type": "mod&key",
      "title": "Removes the TitleBar (Caption)",
      "desc": "Removes/shows the TitleBar from the window, so that the window can no longer be moved by TitleBar. This only works on windows with native TitleBar. It does not work for browsers TitleBars.",
      "isEnable": 1,
      "hotkeyDisplay": "LCtrl+LWin+C",
      "hotkeyModifiers": "<^<#",
      "function": "removeWindowCaption",
      "sc": "sc2E",
      "scope": ""
    },
    {
      "id": "alwaysOnTop",
      "type": "mod&key",
      "title": "Always On Top",
      "desc": "Displays the window always on top of all other windows. Works for windows where the cursor is located. Pressing it again, returns the window to normal mode.",
      "isEnable": 1,
      "hotkeyDisplay": "LCtrl+LWin+T",
      "hotkeyModifiers": "<^<#",
      "function": "alwaysOnTop",
      "sc": "sc14",
      "scope": ""
    },
    {
      "id": "setTransparency",
      "type": "mod&key",
      "title": "Set Transparency",
      "desc": " If press the modifiers, and then right-click, the window will become transparent. If hold down the modifiers, and release the right button, and spin the wheel, the transparency will change. To turn off transparency, press this hotkey again, and release all keys.",
      "isEnable": 1,
      "hotkeyDisplay": "LCtrl+LWin+RButton",
      "hotkeyModifiers": "<^<#",
      "function": "setTransparency",
      "sc": "RButton",
      "scope": ""
    },
    {
      "id": "copy",
      "type": "noHotkey",
      "title": "Copy",
      "desc": "Copies the selected text or file. When the <kbd>left mouse</kbd> button is held down, and then a modifier is pressed.",
      "isEnable": 1,
      "hotkeyDisplay": "LCtrl",
      "hotkeyModifiers": "<^",
      "function": "copy_SetHotkey",
      "sc": "LButton",
      "scope": "LButton"
    },
    {
      "id": "paste",
      "type": "noHotkey",
      "title": "Paste",
      "desc": "Pastes text from the clipboard. When the <kbd>left mouse</kbd> button is held down, and then a modifier is pressed.",
      "isEnable": 1,
      "hotkeyDisplay": "LWin",
      "hotkeyModifiers": "<#",
      "function": "paste_SetHotkey",
      "sc": "LButton",
      "scope": "LButton"
    },
    {
      "id": "cut",
      "type": "noHotkey",
      "title": "Cut",
      "desc": "Cuts the selected text or files. When the <kbd>left mouse</kbd> button is held down, and then a modifier is pressed.",
      "isEnable": 1,
      "hotkeyDisplay": "LShift",
      "hotkeyModifiers": "<+",
      "function": "cut_SetHotkey",
      "sc": "LButton",
      "scope": "LButton"
    },
    {
      "id": "enter",
      "type": "noHotkey",
      "title": "Enter",
      "desc": "Presses Enter. When the <kbd>left mouse</kbd> button is held down, and then a modifier is pressed.",
      "isEnable": 1,
      "hotkeyDisplay": "`",
      "hotkeyModifiers": "",
      "function": "enter_SetHotkey",
      "sc": "LButton",
      "scope": "LButton"
    },
    {
      "id": "altTab",
      "type": "key&key",
      "title": "Alt&Tab",
      "desc": "Opens a window with a preview of all open programs. But unlike the usual AltTab, it leaves the window open without holding modifiers, and programs can be selected with the mouse.",
      "isEnable": 1,
      "hotkeyDisplay": "Alt & Tab",
      "hotkeyModifiers": "Alt & Tab",
      "function": "altTab_SetHotkey",
      "sc": "",
      "scope": ""
    },
    {
      "id": "fileExplorer_OpenDetails",
      "type": "mod&key",
      "title": "File Explorer, Right bar Details",
      "desc": "In File Explorer, opens the right bar Details, with a preview of the file, and metadata.",
      "isEnable": 1,
      "hotkeyDisplay": "Ctrl+.",
      "hotkeyModifiers": "^",
      "function": "fileExplorer_OpenDetails",
      "sc": "sc34",
      "scope": "FileExplorer",
      "ahk_classes": [
        "ahk_class CabinetWClass"
      ],
      "index": 18
    },
    {
      "id": "fileExplorer_OpenPreview",
      "type": "mod&key",
      "title": "File Explorer, Right bar Preview",
      "desc": "In File Explorer, opens the right bar Preview, with a large preview of the file.",
      "isEnable": 1,
      "hotkeyDisplay": "Ctrl+/",
      "hotkeyModifiers": "^",
      "function": "fileExplorer_OpenPreview",
      "sc": "sc35",
      "scope": "FileExplorer",
      "ahk_classes": [
        "ahk_class CabinetWClass"
      ]
    },
    {
      "id": "fileExplorer_OpenLeftBar",
      "type": "mod&key",
      "title": "File Explorer, Left bar close/open",
      "desc": "In File Explorer, opens the left bar TreeView.",
      "isEnable": 1,
      "hotkeyDisplay": "Ctrl+'",
      "hotkeyModifiers": "^",
      "function": "fileExplorer_OpenLeftBar",
      "sc": "sc28",
      "scope": "FileExplorer",
      "ahk_classes": [
        "ahk_class CabinetWClass"
      ]
    },
    {
      "id": "stickyKeys",
      "type": "noHotkey",
      "title": "Sticky Keys",
      "desc": "This makes it much easier to press hotkeys. To press hotkeys like <kbd>Ctrl+Shift+b</kbd>, it possible to press not all keys at the same time. But first press Ctrl, release it, then press Shift, release it, then press b, and pressing <kbd>Ctrl+Shift+b</kbd> will trigger. For example, press save <kbd>Ctrl+S</kbd> only with left hand. Common usages: <kbd>Ctrl+S</kbd>, <kbd>Ctrl+A</kbd>, <kbd>Ctrl+F</kbd>, start sentence with capital letter. Type symbols <kbd>!?,</kbd> (Shift+1). <br/>When a modifier key (Ctrl, Shift, Win, Alt) was pressed and released, then this key is like not actually released, but continues to be pressed for 1 second. If no keys were pressed for 1 second, then the modifiers are automatically released.",
      "isEnable": 1,
      "function": "stickyKeys_setHotkeys"
    },
    {
      "id": "GoToStartEndLine",
      "type": "noHotkey",
      "title": "Go to start or end line",
      "desc": "If hold down <kbd>Ctrl+Left</kbd> or <kbd>Ctrl+Right</kbd> for a long time, the cursor moves to the beginning or end of the line. If also hold down LShift, it selects the text.",
      "isEnable": 1,
      "function": "GoToStartEndLine_SetHotkey"
    },
    {
      "id": "DeleteToStartLine",
      "type": "noHotkey",
      "title": "Erase to the beginning of the line",
      "desc": "If hold down <kbd>Ctrl+BackSpace</kbd> for a long time, the cursor moves to the beginning of the line and erases the text.",
      "isEnable": 1,
      "function": "DeleteToStartLine_SetHotkey"
    },
    {
      "id": "DeleteToEndLine",
      "type": "noHotkey",
      "title": "Erases to end of line",
      "desc": "If hold down <kbd>Ctrl+Delete</kbd> for a long time, the cursor moves to the end of the line and erases the text.",
      "isEnable": 1,
      "function": "DeleteToEndLine_SetHotkey"
    },
    {
      "id": "activateLastWindows",
      "type": "key&key",
      "title": "Switches between windows",
      "desc": "This switches between the two recently opened windows. If held down modifiers, and spin the wheel, it brings up the other windows in order of their activity.",
      "isEnable": 1,
      "hotkeyDisplay": "LWin & CapsLock",
      "hotkeyModifiers": "LWin & CapsLock",
      "function": "activateLastWindows_SetHotkeys",
      "sc": "",
      "scope": ""
    },
    {
      "id": "backSpace",
      "type": "noHotkey",
      "title": "BackSpace",
      "desc": "Presses BackSpace. When the <kbd>left mouse</kbd> button is held down, and then a modifier is pressed.",
      "isEnable": 1,
      "hotkeyDisplay": "Escape",
      "hotkeyModifiers": "",
      "function": "backSpace_SetHotkey",
      "sc": "LButton",
      "scope": "LButton"
    },
    {
      "id": "reloadScript",
      "type": "mod&key",
      "title": "Reload script",
      "desc": "",
      "isEnable": 1,
      "hotkeyDisplay": "LCtrl+LWin+R",
      "hotkeyModifiers": "<^<#",
      "function": "reloadScript",
      "sc": "sc13",
      "scope": ""
    },
    {
      "id": "exitScript",
      "type": "mod&key",
      "title": "Exit script",
      "desc": "",
      "isEnable": 1,
      "hotkeyDisplay": "LCtrl+LWin+Escape",
      "hotkeyModifiers": "<^<#",
      "function": "exitScript",
      "sc": "sc1",
      "scope": ""
    },
    {
      "id": "Gestures",
      "type": "noHotkey",
      "title": "Mouse Gestures",
      "desc": "Holding right mouse button, enables gesture painting mode.",
      "isEnable": 1,
      "function": "gesture_EnableDisable"
    }
  
]


const defaultData = [
  {
    id: "Move_window_with_left_right_mouse_button",
    type: "noHotkey",
    title: "Move window",
    desc: "Holding the <i>left</i> and <i>right</i> mouse buttons moves the window. This will also move the window if you release the right mouse button.",
    isEnable: true,
  },
  {
    id: "Resize_window_with_left_right_mouse_button",
    type: "noHotkey",
    title: "Change window size",
    desc: "Pressing the <i>left</i> and <i>right</i> mouse buttons simultaneously, and then releasing the left button and holding only the right one, changes the size of the window.",
    isEnable: true
  },
  {
    id: 3,
    type: "mod&key",
    title: "Change window size",
    desc: "Pressing the left and right mouse buttons simultaneously, and then releasing the left button and holding only the right one, changes the size of the window.",
    isEnable: true,
    hotkeyDisplay: "Ctrl+Shift+H",
    hotkeyModifiers: "^+",
    sc: "H"
  },
  {
    id: 4,
    type: "mod&key",
    title: "Title",
    desc: "Desc 4",
    isEnable: true,
    hotkeyDisplay: "Ctrl+Shift+G",
    hotkeyModifiers: "^+",
    sc: "G"
  },
]



// Какие переменные в конфиге
let configInit = {}
// configInit.KeysList = {}
// configInit.KeysList.themesDir = "" 
// configInit.Sound = {}
// configInit.Sound.themesDir = ""



// Отсылает ahk урл который открыть в FileExplorer
// Урл берётся из href атрибута
async function toAhk_openInFileExplorerHdl(event) {

  // event.preventDefault()
  // // alert(event.target.href)
  // let ahk = await window.chrome.webview.hostObjects.ahk;
  // ahk.openInFileExplorer(event.target.href)

}



// hotkeysDefault
const resetToDefaultHotkeysClick = (e) => {
  let text = "Reset to default hotkeys?"
  showConfirmModal(text, (isOk) => {
    if (isOk) {
      (async () => {
        let ahk = await window.chrome.webview.hostObjects.ahk;
        let hotkeysStr = await ahk.hotkeysDefault;
        let hotkeysObj = await JSON.parse(hotkeysStr);
        // Устанавливаем в состояние дефаулт хоткеи
        setHotkeys(hotkeysObj);
        // Перезаписываем json файл дефаулт хоткеями.
        ahk.resetToDefaultHotkeys();

        // Test
        // setHotkeys(defaultData)
      })()
    }
  })
}

// Конфиг приложения, из ahk
const [config, setConfig] = createSignal(configInit)


function App() {

  // Вызывается один раз при монтировании.
  onMount(async () => {

    // let ahk = await window.chrome.webview.hostObjects.ahk;
    // let config = await ahk.config;
    // config = await JSON.parse(config);
    // setConfig(config);

    // TEST
    // setConfig(testConfig)

  });

  return (
    <>
      {/* <ErrorBoundary fallback={err => err}> */}
      <ConfirmModal />
      <HotkeyList />
      <Button class='mb-4' style={{ "margin-right": "auto", "display": "block" }} variant="success" onClick={resetToDefaultHotkeysClick}>Reset to default hotkeys</Button>
      {/* </ErrorBoundary> */}

      <h2>Aliases</h2>
      <HotkeyAliases />

      <h2>Disabled hotkeys</h2>
      <HotkeysDisabled />

    </>
  )
}


export default App;
export {
  config,
  toAhk_openInFileExplorerHdl,
  data,
  defaultData
  // ahk
};

