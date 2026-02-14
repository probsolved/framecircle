document.addEventListener("click", (e) => {
  const trigger = e.target.closest("[data-photo-lightbox]");
  if (!trigger) return;

  e.preventDefault();

  const fullUrl = trigger.getAttribute("data-full-url");
  if (!fullUrl) return;

  const img = document.getElementById("photoLightboxImg");
  img.src = fullUrl;

  const el = document.getElementById("photoLightbox");

  // Bootstrap 5 may expose Modal either globally or as window.bootstrap
  const Modal = window.bootstrap?.Modal || window.Modal;
  if (!Modal) {
    console.error("Bootstrap Modal not available. Check importmap bootstrap pin/import.");
    return;
  }

  const modal = Modal.getOrCreateInstance(el);
  modal.show();
});
