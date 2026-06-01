import { createSignal, createEffect, For, onMount } from "solid-js";
import { FormCheck, Form, FormControl, InputGroup, Button, Modal } from "solid-bootstrap";


function AddHotkeyDisabled(props) {

  return (
    <div class="hotkeyDiv">
      <form id="addAliasForm" onSubmit={props.addDisabledHotkeySubmitEvent}>

        <div class="title_div">
          Title:
          <input
            class="hotkeyAlias"
            type="text"
            id="addHotkeyDisabled_title"
            style="width: 400px"
            maxLength="100"
          />
        </div>

        <div class='modsContainer'>
          <input
            class="hotkeyAlias"
            type="text"
            id="addHotkeyDisabled"
            name="hotkeyDisplay"
            maxLength="100"
            placeholder="Hotkey to disable"
          />

          <span class='aliasArrow'>Scope:</span>
          <input
            class="hotkeyAlias"
            type="text"
            id="addHotkeyDisabled_scope"
            name="scope"
            maxLength="100"
            title="Ahk_class of the application for which to disable the hotkey"
          />

        </div>

        <Button type="submit" class='mt-4' style={{ "margin": "auto", "display": "block", "padding": "4px 200px" }} variant="success">Add</Button>

      </form>
    </div>
  )

}


export default AddHotkeyDisabled


