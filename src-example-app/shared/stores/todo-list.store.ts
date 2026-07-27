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
