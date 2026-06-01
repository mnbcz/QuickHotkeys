
import { createSignal, createEffect, For, onMount } from "solid-js";
import { Button, Modal } from "solid-bootstrap";

import Hotkey from "./Hotkey";
import { data, defaultData } from "../App"


/**
 * Возвращает массив из трёх элементов: 
 * 1. Нормализованную строку, в правильном порядке модификаторов - LCtrl+LShift+q
 * 2. Модификаторы - <+<^
 * 3. Клавиша - q.
 * @param {string} hotkeyStr - Строка хоткея "Shift + Ctrl + q".
 * Можно использовать модификаторы ^+q, но тогда порядок модификаторов 
 * будет таким как указан.
 */
function parseHotkeyString(hotkeyStr) {

  let hotkeySymbolReplaceMap = {
    "LCtrl": "<^",
    "Ctrl": "^",
    "RCtrl": ">^",

    "LShift": "<+",
    "Shift": "+",
    "RShift": ">+",

    "LAlt": "<!",
    "Alt": "!",
    "RAlt": ">!",

    "LWin": "<#",
    "Win": "#",
    "RWin": ">#",
  }

  // Убираем все пробелы
  hotkeyStr = hotkeyStr.replace(/ /gi, '')
  // Заменяем + на |
  hotkeyStr = hotkeyStr.replace(/\+/gi, '|')

  // Строим строку с правильным следованием Ctrl, Shift. 
  // В том порядке, в котором они определены в массиве. 

  // Массив модификаторов.
  // {lCtrl: "<^", ...}
  let modObj = {}

  // Перебираем карту, и добавляем модификаторы в массив
  Object.keys(hotkeySymbolReplaceMap).forEach(function (key, index) {
    const regex = new RegExp(key, "i")
    let modMatchResult = hotkeyStr.match(regex)
    if (modMatchResult) {
      // В строке, в поле, есть модификатор, типа LCtrl.
      modObj[key] = hotkeySymbolReplaceMap[key]
      // Убираем найденный модификатор из строки
      const regex = new RegExp(key + "[\|]*", "i")
      hotkeyStr = hotkeyStr.replace(regex, "")
    }
  });

  // Убираем все символы | из строки
  // key - например клавиша - q, Tab, или пустая строка.
  let key = hotkeyStr.replace(/\|/gi, "")
  // Строка модификаторов.
  let hotkeyModStr = Object.values(modObj).join("")
  // Строка хоткея с плюсами. LCtrl+LWin.
  let hotkeyDisplayStr = Object.keys(modObj).join("+")
  if (key) {
    if (hotkeyDisplayStr == "") {
      hotkeyDisplayStr = key
    } else {
      hotkeyDisplayStr += "+" + key
    }
  }
  return [hotkeyDisplayStr, hotkeyModStr, key]
}


// Массив хоткеев
const [hotkeys, setHotkeys] = createSignal([])

function HotkeyList() {

  // Modal Select Key
  const [showModal, setShowModal] = createSignal(false);
  // Текст сообщения
  const [modalText, setModalText] = createSignal("");

  // Открывает Модал
  const openModal = (text = false) => {
    setShowModal(true)
    if (text) {
      setModalText(text)
    }
  }

  // Закрывает Модал
  const closeModal = async () => {
    setShowModal(false)
    // // Отправляем запрос Ahk чтобы завершить ожидать нажатие клавиши
    // let ahk = await window.chrome.webview.hostObjects.ahk;
    // ahk.stopAnyKey()
  }


  /** Такой хоткей уже существует?, в состоянии. 
  testHotkey - тестируемый хоткей.
  Если такаого хоткей ещё не существует, возвращает false.
  Возвращает item хоткей, если уже существует.
  И добавляет свойство index - номер хоткея в списке, на странице.
  */
  function isHotkeyExist(testHotkey) {
    // Проверяем не совпал ни такой хоткей с уже установленным
    let itemList = hotkeys()
    // Перебираем все хоткеи.
    // Ищем совпадающий хоткей, с теми же клавишами.
    for (const [index, item] of Object.entries(itemList)) {

      if (item.id === testHotkey.id) {
        // Пропускаем если это активный хоткей
        continue
      }

      // Пропускаем если нет такого свойства
      if (!item.hotkeyDisplay || !testHotkey.hotkeyDisplay) {
        continue
      }

      if (item.hotkeyDisplay.toLowerCase() === testHotkey.hotkeyDisplay.toLowerCase()
        && item.scope && testHotkey.scope && item.scope.toLowerCase() === testHotkey.scope.toLowerCase()) {
        // index - это номер id хоткея, который отображается на странице.
        item.index = parseInt(index) + 1
        return item
      }

    }

    return false
  }


  /**
   * Текст в поле хоткея изменён. Стартуется эта функция.
   * Проверяет что такого хоткея ещё нет.
   * Обновляет в ahk состояние хоткеев.
   * @param {*} id 
   * @param {*} event 
   */
  const hotkeyChangeEvent = async (id, event) => {
    // alert(e.target.value + ", this = " + id)
    // return
    // Новый хоткей
    let newHotkey = {}
    // Предыдущий хоткей
    let prevHotkey = {}

    let itemList = hotkeys()
    for (const item of itemList) {
      // Находим хоткей зная id хоткея, в состоянии.
      if (item.id == id) {
        prevHotkey = item
        let [hotkeyDisplay, hotkeyModifiers, sc] = parseHotkeyString(event.target.value)
        if (item.type == "mod&key") {
          // Новое значение хоткея
          newHotkey = {
            ...item,
            hotkeyDisplay: hotkeyDisplay,
            hotkeyModifiers,
            sc: (sc == "") ? item.sc : sc
          }
        } else if (item.type == "key&key") {
          newHotkey = {
            ...item,
            hotkeyDisplay: event.target.value,
            hotkeyModifiers: event.target.value
          }
        } else {
          newHotkey = {
            ...item,
            hotkeyDisplay: hotkeyDisplay,
            hotkeyModifiers,
          }
        }

        break
      }
    }

    let item = isHotkeyExist(newHotkey)

    if (item === false) {
      // Такого хоткея ещё нет.
      let ahk = await window.chrome.webview.hostObjects.ahk;
      // sc10
      // Получаем sc код клавиши.
      newHotkey.sc = await ahk.getScKey(newHotkey.sc);
      setHotkeys(hotkeys().map((item) => (
        item.id !== id ? item : newHotkey
      )));
      sendToAhk_updateHotkey(id)
    } else {
      // Такой хоткей уже существует.
      // Устанавливаем в поле прежднее значение.
      event.target.value = prevHotkey.hotkeyDisplay
      setModalText("This hotkey \"" + item.index +
        ". " + item.title +
        "\" already exists.")
      setShowModal(true)
    }
  }


  // Вызывается когда изменяется значение в списке.
  const selectEvent = async (id, event) => {

    // alert(event.target.value + ", this = " + id)
    // return
    // Новый хоткей
    let newHotkey = {}

    let itemList = hotkeys()
    for (const item of itemList) {
      // Находим хоткей в состоянии, зная id хоткея.
      if (item.id == id) {
        newHotkey = {
          ...item
        }
        newHotkey.list.value = event.target.value
        break
      }
    }

    // console.log(newHotkey)

    // Устанавливаем состояние хоткеев.
    setHotkeys(hotkeys().map((item) => (
      item.id !== id ? item : newHotkey
    )));

    sendToAhk_updateHotkey(id)

  }

  // TEST
  // window.main_fromAhk_ResponseToSelectKey = fromAhk_ResponseToSelectKey


  /**
   * Отмечен переключатель - включить/отключить хоткей.
   * Вызывается этот метод.
   * Обновляет хоткей в ahk.
   **/
  const toggleEnableEvent = (id) => {
    setHotkeys(hotkeys().map((item) => (
      item.id !== id ? item : { ...item, isEnable: !item.isEnable }
    )));
    sendToAhk_updateHotkey(id)
  }


  // TEST
  /**
   * Обновляет состояние хоткеев в ahk, состоянием отсюда.
   * Устанавливает Hotkey().
   * @param {string} id Id хоткея, который нужно обновить.  
   */
  async function sendToAhk_updateHotkey(id) {
    let ahk = await window.chrome.webview.hostObjects.ahk;
    let hotkeysStr = JSON.stringify(hotkeys());
    ahk.updateHotkey(hotkeysStr, id);
  }


  /**
   * Устанавливает состояние хоткеев, и ahk.hotkeys.
   * Вызывается один раз при монтировании.
   */
  onMount(async () => {
    let ahk = await window.chrome.webview.hostObjects.ahk;
    let hotkeysStr = await ahk.hotkeys;
    let hotkeysObj = await JSON.parse(hotkeysStr);
    setHotkeys(hotkeysObj);

    // TEST
    // setHotkeys(data);
  });


  return (
    <>
      <Modal show={showModal()} onHide={closeModal}>

        <Modal.Header closeButton>
          <Modal.Title>Warning</Modal.Title>
        </Modal.Header>

        <Modal.Body>
          {modalText()}
        </Modal.Body>

        <Modal.Footer>
          <Button variant="secondary" onClick={closeModal}>Close</Button>
        </Modal.Footer>

      </Modal>

      <For each={hotkeys()}>
        {(item, index) =>

          <Hotkey
            item={item}
            index={index() + 1}
            toggleEnableEvent={toggleEnableEvent}
            hotkeyChangeEvent={hotkeyChangeEvent}
            selectEvent={selectEvent}

          />
        }
      </For>

    </>

  )

}


export default HotkeyList

export {
  hotkeys,
  setHotkeys
};

