window.documentSupport = {
    getRelativePoint: function (element, clientX, clientY) {
        if (!element) {
            return { x: 0.5, y: 0.5 };
        }

        const rect = element.getBoundingClientRect();
        const x = rect.width <= 0 ? 0.5 : Math.min(1, Math.max(0, (clientX - rect.left) / rect.width));
        const y = rect.height <= 0 ? 0.5 : Math.min(1, Math.max(0, (clientY - rect.top) / rect.height));
        return { x, y };
    }
};
