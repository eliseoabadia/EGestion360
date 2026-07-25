window.egestionComboScroll = (() => {
    const observers = new WeakMap();

    function isElement(value) {
        return value instanceof Element || value?.nodeType === Node.ELEMENT_NODE;
    }

    function getScrollParent(element) {
        if (!isElement(element)) {
            return null;
        }

        let current = element?.parentElement;

        while (current) {
            const style = window.getComputedStyle(current);
            const canScroll = /(auto|scroll)/.test(style.overflowY);

            if (canScroll && current.scrollHeight > current.clientHeight) {
                return current;
            }

            current = current.parentElement;
        }

        return null;
    }

    function dispose(element) {
        if (!isElement(element)) {
            return;
        }

        const observer = observers.get(element);
        if (observer) {
            observer.disconnect();
            observers.delete(element);
        }
    }

    function observe(element, dotNetRef, methodName = "LoadNextPageFromScroll") {
        if (!isElement(element) || !dotNetRef) {
            return;
        }

        dispose(element);

        const observer = new IntersectionObserver((entries) => {
            if (entries.some((entry) => entry.isIntersecting)) {
                dispose(element);
                dotNetRef.invokeMethodAsync(methodName);
            }
        }, {
            root: getScrollParent(element),
            rootMargin: "0px 0px 80px 0px",
            threshold: 0.1
        });

        observer.observe(element);
        observers.set(element, observer);
    }

    function getScrollTop(element) {
        return getScrollParent(element)?.scrollTop ?? 0;
    }

    function setScrollTop(element, scrollTop) {
        const scrollParent = getScrollParent(element);
        if (!scrollParent) {
            return;
        }

        window.requestAnimationFrame(() => {
            scrollParent.scrollTop = scrollTop;
        });
    }

    return {
        observe,
        dispose,
        getScrollTop,
        setScrollTop
    };
})();
