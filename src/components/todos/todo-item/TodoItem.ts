import { html, LitElement } from "lit";
import { property } from "lit/decorators.js";
import { removeTodo, toggleTodo } from "../../../shared/stores/todo.store";
import { removeIdFromOrder } from "../../../shared/stores/todo-list.store";
import { TodoItemStyles } from "./todo-item.styles";

export class TodoItem extends LitElement {
	@property({ type: String })
	id = "";

	@property({ type: String, attribute: "item-title" })
	title = "";

	@property({ type: String, attribute: "item-description" })
	description = "";

	@property({ type: Boolean, attribute: "is-checked" })
	isChecked = false;

	static styles = [TodoItemStyles];

	onChecked() {
		toggleTodo(this.id);
	}

	onDelete() {
		removeTodo(this.id);
		removeIdFromOrder(this.id);
	}

	render() {
		return html`
			<div class="todo-item ${this.isChecked ? "checked" : ""}">
				<input type="checkbox" .checked="${this.isChecked}" @change="${this.onChecked}" />
				<div class="content">
					<span class="title">${this.title}</span>
					${this.description ? html`<span class="description">${this.description}</span>` : ""}
				</div>
				<button @click="${this.onDelete}">Delete</button>
			</div>
		`;
	}
}
