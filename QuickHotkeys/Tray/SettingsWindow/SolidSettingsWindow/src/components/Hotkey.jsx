import { createSignal, createEffect, For, onMount } from "solid-js";
import { FormCheck, Form, FormControl, InputGroup, Button, Modal } from "solid-bootstrap";
import { config, toAhk_openInFileExplorerHdl } from "../App"


function Hotkey(props) {
  return (
    <div class={props.item.isEnable ? "hotkeyDiv" : "hotkeyDiv hotkeyDiv_disable"}>

      <div class="title_div">
        <span class="title_inline">
          <span class="numberRow">{props.index}. </span>
          {props.item.title}
        </span>
      </div>

      <div class='desc' innerHTML={props.item.desc} />

      <Show when={props.item.list}>
        <label for="RButtonAndWheel_Select">{props.item.list.desc}: </label>
        {" "}
        <select name={props.item.function + "_Select"} id={props.item.function + "_Select"} class="selectList"
          onChange={[props.selectEvent, props.item.id]}
        >  
            <For each={props.item.list.items}>
              {(item, index) =>
                <option 
                  value={item.function}
                  selected={props.item.list.value == item.function ? "selected" : ""} 
                >
                  {item.display}
                </option>  
              }
            </For>
        </select>
      </Show>

      <div class='modsContainer'>

        <Show when={props.item.hotkeyDisplay}>
          <Form.Control
            // as="text"
            class="textkey"
            type="text"
            id={"hotkey-" + props.item.id}
            maxLength="100"
            value={props.item.hotkeyDisplay}
            onChange={[props.hotkeyChangeEvent, props.item.id]}
          // valueSc="testSc"
          />
        </Show>

        <Form.Check
          class='switch'
          type="switch"
          checked={props.item.isEnable ? "checked" : ""}
          onChange={[props.toggleEnableEvent, props.item.id]}
        />

      </div>

    </div>
  )

}



export default Hotkey