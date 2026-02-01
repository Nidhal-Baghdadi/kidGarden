document.addEventListener("turbo:load", () => {
  const container = document.getElementById("messages-container");
  if (!container) return;

  if (container.dataset.autoscroll === "true") {
    container.scrollTop = container.scrollHeight;
  }
});
