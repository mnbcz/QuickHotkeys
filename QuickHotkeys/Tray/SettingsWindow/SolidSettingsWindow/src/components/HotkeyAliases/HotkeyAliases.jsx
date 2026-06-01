
import { createSignal, createEffect, For, onMount } from "solid-js";
import { Button, Modal } from "solid-bootstrap";

import HotkeyAlias from "./HotkeyAlias"
import AddAlias from "./AddAlias"
import {parseHotkeyString} from "../../functions/functions"


let hotkeyAliasesTest = [
  {
    "id": 1089,
    "title": "Set English",
    "isEnable": 1,
    "hotkeyDisplay": "LCtrl+9",
    "hotkeyHotkey": "<^{9}",
    "aliasDisplay": "LCtrl+F8",
    "aliasHotkey": "<^{F8}",
    "scope": ""
  },
  {
    "id": 10182,
    "title": "Set Ru",
    "isEnable": 1,
    "hotkeyDisplay": "LCtrl+6",
    "hotkeyHotkey": "<^{8}",
    "aliasDisplay": "LCtrl+F7",
    "aliasHotkey": "<^{F7}",
    "scope": ""
  }
]


// Массив хоткеев алиасов.
const [hotkeyAliases, setHotkeyAliases] = createSignal([])
const [isShowAddAliasForm, setIsShowAddAliasForm] = createSignal(false)


function HotkeyAliases(){

  // Вызывается при нажатии на кнопку удалить алиас хоткей.
  const deleteEvent = (id) => {
    setHotkeyAliases(hotkeyAliases().filter((item) => (
      item.id !== id
    )));
    sendToAhk_deleteHotkeyAliases(id)
  }
 
  /**
   * Отмечен переключатель - включить/отключить хоткей.
   * Вызывается этот метод.
   * Обновляет хоткей в ahk.
   **/
  const toggleEnableEvent = (id) => {
    setHotkeyAliases(hotkeyAliases().map((item) => (
      item.id !== id ? item : { ...item, isEnable: !item.isEnable }
    )));
    sendToAhk_updateHotkeyAliases(id)
  }

  // Вызывается когда изменяется хоткей в поле.
  const hotkeyChangeEvent = (id, event) => {
    let value = event.target.value.trim()
    // Имя элемента.
    let name = event.target.name
    // console.log("hotkeyChangeEvent, value = ", value, ", name = ",  name)
    
    if(name === "hotkeyDisplay"){
      if(value == ""){
        alert("Hotkey field cannot be empty")
        return
      }
      let [hotkeyDisplay, hotkeyHotkey, key_]  = parseHotkeyString(value)
      // console.log(hotkeyDisplay, hotkeyHotkey)
      hotkeyHotkey += "{" + key_ + "}"
      setHotkeyAliases(hotkeyAliases().map((item) => (
        item.id !== id ? item : { ...item, hotkeyDisplay, hotkeyHotkey}
      )));
      sendToAhk_updateHotkeyAliases(id)
    }

    if(name === "aliasDisplay"){
      if(value == ""){
        alert("Hotkey field cannot be empty")
        return
      }
      let [aliasDisplay, aliasHotkey, key_]  = parseHotkeyString(value)
      aliasHotkey += key_
      // console.log("aliasDisplay:", aliasDisplay, aliasHotkey)
      setHotkeyAliases(hotkeyAliases().map((item) => (
        item.id !== id ? item : { ...item, aliasDisplay, aliasHotkey}
      )));
      sendToAhk_updateHotkeyAliases(id)
    }

    if(name === "scope"){
      setHotkeyAliases(hotkeyAliases().map((item) => (
        item.id !== id ? item : {...item, scope: value}
      )));
      sendToAhk_updateHotkeyAliases(id)  
    }
  }
  
  // Вызывается когда нажата кнопка - Добавить алиас.
  const addAliasClick = () => {
    setIsShowAddAliasForm(true)
  }

  // Вызывается когда нажата кнопка - Добавить, в форме добавления алиаса.
  const addAliasSubmitEvent = (event) => {
    event.preventDefault()
    // console.log(event)
    let alias = {}
    alias.id = Math.random().toString(16).slice(2)
    alias.title = event.target.elements.addAlias_title.value
    alias.isEnable = 1
    alias.hotkeyDisplay = event.target.elements.addAlias_from.value.trim()

    if(alias.hotkeyDisplay == ""){
      alert("Hotkey field cannot be empty")
      return
    }

    let [hotkeyDisplay, hotkeyHotkey, key_]  = parseHotkeyString(alias.hotkeyDisplay)
    alias.hotkeyDisplay = hotkeyDisplay
    alias.hotkeyHotkey = hotkeyHotkey + "{" + key_ + "}"

    alias.aliasDisplay = event.target.elements.addAlias_to.value.trim()

    if(alias.aliasDisplay == ""){
      alert("Alias field cannot be empty")
      return
    }

    let [hotkeyDisplay2, hotkeyHotkey2, key_2]  = parseHotkeyString(alias.aliasDisplay)
    alias.aliasDisplay = hotkeyDisplay2
    alias.aliasHotkey = hotkeyHotkey2 + key_2 

    alias.scope = event.target.elements.addAlias_scope.value
    // console.log(alias)

    let hkAliases = [...hotkeyAliases()]
    hkAliases.push(alias)
    // console.log(hkAliases)
    setHotkeyAliases(hkAliases)
    setIsShowAddAliasForm(false)
    sendToAhk_addHotkeyAliases()
  }
  

  /**
   * Обновляет состояние хоткеев в ahk, состоянием отсюда.
   * Устанавливает Hotkey().
   * @param {string} id Id хоткея, который нужно обновить.  
   */
  async function sendToAhk_updateHotkeyAliases(id){
    let ahk = await window.chrome.webview.hostObjects.ahk;
    let hotkeysStr = JSON.stringify(hotkeyAliases());
    ahk.hotkeyAliases_updateHotkey(hotkeysStr, id);
  }

  /**
   * Обновляет состояние хоткеев в ahk, состоянием отсюда.
   * Удаляет Hotkey().
   * @param {string} id Id хоткея, который нужно удалить.  
   */
  async function sendToAhk_deleteHotkeyAliases(id){
    let ahk = await window.chrome.webview.hostObjects.ahk;
    let hotkeysStr = JSON.stringify(hotkeyAliases());
    ahk.hotkeyAliases_deleteHotkey(hotkeysStr, id);
  }

  /**
   * Обновляет состояние хоткеев в ahk, состоянием отсюда.
   * Удаляет Hotkey().
   * @param {string} id Id хоткея, который нужно удалить.  
   */
  async function sendToAhk_addHotkeyAliases(){
    let ahk = await window.chrome.webview.hostObjects.ahk;
    // console.log("sendToAhk_addHotkeyAliases:")
    // console.log(hotkeyAliases())
    let hotkeysStr = JSON.stringify(hotkeyAliases());
    ahk.hotkeyAliases_addHotkey(hotkeysStr);
  }

  /**
   * Устанавливает состояние хоткеев, и ahk.hotkeys.
   * Вызывается один раз при монтировании.
   */
  onMount(async () => {
      let ahk = await window.chrome.webview.hostObjects.ahk;
      let hotkeysStr = await ahk.hotkeyAliases;
      let hotkeysObj = await JSON.parse(hotkeysStr);
      setHotkeyAliases(hotkeysObj);

      // TEST
      // setHotkeyAliases(hotkeyAliasesTest)
  });

  return (
    <>

      <div class='mb-1'>
        Here you can assign an alias to the hotkey. <br/>
        In the field on the left - the real hotkey must be specified. In the field on the right - the alias, that the real hotkey will press.<br/>
        For example, to switch the language to English, this hotkey is assigned in Windows - <kbd>Ctrl+Shift+9</kbd>.<br/>
        And this hotkey assigned to switch the language to Another language - <kbd>Ctrl+Shift+8</kbd>.<br/>
        These hotkeys are not convenient to press.<br/>
        It is much more convenient to press - <kbd>Ctrl+F9</kbd>, <kbd>Ctrl+F8</kbd>. But in Windows you can not assign these hotkeys.<br/>
        Because of this, we assign these aliases (<kbd>Ctrl+F9</kbd>, <kbd>Ctrl+F8</kbd>).<br/>
        To assign hotkeys for switching between languages, you need to go to <kbd>Windows Settings</kbd> - <kbd>Win+I</kbd>. Then type <kbd>Typing</kbd> in the search, and select <kbd>Typing Settings</kbd>. Then <kbd>Advanced keyboard settings</kbd>. Then click the link at the bottom - <kbd>Input language hotkeys</kbd>. A window with languages ​​​​will open. <br/>
        Click the <kbd>Change Key Sequence</kbd> button, and assign there for the English language - hotkey <kbd>Ctrl+Shift+9</kbd>, and for Another Language - <kbd>Ctrl+Shift+8</kbd>. (You do not need to assign hotkeys like <kbd>Ctrl+8</kbd>, due to conflicts).<br/>
        And then just turn on the hotkeys below here: <kbd>Set English</kbd>, and <kbd>Set Language 2</kbd> (turn on the switch on the right).
        <br/><br/>
        <b>Note:</b> The <kbd>Scope</kbd> field - is the hotkey's scope. For example, if you specify <kbd>CabinetWClass</kbd> here, the hotkey will only work in the FileExplorer window.
      </div>

      <For each={hotkeyAliases()}>
      {(item, index) =>
        <HotkeyAlias
          item={item} 
          index={index() + 1}
          deleteEvent={deleteEvent}
          toggleEnableEvent={toggleEnableEvent} 
          hotkeyChangeEvent={hotkeyChangeEvent}
        />
      }
      </For>

      <Show when={isShowAddAliasForm()}>
        <AddAlias 
          addAliasSubmitEvent={addAliasSubmitEvent} 
        />
      </Show>
    
      <Button class='mb-4' style={{ "margin-right": "auto", "display": "block" }} variant="success" onClick={addAliasClick}>Add alias</Button>


    </>

  )

}


export default HotkeyAliases


