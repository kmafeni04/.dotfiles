// ==UserScript==
// @name        Fix web WhatsApp Notifications
// @description	Hits the notification button, once
// @version		1.0
// @namespace   https://web.whatsapp.com/
// @run-at document-idle
// @grant       none
// ==/UserScript==
(function () {
  "use strict";

  let waitForTheElement = setInterval(function () {
    const elements = document.getElementsByClassName("x1qlqyl8");
    for (let element of elements) {
      if (element.textContent.toLowerCase().includes("turn on")) {
        element.click();
        clearInterval(waitForTheElement);
        break;
      }
    }
  }, 500);
})();
