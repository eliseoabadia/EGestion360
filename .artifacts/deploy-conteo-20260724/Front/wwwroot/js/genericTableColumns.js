(() => {
    const tableStates = new Map();
    const minColumnWidth = 64;
    const actionColumnClass = "eg-action-column";
    const actionCellClass = "eg-action-cell";

    const getRoot = (elementId) => document.getElementById(elementId);

    const getTable = (root) => {
        if (root?.tagName?.toLowerCase() === "table") {
            return root;
        }

        return root?.querySelector(".mud-table > .mud-table-container > table.mud-table-root") ||
            root?.querySelector("table");
    };

    const getHeaderRow = (root) =>
        getTable(root)?.querySelector("thead > tr") ||
        root?.querySelector("thead > tr");

    const getHeaderCells = (root) =>
        Array.from(getHeaderRow(root)?.children || [])
            .filter((cell) => cell.tagName?.toLowerCase() === "th");

    const getBodyRows = (root) =>
        Array.from(getTable(root)?.querySelectorAll("tbody > tr") || []);

    const getColumnCells = (root, index) => [
        getHeaderCells(root)[index],
        ...getBodyRows(root).map((row) => row.children[index]).filter(Boolean)
    ].filter(Boolean);

    const getActionControls = (cell) => {
        const candidates = Array.from(cell.querySelectorAll("button, a, .mud-button-root"));
        const unique = candidates.filter((candidate, index) =>
            candidates.findIndex((item) => item === candidate || item.contains(candidate)) === index);

        return unique.filter((control) => {
            const style = window.getComputedStyle(control);
            return style.display !== "none" && style.visibility !== "hidden";
        });
    };

    const getActionControlsWidth = (cell) => {
        const controls = getActionControls(cell);
        const controlsWidth = controls.reduce((total, control) =>
            total + Math.ceil(control.getBoundingClientRect().width || 34), 0);

        return controlsWidth + (Math.max(0, controls.length - 1) * 2);
    };

    const getState = (elementId) => {
        let state = tableStates.get(elementId);

        if (!state) {
            state = {
                dragIndex: null,
                widths: new Map(),
                order: [],
                observer: null,
                refreshTimer: null,
                interactionsEnabled: false
            };
            tableStates.set(elementId, state);
        }

        return state;
    };

    const normalizeLabel = (text) =>
        (text || "")
            .replace(/\s+/g, " ")
            .trim();

    const getColumnLabel = (cell, index) => {
        const clone = cell.cloneNode(true);
        clone.querySelectorAll(".eg-column-resizer").forEach((handle) => handle.remove());
        clone.querySelectorAll(".eg-column-drag-handle").forEach((handle) => handle.remove());
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

    const applyActionColumnLayout = (root) => {
        const headerCells = getHeaderCells(root);

        headerCells.forEach((cell) => cell.classList.remove(actionColumnClass));
        getBodyRows(root).forEach((row) => {
            Array.from(row.children).forEach((cell) => {
                cell.classList.remove(actionColumnClass, actionCellClass);
            });
        });

        headerCells.forEach((cell, index) => {
            if (!isActionColumn(getColumnLabel(cell, index))) {
                return;
            }

            const maxControlsWidth = Math.max(
                0,
                ...getBodyRows(root).map((row) => getActionControlsWidth(row.children[index] ?? row)));
            const compactWidth = Math.max(96, Math.min(360, 24 + maxControlsWidth));
            const actionWidth = `${compactWidth}px`;

            getColumnCells(root, index).forEach((columnCell) => {
                columnCell.classList.add(actionColumnClass);
                columnCell.style.setProperty("--eg-action-column-width", actionWidth);
                columnCell.style.setProperty("width", actionWidth, "important");
                columnCell.style.setProperty("min-width", actionWidth, "important");
                columnCell.style.setProperty("max-width", actionWidth, "important");

                if (columnCell.tagName?.toLowerCase() === "td") {
                    columnCell.classList.add(actionCellClass);
                }
            });
        });
    };

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

        saveWidths(root, state);
        moveChild(headerRow, fromIndex, toIndex);
        getBodyRows(root).forEach((row) => moveChild(row, fromIndex, toIndex));
        saveOrder(root, state);
        applyWidths(root, state);
        applyActionColumnLayout(root);
        setupHeaderInteractions(root, state);
    };

    const applyOrder = (root, state) => {
        if (!state.order.length || state.dragIndex !== null) {
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
            applyWidths(root, state);
            applyActionColumnLayout(root);
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

            if (event.button !== 0) {
                return;
            }

            saveWidths(root, state);

            const startX = event.clientX;
            const startWidth = cell.getBoundingClientRect().width;
            root.classList.add("eg-column-resizing");
            handle.setPointerCapture?.(event.pointerId);

            const onPointerMove = (moveEvent) => {
                const width = Math.max(minColumnWidth, startWidth + moveEvent.clientX - startX);
                const key = getColumnKey(cell, index);

                if (key) {
                    state.widths.set(key, Math.round(width));
                }

                setColumnWidth(root, index, width);
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

    const setupDragHandle = (root, state, cell, index) => {
        let handle = cell.querySelector(":scope > .eg-column-drag-handle");

        if (!handle) {
            handle = document.createElement("span");
            handle.className = "eg-column-drag-handle";
            handle.title = "Arrastra para mover la columna";
            handle.setAttribute("aria-hidden", "true");
            cell.insertBefore(handle, cell.firstChild);
        }

        handle.draggable = true;

        handle.ondragstart = (event) => {
            saveWidths(root, state);
            state.dragIndex = index;
            cell.classList.add("eg-column-drag-source");
            root.classList.add("eg-column-dragging");
            event.dataTransfer.effectAllowed = "move";
            event.dataTransfer.setData("text/plain", String(index));
        };

        handle.ondragend = () => {
            state.dragIndex = null;
            root.classList.remove("eg-column-dragging");
            getHeaderCells(root).forEach((item) => item.classList.remove("eg-column-drag-source", "eg-column-drop-target"));
        };
    };

    function setupHeaderInteractions(root, state) {
        const cells = getHeaderCells(root);

        cells.forEach((cell, index) => {
            cell.classList.add("eg-column-resizable");
            cell.classList.add("eg-column-draggable");
            cell.removeAttribute("draggable");
            setupDragHandle(root, state, cell, index);
            setupResizeHandle(root, state, cell, index);

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
                root.classList.remove("eg-column-dragging");

                if (!Number.isNaN(fromIndex) && fromIndex !== index) {
                    moveColumn(root, fromIndex, index, state);
                }
            };
        });
    }

    const scheduleRefresh = (root, state) => {
        window.clearTimeout(state.refreshTimer);
        state.refreshTimer = window.setTimeout(() => {
            if (state.interactionsEnabled) {
                applyOrder(root, state);
                applyWidths(root, state);
                setupHeaderInteractions(root, state);
            }

            applyActionColumnLayout(root);
        }, 80);
    };

    const ensureObserver = (root, table, state) => {
        if (!state.observer) {
            state.observer = new MutationObserver(() => scheduleRefresh(root, state));
            state.observer.observe(table, { childList: true, subtree: true });
        }
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

        setupActionColumns: function (elementId) {
            const root = getRoot(elementId);
            const table = getTable(root);

            if (!root || !table) {
                return;
            }

            const state = getState(elementId);

            applyActionColumnLayout(root);
            ensureObserver(root, table, state);
        },

        setupInteractions: function (elementId) {
            const root = getRoot(elementId);
            const table = getTable(root);

            if (!root || !table) {
                return;
            }

            const state = getState(elementId);
            state.interactionsEnabled = true;

            root.classList.add("eg-table-interactive-columns");
            applyOrder(root, state);
            applyWidths(root, state);
            setupHeaderInteractions(root, state);
            applyActionColumnLayout(root);

            ensureObserver(root, table, state);
        }
    };

    const setupDocumentActionColumns = () => {
        let refreshTimer = null;

        const refresh = () => {
            window.clearTimeout(refreshTimer);
            refreshTimer = window.setTimeout(() => {
                document
                    .querySelectorAll("table.mud-table-root")
                    .forEach((table) => applyActionColumnLayout(table));
            }, 80);
        };

        const start = () => {
            if (!document.body) {
                return;
            }

            refresh();
            new MutationObserver(refresh).observe(document.body, { childList: true, subtree: true });
        };

        if (document.readyState === "loading") {
            document.addEventListener("DOMContentLoaded", start, { once: true });
            return;
        }

        start();
    };

    setupDocumentActionColumns();
})();
