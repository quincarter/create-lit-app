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
