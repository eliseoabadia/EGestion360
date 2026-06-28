window.egReportingPdf = (() => {
    const activeUrls = new Map();

    function normalizeToken(token) {
        if (!token) {
            return "";
        }

        let value = `${token}`.trim();
        if ((value.startsWith("\"") && value.endsWith("\"")) ||
            (value.startsWith("'") && value.endsWith("'"))) {
            value = value.substring(1, value.length - 1);
        }

        return value.startsWith("Bearer ") ? value : `Bearer ${value}`;
    }

    function clear(containerId) {
        const currentUrl = activeUrls.get(containerId);
        if (currentUrl) {
            URL.revokeObjectURL(currentUrl);
            activeUrls.delete(containerId);
        }
    }

    async function render(containerId, url, token) {
        const container = document.getElementById(containerId);
        if (!container) {
            return { ok: false, message: "No se encontro el contenedor del reporte." };
        }

        clear(containerId);
        container.innerHTML = "";

        const headers = {};
        const authHeader = normalizeToken(token);
        if (authHeader && authHeader !== "Bearer ") {
            headers.Authorization = authHeader;
        }

        const response = await fetch(url, { headers });
        if (!response.ok) {
            const text = await response.text();
            return {
                ok: false,
                message: text || `No se pudo generar el reporte (${response.status}).`
            };
        }

        const blob = await response.blob();
        const objectUrl = URL.createObjectURL(blob);
        activeUrls.set(containerId, objectUrl);

        const frame = document.createElement("iframe");
        frame.src = objectUrl;
        frame.title = "Reporte PDF";
        frame.className = "reporting-pdf-frame";
        container.appendChild(frame);

        return { ok: true, message: "" };
    }

    return { render, clear };
})();
