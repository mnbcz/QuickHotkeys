import { createSignal, createEffect, For, onMount } from "solid-js";
import { FormCheck, Form, FormControl, InputGroup, Button, Modal } from "solid-bootstrap";
import { config, toAhk_openInFileExplorerHdl } from "../../App"


function HotkeyAlias(props) {
  return (
    <div class={props.item.isEnable ? "hotkeyDiv" : "hotkeyDiv hotkeyDiv_disable"}>

      <div class="title_div">
        <span class="title_inline">
          <span class="numberRow">{props.index}.</span>
          {props.item.title}
        </span>
      </div>

      <div class='desc' innerHTML={props.item.desc} />

      <div class='modsContainer'>

        <Show when={props.item.hotkeyDisplay}>
          <input
            // as="text"
            class="hotkeyAlias"
            type="text"
            id={"hotkeyHotkey-" + props.item.id}
            maxLength="100"
            value={props.item.hotkeyDisplay}
            name="hotkeyDisplay"
            onChange={[props.hotkeyChangeEvent, props.item.id]}
          />
          <span class='aliasArrow'>➔</span>
          <input
            class="hotkeyAlias"
            type="text"
            id={"hotkeyAlias-" + props.item.id}
            maxLength="100"
            value={props.item.aliasDisplay}
            name="aliasDisplay"
            onChange={[props.hotkeyChangeEvent, props.item.id]}
          />
          <span class='aliasArrow'>Scope:</span>
          <input
            class="hotkeyAlias"
            type="text"
            id={"hotkeyAliasScope-" + props.item.id}
            maxLength="100"
            value={props.item.scope}
            name="scope"
            onChange={[props.hotkeyChangeEvent, props.item.id]}
          />
        </Show>

        <div class='switch'>

          <span class="delete" title="Delete">
            {/* <i class="bi bi-trash3-fill" onClick={[props.deleteEvent, props.item.id]}></i> */}
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-trash3-fill" viewBox="0 0 16 16" onClick={[props.deleteEvent, props.item.id]}>
              <path d="M11 1.5v1h3.5a.5.5 0 0 1 0 1h-.538l-.853 10.66A2 2 0 0 1 11.115 16h-6.23a2 2 0 0 1-1.994-1.84L2.038 3.5H1.5a.5.5 0 0 1 0-1H5v-1A1.5 1.5 0 0 1 6.5 0h3A1.5 1.5 0 0 1 11 1.5m-5 0v1h4v-1a.5.5 0 0 0-.5-.5h-3a.5.5 0 0 0-.5.5M4.5 5.029l.5 8.5a.5.5 0 1 0 .998-.06l-.5-8.5a.5.5 0 1 0-.998.06m6.53-.528a.5.5 0 0 0-.528.47l-.5 8.5a.5.5 0 0 0 .998.058l.5-8.5a.5.5 0 0 0-.47-.528M8 4.5a.5.5 0 0 0-.5.5v8.5a.5.5 0 0 0 1 0V5a.5.5 0 0 0-.5-.5"/>
            </svg>
          
          </span>

          <Form.Check
            type="switch"
            checked={props.item.isEnable ? "checked" : ""}
            onChange={[props.toggleEnableEvent, props.item.id]}
          />
        </div>

      </div>

    </div>
  )

}



export default HotkeyAlias


