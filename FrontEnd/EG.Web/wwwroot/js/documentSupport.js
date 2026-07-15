window.documentSupport = {
    previewUrls: new Map(),

    createPreviewUrl: function (key, base64Data, contentType) {
        this.revokePreviewUrl(key);

        const binary = atob(base64Data);
        const bytes = new Uint8Array(binary.length);
        for (let index = 0; index < binary.length; index++) {
            bytes[index] = binary.charCodeAt(index);
        }

        const url = URL.createObjectURL(new Blob([bytes], {
            type: contentType || "application/octet-stream"
        }));
        this.previewUrls.set(key, url);
        return url;
    },

    revokePreviewUrl: function (key) {
        const url = this.previewUrls.get(key);
        if (url) {
            URL.revokeObjectURL(url);
            this.previewUrls.delete(key);
        }
    },

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
