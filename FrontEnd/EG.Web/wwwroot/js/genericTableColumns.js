window.egestionTableColumns = window.egestionTableColumns || {
    getColumns: function (elementId) {
        const root = document.getElementById(elementId);

        if (!root) {
            return [];
        }

        const headerRow =
            root.querySelector(".mud-table > .mud-table-container > table.mud-table-root > thead > tr") ||
            root.querySelector("thead > tr");

        if (!headerRow) {
            return [];
        }

        return Array.from(headerRow.children)
            .filter((cell) => cell.tagName && cell.tagName.toLowerCase() === "th")
            .map((cell, index) => {
                const label = (cell.textContent || "").replace(/\s+/g, " ").trim();
                const normalized = label
                    .normalize("NFD")
                    .replace(/[\u0300-\u036f]/g, "")
                    .toLowerCase();

                return {
                    index: index + 1,
                    label: label || `Columna ${index + 1}`,
                    isAction: !label || normalized === "accion" || normalized === "acciones"
                };
            });
    }
};
