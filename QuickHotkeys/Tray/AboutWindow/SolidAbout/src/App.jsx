import { createEffect, onMount, createSignal } from "solid-js";


// const data = {
//     appName: "Screen Keyboard",
//     currentVersion: "v.1.2",
//     // newVersion: "v1.3",
//     newVersion: "",
//     // newVersion: false,
//     downloadUrl: "http://download.com",
//     siteUrl: "http://site.com",
//     email: "mnbczmnbcz@gmail.com",
//     youtubeUrl: "youtube.com"
// }

function getActiveYear(){
  return new Date().getFullYear()
}


function App() {

  const [items, setItems] = createSignal({});

  let ahk

  onMount(async () => {
    ahk = await window.chrome.webview.hostObjects.ahk;
    let itemsStr = await ahk.items;
    let itemsObj = await JSON.parse(itemsStr);
    setItems(itemsObj);

    // setItems(data);
  });

  // createEffect(async () => {
  //     addListenerToLinks()
  // });

  onMount(() => {

    setTimeout(addListenerToLinks, 1000)
    // addListenerToLinks()
  });


  const closeHdl = (event) => {
    event.preventDefault()
    ahk.close()
  }


  const hrefClick = (event) => {
    event.preventDefault()
    ahk.hrefClick(event.target.href)
  }


  /** На все ссылки назначает обработчик. */
  function addListenerToLinks() {
    var links = document.getElementsByTagName("a");
    for (var i = 0; i < links.length; i++) {
      if (links[i].id == 'close') {
        continue
      }
      links[i].addEventListener("click", hrefClick);
    }
  }


  return (
    <>
      <div class="wrapAll">
        <main>
          <a id="close" onclick={closeHdl}></a>
          <div class="row">
            <h3>{items().appName} {items().currentVersion}</h3>
          </div>

          <ul>

            {items().newVersion !== items().currentVersion ?
              <li class="row green">
                New version {items().newVersion} available,
                {" "}<a href={items().newVersionUrl}>Download</a>
              </li>
              :
              <li>Is up to date</li>
            }

            <li class="row">
              <b>Website:</b> <a href={items().newVersionUrl}>{items().newVersionUrl}</a>
            </li>

            {items().youtubeUrl ?
              <li class="row">
                <a href={items().youtubeUrl}>YouTube Tutorial</a>
              </li>
              : ""
            }


            {items().email ?
              <li class="row">
                <b>Developer team:</b> <a href={"mailto:" + items().email}>{items().email}</a>
              </li>
              : ""
            }

          </ul>

        </main>


        <footer>Copyright © {getActiveYear()}</footer>

      </div>

    </>
  );

}

export default App;
