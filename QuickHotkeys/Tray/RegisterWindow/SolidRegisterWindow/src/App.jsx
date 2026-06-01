import { createEffect, onMount, createSignal } from "solid-js";
import { Form, Button } from "solid-bootstrap";


// const data = {
//     appName: "Screen Keyboard",
//     currentVersion: "v.1.2",
//     newVersion: "v1.3",
//     // newVersion: false,
//     downloadUrl: "http://download.com",
//     siteUrl: "http://site.com",
//     email: "mnbczmnbcz@gmail.com",
//     youtubeUrl: "youtube.com"
// }



function App() {

    const [items, setItems] = createSignal({});
    const [error, setError] = createSignal("");
    const [isLoading, setIsLoading] = createSignal(false);
    const [isRegistered, setIsRegistered] = createSignal(false);

    let ahk

    // Вызывается один раз при монтировании.
    onMount(async () => {
        ahk = await window.chrome.webview.hostObjects.ahk;
        let itemsStr = await ahk.items;
        // itemsStr = await JSON.parse(itemsStr);
        let itemsObj = await JSON.parse(itemsStr);
        setItems(itemsObj);
    });


    // Вызывается при изменении состояния, перерендеринге. 
    createEffect(async () => {

        // Выполняется один раз при загрузке
        if (Object.keys(items()).length == 0) {
            // ahk = await window.chrome.webview.hostObjects.ahk;
            // let itemsStr = await ahk.items;
            // itemsStr = await JSON.parse(itemsStr);
            // let itemsObj = await JSON.parse(itemsStr);
            // setItems(itemsObj);

            // let obj = {
            //     appName: "Screen Keyboard",
            //     urlToBy: "test.com",
            //     message: "It looks like the Internet is disconnected. Check your internet connection and try again.",
            // }
            // setItems(obj);

        } 

        addListenerToLinks()

    });


    // Нажатие на кнопку закрыть
    const closeHdl = async () => {
        // let ahk = await window.chrome.webview.hostObjects.ahk;
        ahk.close()
    }


    // Нажатие на кнопку Зарегистрировать.
    const registerButtonHdl = () => {

        // Если запрос отправлен, но ответ ещё не получен
        if(isLoading()){
            return
        }

        let key = document.getElementById("key").value.trim()
        if(!key){
            setError("Field cannot be empty")
            return
        }else{
            setError("")
            setItems({...items(), message: ""});
            setIsLoading(true)
            ahk.sendKey(key)
        }
    }


    // {message: "✓ Registered", isRegistered: true}
    // Вызывается Ahk. В ответ на кнопку Зарегистрировать.
    const fromAhk = (responseStr = "") => {

        let responseObj = JSON.parse(responseStr)
        alert(responseObj)
        setItems({...items(), ...responseObj});

        if(responseObj.isRegistered){
            setIsRegistered(true)
        }else{
            setIsLoading(false)
        }

    }

    fromAhkMain = fromAhk


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

                <div class="header">{items().appName}</div>

                {!isRegistered() ? 

                <>

                    <Form.Label htmlFor="key">Registration key</Form.Label>

                    
                    <Form.Control
                        type="text"
                        id="key"
                        maxLength={100}
                    />


                    {error() ?
                        <Form.Text id="keyError">
                        {error()}
                        </Form.Text>
                        : ""
                    }
                    
                    <Button variant="primary" class="sendButton" onclick={registerButtonHdl}>
                        {isLoading() ? 
                            <div class="lds-dual-ring"></div>
                            : "Register"
                        }
                        
                    </Button>

                </>
                : ""
                }

                {/* https://docs.solidjs.com/ */}
                {items().message?
                    <div class="green" innerHTML={items().message} />
                    : ""
                }

            </main>


            <footer>
                <div class="textOnBottom">Don't have the key? Get it <a href={items().urlToBy}>here</a>.</div>
                {/* <div>Copyright © 2024</div> */}
            </footer>

        </div>

    </>
    );

}

export default App;
