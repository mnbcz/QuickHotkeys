import { createSignal } from "solid-js";
import { Button, Modal } from "solid-bootstrap";



// Использование:
// let text = "Reset to default hotkeys?"
// showConfirmModal(text, choseEvent)
// function choseEvent(isOk){
//     // alert(isOk)
//     if(isOk){
//         
//     }
// }


// ===============================================================
// Modal Ok, Cancel

const [modalOkCancel, setModalOkCancel] = createSignal({
    isShow: false,
    text: "",
    choseEvent: {}
})

// Вызывается кнопкой
function modalOkCancel_chose(isOk){
    // Вызываем колбэк
    modalOkCancel().choseEvent(isOk)
    // Закрываем окно
    setModalOkCancel({
        isShow: false,
        text: "",
        choseEvent: {}
    })    
}

// Открывает модал, и ждёт нажатия кнопки Ok, Cancel
// Если нажато, вызывает функцию choseEvent,
// которая аргументом принимает isOk.
function showConfirmModal(text, choseEvent){
    setModalOkCancel({
        isShow: true,
        text: text,
        choseEvent: choseEvent
    })
}


// ===============================================================




function ConfirmModal() {
    

    return (
        
        <Modal show={modalOkCancel().isShow} onHide={() => modalOkCancel_chose(false)}>

            <Modal.Header closeButton>
                {/* <Modal.Title>Text</Modal.Title> */}
            </Modal.Header>

            <Modal.Body>
                {modalOkCancel().text}
            </Modal.Body>

            <Modal.Footer>
                
                <Button variant="secondary" onClick={() => modalOkCancel_chose(false)}>Cancel</Button>
                <Button variant="primary" onClick={() => modalOkCancel_chose(true)}>OK</Button>
            </Modal.Footer>

        </Modal>

        
    )
}

export default ConfirmModal;
export {
    showConfirmModal
};

