window.egDialogDrag = (function () {
    const dragHandleSelector = ".mud-dialog-title";
    const dialogSelector = ".mud-dialog";
    const interactiveSelector = "button, a, input, textarea, select, label, .mud-button-root, .mud-icon-button, .mud-input-control";
    const crudDialogSelector = ".mud-dialog.crud-dialog";
    const formFieldSelector = [
        ".entity-form-content > .mud-grid > .mud-grid-item",
        ".entity-form-content > .mud-grid > [class*='mud-grid-item']",
        ".entity-form-content > .eg-form-loading-state > .mud-grid > .mud-grid-item",
        ".entity-form-content > .eg-form-loading-state > .mud-grid > [class*='mud-grid-item']"
    ].join(", ");
    let observer;

    function isSmallViewport() {
        return window.matchMedia("(max-width: 640px)").matches;
    }

    function clamp(value, min, max) {
        return Math.min(Math.max(value, min), max);
    }

    function clampDialog(dialog) {
        const rect = dialog.getBoundingClientRect();
        const padding = 8;
        const maxLeft = Math.max(padding, window.innerWidth - rect.width - padding);
        const maxTop = Math.max(padding, window.innerHeight - rect.height - padding);

        dialog.style.left = `${clamp(rect.left, padding, maxLeft)}px`;
        dialog.style.top = `${clamp(rect.top, padding, maxTop)}px`;
    }

    function prepareDialogForDrag(dialog) {
        const rect = dialog.getBoundingClientRect();

        dialog.classList.add("eg-draggable-dialog");
        dialog.style.position = "fixed";
        dialog.style.left = `${rect.left}px`;
        dialog.style.top = `${rect.top}px`;
        dialog.style.right = "auto";
        dialog.style.bottom = "auto";
        dialog.style.margin = "0";
        dialog.style.transform = "none";
        dialog.style.width = `${rect.width}px`;
    }

    function onPointerDown(event) {
        if (event.button !== 0 || isSmallViewport()) {
            return;
        }

        if (event.target.closest(interactiveSelector)) {
            return;
        }

        const handle = event.currentTarget;
        const dialog = handle.closest(dialogSelector);
        if (!dialog) {
            return;
        }

        prepareDialogForDrag(dialog);

        const startX = event.clientX;
        const startY = event.clientY;
        const startRect = dialog.getBoundingClientRect();

        dialog.classList.add("eg-dialog-dragging");
        handle.setPointerCapture?.(event.pointerId);
        event.preventDefault();

        function onPointerMove(moveEvent) {
            const nextLeft = startRect.left + moveEvent.clientX - startX;
            const nextTop = startRect.top + moveEvent.clientY - startY;
            const padding = 8;
            const maxLeft = Math.max(padding, window.innerWidth - startRect.width - padding);
            const maxTop = Math.max(padding, window.innerHeight - startRect.height - padding);

            dialog.style.left = `${clamp(nextLeft, padding, maxLeft)}px`;
            dialog.style.top = `${clamp(nextTop, padding, maxTop)}px`;
        }

        function onPointerUp(upEvent) {
            dialog.classList.remove("eg-dialog-dragging");
            handle.releasePointerCapture?.(upEvent.pointerId);
            window.removeEventListener("pointermove", onPointerMove);
            window.removeEventListener("pointerup", onPointerUp);
            window.removeEventListener("pointercancel", onPointerUp);
        }

        window.addEventListener("pointermove", onPointerMove);
        window.addEventListener("pointerup", onPointerUp);
        window.addEventListener("pointercancel", onPointerUp);
    }

    function attachDialog(dialog) {
        applyCrudDialogSizing(dialog);

        const handle = dialog.querySelector(dragHandleSelector);
        if (!handle || handle.dataset.egDialogDrag === "true") {
            return;
        }

        handle.dataset.egDialogDrag = "true";
        handle.classList.add("eg-dialog-drag-handle");
        handle.addEventListener("pointerdown", onPointerDown);
    }

    function applyCrudDialogSizing(dialog) {
        if (!dialog.matches(crudDialogSelector)) {
            return;
        }

        const fieldCount = dialog.querySelectorAll(formFieldSelector).length;
        dialog.classList.toggle("crud-dialog-wide", fieldCount >= 7);
        dialog.classList.toggle("crud-dialog-wide-xl", fieldCount >= 11);
        dialog.classList.toggle("crud-dialog-wide-xxl", fieldCount >= 16);
    }

    function attachAll() {
        document.querySelectorAll(dialogSelector).forEach(attachDialog);
    }

    function init() {
        attachAll();

        if (!observer) {
            observer = new MutationObserver(attachAll);
            observer.observe(document.body, { childList: true, subtree: true });
            window.addEventListener("resize", () => {
                attachAll();
                document.querySelectorAll(".eg-draggable-dialog").forEach(clampDialog);
            });
        }
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", init, { once: true });
    } else {
        init();
    }

    return { init };
})();
