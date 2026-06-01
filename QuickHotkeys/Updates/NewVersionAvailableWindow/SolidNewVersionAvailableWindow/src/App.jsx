import { createEffect, onMount, createSignal } from "solid-js";
import { Button } from "solid-bootstrap";



// let Config = {
//     appName: "ScreenCast Keyboard",
//     currentVersion: "v1.2",
//     newVersion: "v1.3",
//     newVersionUrl: "https://github.com/mnbcz/ScreenCast-Keyboard/releases",
//     downloadUrl: "https://github.com/mnbcz/ScreenCast-Keyboard/archive/refs/tags/v1.2.zip",
//     siteUrl: "https://github.com/mnbcz/ScreenCast-Keyboard/releases",
//     email: "mnbczmnbcz@gmail.com",
//     youtubeUrl: "youtube.com",
   
// }



function App() {

    const [items, setItems] = createSignal({});

    let ahk

    // Вызывается один раз при монтировании.
    onMount(async () => {
        ahk = await window.chrome.webview.hostObjects.ahk;
        let itemsStr = await ahk.items;
        let itemsObj = await JSON.parse(itemsStr);
        setItems(itemsObj);

        // setItems(Config);
        // alert("onMount")

    });


    // Вызывается при изменении состояния, перерендеринге. 
    createEffect(async () => {
        // alert("createEffect")
        addListenerToLinks()
    });


    // Нажатие на кнопку закрыть
    const closeHdl = async () => {
        ahk.close()
    }


    // Нажатие на кнопку Зарегистрировать.
    const closeButtonHdl = () => {
        ahk.close()
    }


    function hrefClick(event){
        event.preventDefault()
        ahk.hrefClick(event.target.href)
    }


    /** На все ссылки назначает обработчик. */
    function addListenerToLinks() {

        var links = document.getElementsByTagName("a");

        for (var i = 0; i < links.length; i++) {
            links[i].addEventListener("click", hrefClick);
        }

    }


    return (
    <>

        <div class="wrapAll">

            <main>

                <a id="close" onclick={closeHdl}></a>

                <div class="header">{items().appName} {items().currentVersion}</div>


                <ul>

                    <li class="green">
                        New version {items().newVersion} available, {" "}
                        <a href={items().newVersionUrl}>Download</a>
                    </li>
                    
                    <li class="green">
                        <a href={items().newVersionUrl}>What's new?</a>
                    </li>

                </ul>

            </main>


            <footer>
                <Button variant="primary" class="sendButton" onclick={closeButtonHdl}>
                       Close    
                </Button>
                {/* <div>Copyright © 2024</div> */}
            </footer>

        </div>

    </>
    );

}

export default App;
