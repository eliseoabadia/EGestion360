(() => {
    const tableStates = new Map();
    const minColumnWidth = 56;

    const getRoot = (elementId) => document.getElementById(elementId);

    const getTable = (root) =>
        root?.querySelector(".mud-table > .mud-table-container > table.mud-table-root") ||
        root?.querySelector("table");

    const getHeaderRow = (root) =>
        getTable(root)?.querySelector("thead > tr") ||
        root?.querySelector("thead > tr");

    const getHeaderCells = (root) =>
        Array.from(getHeaderRow(root)?.children || [])
            .filter((cell) => cell.tagName?.toLowerCase() === "th");

    const getBodyRows = (root) =>
        Array.from(getTable(root)?.querySelectorAll("tbody > tr") || []);

    const normalizeLabel = (text) =>
        (text || "")
            .replace(/\s+/g, " ")
            .trim();

    const getColumnLabel = (cell, index) => {
        const clone = cell.cloneNode(true);
        clone.querySelectorAll(".eg-column-resizer").forEach((handle) => handle.remove());
        return normalizeLabel(clone.textContent) || `Columna ${index + 1}`;
    };

    const getColumnKey = (cell, index) =>
        getColumnLabel(cell, index)
            .normalize("NFD")
            .replace(/[\u0300-\u036f]/g, "")
            .toLowerCase();

    const isActionColumn = (label) => {
        const normalized = label
            .normalize("NFD")
            .replace(/[\u0300-\u036f]/g, "")
            .toLowerCase();

        return !label || normalized === "accion" || normalized === "acciones";
    };

    const shouldIgnoreDrag = (event) =>
        event.target.closest(".eg-column-resizer,button,a,input,textarea,select,.mud-button-root,.mud-input,.mud-checkbox");

    const setColumnWidth = (root, index, width) => {
        const normalizedWidth = `${Math.max(minColumnWidth, Math.round(width))}px`;
        const cells = [
            getHeaderCells(root)[index],
            ...getBodyRows(root).map((row) => row.children[index]).filter(Boolean)
        ];

        cells.forEach((cell) => {
            cell.style.width = normalizedWidth;
            cell.style.minWidth = normalizedWidth;
            cell.style.maxWidth = normalizedWidth;
        });
    };

    const saveWidths = (root, state) => {
        getHeaderCells(root).forEach((cell, index) => {
            const key = getColumnKey(cell, index);
            const width = cell.getBoundingClientRect().width;

            if (key && width > 0) {
                state.widths.set(key, Math.round(width));
            }
        });
    };

    const applyWidths = (root, state) => {
        getHeaderCells(root).forEach((cell, index) => {
            const width = state.widths.get(getColumnKey(cell, index));

            if (width) {
                setColumnWidth(root, index, width);
            }
        });
    };

    const moveChild = (row, fromIndex, toIndex) => {
        if (!row || fromIndex === toIndex) {
            return;
        }

        const cells = Array.from(row.children);
        const moving = cells[fromIndex];
        const target = cells[toIndex];

        if (!moving || !target) {
            return;
        }

        row.insertBefore(moving, fromIndex < toIndex ? target.nextSibling : target);
    };

    const saveOrder = (root, state) => {
        state.order = getHeaderCells(root).map((cell, index) => getColumnKey(cell, index));
    };

    const moveColumn = (root, fromIndex, toIndex, state) => {
        const headerRow = getHeaderRow(root);

        moveChild(headerRow, fromIndex, toIndex);
        getBodyRows(root).forEach((row) => moveChild(row, fromIndex, toIndex));
        saveOrder(root, state);
        applyWidths(root, state);
        setupHeaderInteractions(root, state);
    };

    const applyOrder = (root, state) => {
        if (!state.order.length) {
            return;
        }

        let changed = false;

        state.order.forEach((key, targetIndex) => {
            const cells = getHeaderCells(root);
            const currentIndex = cells.findIndex((cell, index) => getColumnKey(cell, index) === key);

            if (currentIndex >= 0 && currentIndex !== targetIndex) {
                const headerRow = getHeaderRow(root);
                moveChild(headerRow, currentIndex, targetIndex);
                getBodyRows(root).forEach((row) => moveChild(row, currentIndex, targetIndex));
                changed = true;
            }
        });

        if (changed) {
            setupHeaderInteractions(root, state);
        }
    };

    const setupResizeHandle = (root, state, cell, index) => {
        let handle = cell.querySelector(":scope > .eg-column-resizer");

        if (!handle) {
            handle = document.createElement("span");
            handle.className = "eg-column-resizer";
            handle.title = "Arrastra para ajustar el ancho";
            cell.appendChild(handle);
        }

        handle.onpointerdown = (event) => {
            event.preventDefault();
            event.stopPropagation();

            const startX = event.clientX;
            const startWidth = cell.getBoundingClientRect().width;
            root.classList.add("eg-column-resizing");
            handle.setPointerCapture?.(event.pointerId);

            const onPointerMove = (moveEvent) => {
                setColumnWidth(root, index, startWidth + moveEvent.clientX - startX);
            };

            const onPointerUp = () => {
                document.removeEventListener("pointermove", onPointerMove);
                document.removeEventListener("pointerup", onPointerUp);
                root.classList.remove("eg-column-resizing");
                saveWidths(root, state);
            };

            document.addEventListener("pointermove", onPointerMove);
            document.addEventListener("pointerup", onPointerUp, { once: true });
        };
    };

    function setupHeaderInteractions(root, state) {
        const cells = getHeaderCells(root);

        cells.forEach((cell, index) => {
            cell.classList.add("eg-column-draggable");
            cell.setAttribute("draggable", "true");
            cell.title = cell.title || "Arrastra para mover la columna";
            setupResizeHandle(root, state, cell, index);

            cell.ondragstart = (event) => {
                if (shouldIgnoreDrag(event)) {
                    event.preventDefault();
                    return;
                }

                state.dragIndex = index;
                cell.classList.add("eg-column-drag-source");
                event.dataTransfer.effectAllowed = "move";
                event.dataTransfer.setData("text/plain", String(index));
            };

            cell.ondragover = (event) => {
                if (state.dragIndex === null || state.dragIndex === index) {
                    return;
                }

                event.preventDefault();
                event.dataTransfer.dropEffect = "move";
                cell.classList.add("eg-column-drop-target");
            };

            cell.ondragleave = () => {
                cell.classList.remove("eg-column-drop-target");
            };

            cell.ondrop = (event) => {
                event.preventDefault();
                cell.classList.remove("eg-column-drop-target");

                const fromIndex = state.dragIndex ?? Number(event.dataTransfer.getData("text/plain"));
                state.dragIndex = null;

                if (!Number.isNaN(fromIndex) && fromIndex !== index) {
                    moveColumn(root, fromIndex, index, state);
                }
            };

            cell.ondragend = () => {
                state.dragIndex = null;
                cells.forEach((item) => item.classList.remove("eg-column-drag-source", "eg-column-drop-target"));
            };
        });
    }

    const scheduleRefresh = (root, state) => {
        window.clearTimeout(state.refreshTimer);
        state.refreshTimer = window.setTimeout(() => {
            applyOrder(root, state);
            applyWidths(root, state);
            setupHeaderInteractions(root, state);
        }, 50);
    };

    window.egestionTableColumns = {
        getColumns: function (elementId) {
            const root = getRoot(elementId);

            if (!root) {
                return [];
            }

            return getHeaderCells(root).map((cell, index) => {
                const label = getColumnLabel(cell, index);

                return {
                    index: index + 1,
                    label,
                    isAction: isActionColumn(label)
                };
            });
        },

        setupInteractions: function (elementId) {
            const root = getRoot(elementId);
            const table = getTable(root);

            if (!root || !table) {
                return;
            }

            let state = tableStates.get(elementId);

            if (!state) {
                state = {
                    dragIndex: null,
                    widths: new Map(),
                    order: [],
                    observer: null,
                    refreshTimer: null
                };
                tableStates.set(elementId, state);
            }

            root.classList.add("eg-table-interactive-columns");
            applyOrder(root, state);
            applyWidths(root, state);
            setupHeaderInteractions(root, state);

            if (!state.observer) {
                state.observer = new MutationObserver(() => scheduleRefresh(root, state));
                state.observer.observe(table, { childList: true, subtree: true });
            }
        }
    };
})();
