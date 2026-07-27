import { SignalWatcher } from "@lit-labs/preact-signals";
import { type CSSResultOrNative, html, LitElement } from "lit";
import { query } from "lit/decorators.js";
import { repeat } from "lit/directives/repeat.js";
import { addTodo } from "../../../shared/stores/todo.store";
import {
	addIdToOrder,
	sortDirectionSignal,
	sortedTodosSignal,
	toggleSortDirection,
} from "../../../shared/stores/todo-list.store";
import "../todo-item/todo-item";
import { TodoListStyles } from "./todo-list.styles";

export class TodoList extends SignalWatcher(LitElement) {
	static styles: CSSResultOrNative[] = [TodoListStyles];

	@query("#todo-input")
	inputElement!: HTMLInputElement;

	private _onAddTodo() {
		const title = this.inputElement.value.trim();
		console.log("title", title);
		if (title) {
			const id = addTodo(title);
			addIdToOrder(id);
			this.inputElement.value = "";
		}
	}

	private _toggleSort() {
		toggleSortDirection();
	}

	render() {
		return html`
            <div class="todo-list-container">
                <header>
                    <h2>Todos</h2>
                    <button class="sort-btn" @click="${this._toggleSort}">
                        Sort: ${sortDirectionSignal.value.toUpperCase()}
                    </button>
                </header>

                <div class="input-area">
                    <input id="todo-input" type="text" placeholder="Add a new todo..." />
                    <button @click="${this._onAddTodo}">Add</button>
                </div>

                <div class="list">
                    ${repeat(
											sortedTodosSignal.value,
											(item) => item.id,
											(item) => html`
                        <todo-item
                            .id="${item.id}"
                            .title="${item.title}"
                            .description="${item.description || ""}"
                            .isChecked="${item.checked}"
                        ></todo-item>
                    `,
										)}
                </div>
            </div>
        `;
	}
}
