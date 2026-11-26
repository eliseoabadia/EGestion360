(function () {
    const storageKey = 'egestion360.sidebar.width';
    const defaultWidth = 320;
    let disposeCurrent = null;
    function readVariable(root, name, fallback) {
        const value = Number.parseInt(getComputedStyle(root).getPropertyValue(name), 10);
        return Number.isFinite(value) ? value : fallback;
    }
    function persist(width) {
        try { localStorage.setItem(storageKey, String(Math.round(width))); }
        catch (error) { console.debug('No se pudo guardar el ancho del menú.', error); }
    }
    function initialize() {
        disposeCurrent?.();
        const root = document.querySelector('.layout-root');
        const sidebar = root?.querySelector('.sidebar-container');
        const handle = root?.querySelector('.sidebar-resize-handle');
        if (!root || !sidebar || !handle) return;
        root.classList.remove('sidebar-resizing');
        const min = readVariable(root, '--eg-sidebar-min-width', 260);
        const max = readVariable(root, '--eg-sidebar-max-width', 420);
        const setWidth = value => {
            const width = Math.min(Math.max(Math.round(value), min), max);
            root.style.setProperty('--eg-sidebar-width', `${width}px`);
            return width;
        };
        try {
            const stored = Number.parseInt(localStorage.getItem(storageKey), 10);
            setWidth(Number.isFinite(stored) ? stored : defaultWidth);
        } catch (error) { setWidth(defaultWidth); console.debug('No se pudo leer el ancho del menú.', error); }
        let pointer = null, startX = 0, startWidth = 0, nextX = 0, frame = 0, dragging = false;
        const canResize = () => !sidebar.classList.contains('collapsed') && window.innerWidth >= 960;
        const flushWidth = () => {
            frame = 0;
            if (pointer !== null && dragging) setWidth(startWidth + nextX - startX);
        };
        const stopResize = () => {
            const id = pointer;
            if (frame) { cancelAnimationFrame(frame); frame = 0; }
            if (id !== null && dragging) setWidth(startWidth + nextX - startX);
            pointer = null;
            const shouldPersist = dragging;
            dragging = false;
            // Limpiar siempre, incluso tras blur, perdida de captura o reinicializacion.
            root.classList.remove('sidebar-resizing');
            if (id !== null && handle.hasPointerCapture?.(id)) handle.releasePointerCapture(id);
            if (shouldPersist) persist(sidebar.getBoundingClientRect().width);
        };
        const onDown = event => {
            if (event.button !== 0 || !canResize()) return;
            stopResize();
            event.preventDefault();
            pointer = event.pointerId;
            startX = nextX = event.clientX;
            startWidth = sidebar.getBoundingClientRect().width;
            handle.setPointerCapture?.(pointer);
        };
        const onMove = event => {
            if (pointer !== event.pointerId) return;
            if ((event.buttons & 1) === 0 || !canResize()) { stopResize(); return; }
            nextX = event.clientX;
            if (!dragging && Math.abs(nextX - startX) < 3) return;
            dragging = true;
            root.classList.add('sidebar-resizing');
            if (!frame) frame = requestAnimationFrame(flushWidth);
        };
        const onUp = event => { if (pointer === event.pointerId) stopResize(); };
        const onVisibility = () => { if (document.hidden) stopResize(); };
        const onEscape = event => { if (event.key === 'Escape') stopResize(); };
        const onKeys = event => {
            if (!canResize()) return;
            const current = sidebar.getBoundingClientRect().width;
            const step = event.shiftKey ? 32 : 12;
            const values = { ArrowLeft: current - step, ArrowRight: current + step, Home: min, End: max };
            if (!Object.hasOwn(values, event.key)) return;
            event.preventDefault();
            persist(setWidth(values[event.key]));
        };
        const onDoubleClick = () => { if (canResize()) persist(setWidth(defaultWidth)); };
        handle.addEventListener('pointerdown', onDown);
        handle.addEventListener('lostpointercapture', stopResize);
        handle.addEventListener('keydown', onKeys);
        handle.addEventListener('dblclick', onDoubleClick);
        window.addEventListener('pointermove', onMove);
        window.addEventListener('pointerup', onUp);
        window.addEventListener('pointercancel', onUp);
        window.addEventListener('blur', stopResize);
        window.addEventListener('pagehide', stopResize);
        window.addEventListener('resize', stopResize);
        window.addEventListener('keydown', onEscape);
        document.addEventListener('visibilitychange', onVisibility);
        disposeCurrent = () => {
            stopResize();
            handle.removeEventListener('pointerdown', onDown);
            handle.removeEventListener('lostpointercapture', stopResize);
            handle.removeEventListener('keydown', onKeys);
            handle.removeEventListener('dblclick', onDoubleClick);
            window.removeEventListener('pointermove', onMove);
            window.removeEventListener('pointerup', onUp);
            window.removeEventListener('pointercancel', onUp);
            window.removeEventListener('blur', stopResize);
            window.removeEventListener('pagehide', stopResize);
            window.removeEventListener('resize', stopResize);
            window.removeEventListener('keydown', onEscape);
            document.removeEventListener('visibilitychange', onVisibility);
            disposeCurrent = null;
        };
    }
    window.egestionSidebarResize = { initialize, dispose() { disposeCurrent?.(); } };
})();