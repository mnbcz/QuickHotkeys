
import { createSignal, createEffect, For, onMount } from "solid-js";
import { Button, Modal } from "solid-bootstrap";

import HotkeyDisabled from "./HotkeyDisabled"
import AddHotkeyDisabled from "./AddHotkeyDisabled"
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
const [hotkeyDisabled, setHotkeyDisabled] = createSignal([])
const [isShowAddForm, setIsShowAddForm] = createSignal(false)


function HotkeysDisabled(){

  // Вызывается при нажатии на кнопку удалить хоткей.
  const deleteEvent = (id) => {
    setHotkeyDisabled(hotkeyDisabled().filter((item) => (
      item.id !== id
    )));
    sendToAhk_deleteHotkeyDisabled(id)
  }
 
  /**
   * Отмечен переключатель - включить/отключить хоткей.
   * Обновляет хоткей в ahk.
   **/
  const toggleEnableEvent = (id) => {
    setHotkeyDisabled(hotkeyDisabled().map((item) => (
      item.id !== id ? item : { ...item, isEnable: !item.isEnable }
    )));
    sendToAhk_updateHotkeyDisabled(id)
  }

  // Вызывается когда изменяется хоткей в поле.
  const hotkeyChangeEvent = async (id, event) => {
    // alert("hotkeyChangeEvent")
    let value = event.target.value.trim()
    // Имя элемента.
    let name = event.target.name
    let ahk = await window.chrome.webview.hostObjects.ahk;
    // console.log("hotkeyChangeEvent, value = ", value, ", name = ",  name)
    
    if(name === "hotkeyDisplay"){
      // console.log("hotkeyChangeEvent(), name = hotkeyDisplay")
      if(value == ""){
        alert("Hotkey field cannot be empty")
        return
      }
      let [hotkeyDisplay, hotkeyHotkey, key_]  = parseHotkeyString(value)
      let sc = await ahk.getScKey(key_)
      let hotkey = hotkeyHotkey += sc
      // console.log("hotkeyHotkey = ", hotkeyHotkey)
      setHotkeyDisabled(hotkeyDisabled().map((item) => (
        item.id !== id ? item : { ...item, hotkeyDisplay, hotkey}
      )));
      sendToAhk_updateHotkeyDisabled(id)
    }

    if(name === "scope"){
      setHotkeyDisabled(hotkeyDisabled().map((item) => (
        item.id !== id ? item : {...item, scope: value}
      )));
      sendToAhk_updateHotkeyDisabled(id)  
    }
  }
  
  // Вызывается когда нажата кнопка - Добавить хоткей.
  const addDisabledHotkeyEvent = () => {
    setIsShowAddForm(true)
  }

  // Вызывается когда нажата кнопка - Добавить, в форме добавления хоткея.
  const addDisabledHotkeySubmitEvent = async (event) => {
    event.preventDefault()
    let ahk = await window.chrome.webview.hostObjects.ahk;
    // console.log(event)
    let alias = {}
    alias.id = Math.random().toString(16).slice(2)
    alias.title = event.target.elements.addHotkeyDisabled_title.value
    alias.isEnable = 1
    alias.hotkeyDisplay = event.target.elements.addHotkeyDisabled.value.trim()

    if(alias.hotkeyDisplay == ""){
      alert("Hotkey field cannot be empty")
      return
    }

    let [hotkeyDisplay, hotkeyHotkey, key_] = parseHotkeyString(alias.hotkeyDisplay)
    alias.hotkeyDisplay = hotkeyDisplay
    let sc = await ahk.getScKey(key_)
    alias.hotkey = hotkeyHotkey + sc

    alias.scope = event.target.elements.addHotkeyDisabled_scope.value
    // console.log(alias)

    let hkAliases = [...hotkeyDisabled()]
    hkAliases.push(alias)
    // console.log(hkAliases)
    setHotkeyDisabled(hkAliases)
    setIsShowAddForm(false)
    sendToAhk_addHotkeyDisabled()
  }
  

  /**
   * Обновляет состояние хоткеев в ahk, состоянием отсюда.
   * Устанавливает Hotkey().
   * @param {string} id Id хоткея, который нужно обновить.  
   */
  async function sendToAhk_updateHotkeyDisabled(id){
    let ahk = await window.chrome.webview.hostObjects.ahk;
    let hotkeysStr = JSON.stringify(hotkeyDisabled());
    ahk.hotkeyDisabled_updateHotkey(hotkeysStr, id);
  }

  /**
   * Обновляет состояние хоткеев в ahk, состоянием отсюда.
   * Удаляет Hotkey().
   * @param {string} id Id хоткея, который нужно удалить.  
   */
  async function sendToAhk_deleteHotkeyDisabled(id){
    let ahk = await window.chrome.webview.hostObjects.ahk;
    let hotkeysStr = JSON.stringify(hotkeyDisabled());
    ahk.hotkeyDisabled_deleteHotkey(hotkeysStr, id);
  }

  /**
   * Обновляет состояние хоткеев в ahk, состоянием отсюда.
   * Удаляет Hotkey().
   * @param {string} id Id хоткея, который нужно удалить.  
   */
  async function sendToAhk_addHotkeyDisabled(){
    let ahk = await window.chrome.webview.hostObjects.ahk;
    // console.log("sendToAhk_addHotkeyAliases:")
    // console.log(hotkeyDisabled())
    let hotkeysStr = JSON.stringify(hotkeyDisabled());
    ahk.hotkeyDisabled_addHotkey(hotkeysStr);
  }

  /**
   * Устанавливает состояние хоткеев, и ahk.hotkeys.
   * Вызывается один раз при монтировании.
   */
  onMount(async () => {
      let ahk = await window.chrome.webview.hostObjects.ahk;
      let hotkeysStr = await ahk.hotkeyDisabled;
      let hotkeysObj = await JSON.parse(hotkeysStr);
      setHotkeyDisabled(hotkeysObj);

      // TEST
      // setHotkeyAliases(hotkeyAliasesTest)
  });

  return (
    <>
      <div class='mb-1'>
        Hotkeys that need to be disabled.<br/>
        Required if there is a hotkey that can cause problems and it needs to be disabled. To eliminate accidental pressing.<br/>
        For example, there is a hotkey in File Explorer - <kbd>Ctrl+D</kbd>. If you accidentally press this hotkey, the selected file will be silently deleted.<br/>
        This hotkey is not needed, it is dangerous, and therefore it is better to disable it. Then when you press this hotkey, nothing happens.
        <br/><br/>
        <b>Note:</b> The <kbd>Scope</kbd> field - is the hotkey's scope. For example, if you specify <kbd>CabinetWClass</kbd> here, the hotkey will only work in the FileExplorer window.
      </div>

      <For each={hotkeyDisabled()}>
      {(item, index) =>
        <HotkeyDisabled
          item={item} 
          index={index() + 1}
          deleteEvent={deleteEvent}
          toggleEnableEvent={toggleEnableEvent} 
          hotkeyChangeEvent={hotkeyChangeEvent}
        />
      }
      </For>

      <Show when={isShowAddForm()}>
        <AddHotkeyDisabled 
          addDisabledHotkeySubmitEvent={addDisabledHotkeySubmitEvent} 
        />
      </Show>
    
      <Button class='mb-4' style={{ "margin-right": "auto", "display": "block" }} variant="success" onClick={addDisabledHotkeyEvent}>Add Disabled hotkey</Button>


    </>

  )

}


export default HotkeysDisabled


