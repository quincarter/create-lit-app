# Preact Signals & Persistence Stores
if [ "$ENABLE_SIGNALS" = true ]; then
cat <<'EOF' > src/shared/stores/persistent-signal.ts
import { effect, signal, type Signal } from "@lit-labs/preact-signals";
import { openDB, type IDBPDatabase } from "idb";

const DB_NAME = "app-shell-store";
const STORE_NAME = "signals";
const DB_VERSION = 1;

let dbPromise: Promise<IDBPDatabase> | null = null;

const getDB = () => {
	if (!dbPromise) {
		dbPromise = openDB(DB_NAME, DB_VERSION, {
			upgrade(db) {
				if (!db.objectStoreNames.contains(STORE_NAME)) {
					db.createObjectStore(STORE_NAME);
				}
			},
		});
	}
	return dbPromise;
};

export interface PersistentSignalOptions {
	key?: string;
}

export function persistentSignal<T>(
	defaultValue: T,
	options: PersistentSignalOptions = {},
): Signal<T> {
	const { key } = options;
	const s = signal<T>(defaultValue);

	if (!key) return s;

	const initialized = signal(false);

	getDB().then(async (db) => {
		try {
			const storedValue = await db.get(STORE_NAME, key);
			if (storedValue !== undefined) {
				s.value = storedValue;
			}
		} catch (error) {
			console.error(`Failed to load persistent signal for key "${key}":`, error);
		} finally {
			initialized.value = true;
		}
	});

	effect(() => {
		const value = s.value;
		if (!initialized.value) return;

		(async () => {
			try {
				const db = await getDB();
				await db.put(STORE_NAME, value, key);
			} catch (error) {
				console.error(`Failed to persist signal for key "${key}":`, error);
			}
		})();
	});

	return s;
}

export async function clearPersistentSignals(): Promise<void> {
	const db = await getDB();
	await db.clear(STORE_NAME);
}
EOF

cat <<'EOF' > src/shared/stores/todo.store.ts
import { persistentSignal } from "./persistent-signal";
import type { ITodoItem } from "../interfaces/todos.interface";

export const todosSignal = persistentSignal<Record<string, ITodoItem>>({}, { key: "todos" });

export const addTodo = (title: string, description?: string) => {
	const id = crypto.randomUUID();
	todosSignal.value = {
		...todosSignal.value,
		[id]: { id, title, description, checked: false },
	};
	return id;
};

export const toggleTodo = (id: string) => {
	const todo = todosSignal.value[id];
	if (todo) {
		todosSignal.value = {
			...todosSignal.value,
			[id]: { ...todo, checked: !todo.checked },
		};
	}
};

export const removeTodo = (id: string) => {
	const newTodos = { ...todosSignal.value };
	delete newTodos[id];
	todosSignal.value = newTodos;
};
EOF

cat <<'EOF' > src/shared/stores/todo-list.store.ts
import { computed } from "@lit-labs/preact-signals";
import { persistentSignal } from "./persistent-signal";
import { todosSignal } from "./todo.store";

export const todoOrderSignal = persistentSignal<string[]>([], { key: "todo-order" });
export const sortDirectionSignal = persistentSignal<"asc" | "desc">("asc", { key: "sort-direction" });

export const sortedTodosSignal = computed(() => {
	const todos = todoOrderSignal.value
		.map((id) => todosSignal.value[id])
		.filter(Boolean);

	return sortDirectionSignal.value === "asc"
		? [...todos].sort((a, b) => a.title.localeCompare(b.title))
		: [...todos].sort((a, b) => b.title.localeCompare(a.title));
});

export const addIdToOrder = (id: string) => {
	todoOrderSignal.value = [...todoOrderSignal.value, id];
};

export const removeIdFromOrder = (id: string) => {
	todoOrderSignal.value = todoOrderSignal.value.filter(
		(todoId) => todoId !== id,
	);
};

export const toggleSortDirection = () => {
	sortDirectionSignal.value =
		sortDirectionSignal.value === "asc" ? "desc" : "asc";
};
EOF
fi

# Internal Views
mkdir -p src/shared/internal-views/404-not-found
cat <<'EOF' > src/shared/internal-views/404-not-found/PageNotFound.ts
import { css, html, LitElement } from "lit";
export class PageNotFound extends LitElement {
	static styles = [css`:host { display: block; padding: 2rem; }`];
	render() { return html`<h2>404 - Page Not Found</h2>`; }
}
EOF
cat <<'EOF' > src/shared/internal-views/404-not-found/page-not-found.ts
import { PageNotFound } from "./PageNotFound";
customElements.define("page-not-found", PageNotFound);
EOF

mkdir -p src/shared/internal-views/no-access
cat <<'EOF' > src/shared/internal-views/no-access/NoAccess.ts
import { css, html, LitElement } from "lit";
export class NoAccess extends LitElement {
	static styles = [css`:host { display: block; padding: 2rem; }`];
	render() { return html`<h2>Access Denied</h2>`; }
}
EOF
cat <<'EOF' > src/shared/internal-views/no-access/no-access.ts
import { NoAccess } from "./NoAccess";
customElements.define("no-access", NoAccess);
EOF

mkdir -p src/shared/internal-views/under-construction
cat <<'EOF' > src/shared/internal-views/under-construction/UnderConstruction.ts
import { css, html, LitElement } from "lit";
export class UnderConstruction extends LitElement {
	static styles = [css`:host { display: block; padding: 2rem; }`];
	render() { return html`<h2>Under Construction</h2>`; }
}
EOF
cat <<'EOF' > src/shared/internal-views/under-construction/under-construction.ts
import { UnderConstruction } from "./UnderConstruction";
customElements.define("under-construction", UnderConstruction);
EOF
