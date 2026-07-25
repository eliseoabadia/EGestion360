(function () {
    const storageKey = "egestion360.sidebar.width";
    const defaultWidth = 320;
    const fallbackMin = 260;
    const fallbackMax = 420;
    let disposeCurrent = null;

    function getRoot() {
        return document.querySelector(".layout-root");
    }

    function readPixelVariable(root, name, fallback) {
        const value = getComputedStyle(root).getPropertyValue(name).trim();
        const parsed = Number.parseInt(value, 10);
        return Number.isFinite(parsed) ? parsed : fallback;
    }

    function clamp(value, min, max) {
        return Math.min(Math.max(value, min), max);
    }

    function setWidth(root, value, persist) {
        const min = readPixelVariable(root, "--eg-sidebar-min-width", fallbackMin);
        const max = readPixelVariable(root, "--eg-sidebar-max-width", fallbackMax);
        const width = clamp(Math.round(value), min, max);

        root.style.setProperty("--eg-sidebar-width", `${width}px`);

        if (persist) {
            localStorage.setItem(storageKey, String(width));
        }

        return width;
    }

    function getCurrentWidth(root, sidebar) {
        const measured = sidebar.getBoundingClientRect().width;
        if (Number.isFinite(measured) && measured > 0) {
            return measured;
        }

        return readPixelVariable(root, "--eg-sidebar-width", defaultWidth);
    }

    function applyStoredWidth(root) {
        const stored = Number.parseInt(localStorage.getItem(storageKey) || "", 10);

        if (Number.isFinite(stored)) {
            setWidth(root, stored, false);
            return;
        }

        setWidth(root, defaultWidth, false);
    }

    function initialize() {
        if (disposeCurrent) {
            disposeCurrent();
        }

        const root = getRoot();
        const sidebar = root?.querySelector(".sidebar-container");
        const handle = root?.querySelector(".sidebar-resize-handle");

        if (!root || !sidebar || !handle) {
            return;
        }

        applyStoredWidth(root);

        let activePointerId = null;
        let startX = 0;
        let startWidth = 0;

        const stopResize = () => {
            if (activePointerId === null) {
                return;
            }

            activePointerId = null;
            root.classList.remove("sidebar-resizing");
            localStorage.setItem(storageKey, String(Math.round(getCurrentWidth(root, sidebar))));
        };

        const onPointerMove = (event) => {
            if (activePointerId !== event.pointerId) {
                return;
            }

            setWidth(root, startWidth + event.clientX - startX, false);
        };

        const onPointerUp = (event) => {
            if (activePointerId !== event.pointerId) {
                return;
            }

            stopResize();
        };

        const onPointerDown = (event) => {
            if (event.button !== 0 || sidebar.classList.contains("collapsed")) {
                return;
            }

            event.preventDefault();
            activePointerId = event.pointerId;
            startX = event.clientX;
            startWidth = getCurrentWidth(root, sidebar);
            root.classList.add("sidebar-resizing");
            handle.setPointerCapture?.(event.pointerId);
        };

        const onKeyDown = (event) => {
            if (sidebar.classList.contains("collapsed")) {
                return;
            }

            const current = getCurrentWidth(root, sidebar);
            let next = null;

            if (event.key === "ArrowLeft") {
                next = current - (event.shiftKey ? 32 : 12);
            } else if (event.key === "ArrowRight") {
                next = current + (event.shiftKey ? 32 : 12);
            } else if (event.key === "Home") {
                next = readPixelVariable(root, "--eg-sidebar-min-width", fallbackMin);
            } else if (event.key === "End") {
                next = readPixelVariable(root, "--eg-sidebar-max-width", fallbackMax);
            }

            if (next === null) {
                return;
            }

            event.preventDefault();
            setWidth(root, next, true);
        };

        const onDoubleClick = () => {
            if (!sidebar.classList.contains("collapsed")) {
                setWidth(root, defaultWidth, true);
            }
        };

        handle.addEventListener("pointerdown", onPointerDown);
        handle.addEventListener("keydown", onKeyDown);
        handle.addEventListener("dblclick", onDoubleClick);
        window.addEventListener("pointermove", onPointerMove);
        window.addEventListener("pointerup", onPointerUp);
        window.addEventListener("pointercancel", stopResize);

        disposeCurrent = () => {
            stopResize();
            handle.removeEventListener("pointerdown", onPointerDown);
            handle.removeEventListener("keydown", onKeyDown);
            handle.removeEventListener("dblclick", onDoubleClick);
            window.removeEventListener("pointermove", onPointerMove);
            window.removeEventListener("pointerup", onPointerUp);
            window.removeEventListener("pointercancel", stopResize);
            disposeCurrent = null;
        };
    }

    window.egestionSidebarResize = {
        initialize,
        dispose: function () {
            if (disposeCurrent) {
                disposeCurrent();
            }
        }
    };
})();
