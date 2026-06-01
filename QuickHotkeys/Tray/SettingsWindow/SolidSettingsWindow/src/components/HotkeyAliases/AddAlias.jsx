import { createSignal, createEffect, For, onMount } from "solid-js";
import { FormCheck, Form, FormControl, InputGroup, Button, Modal } from "solid-bootstrap";


function AddAlias(props) {


  return (
    <div class="hotkeyDiv">
      <form id="addAliasForm" onSubmit={props.addAliasSubmitEvent}>
        <div class="title_div">
          Title:
          <input
            class="hotkeyAlias"
            type="text"
            id="addAlias_title"
            style="width: 400px"
            maxLength="100"
          />

        </div>

        <div class='modsContainer'>
          <input
            class="hotkeyAlias"
            type="text"
            id="addAlias_from"
            maxLength="100"
            placeholder="Hotkey"
          />
          <input
            class="hotkeyAlias"
            type="hidden"
            id="addAlias_from_hotkey"
            maxLength="100"
            placeholder="Hotkey"
          />
          <span class='aliasArrow'>➔</span>
          <input
            class="hotkeyAlias"
            type="text"
            id="addAlias_to"
            maxLength="100"
            placeholder="Alias"
          />
          <input
            class="hotkeyAlias"
            type="hidden"
            id="addAlias_to_hotkey"
            maxLength="100"
            placeholder="Alias"
          />
          <span class='aliasArrow'>Scope:</span>
          <input
            class="hotkeyAlias"
            type="text"
            id="addAlias_scope"
            maxLength="100"
          />

        </div>

        <Button type="submit" class='mt-4' style={{ "margin": "auto", "display": "block", "padding": "4px 200px" }} variant="success">Add</Button>

      </form>
    </div>
  )

}


export default AddAlias


